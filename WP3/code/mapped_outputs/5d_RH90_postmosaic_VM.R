# script to XXX on FR Virtual Machine following export of tiles from DASH

#===============================================================================
# Preamble
#===============================================================================

source("WP3/code/mapped_outputs/0_setup.R")
source("WP3/code/mapped_outputs/1_functions.R")

# read in data
rh90_incomplete <- rast(path_rh90_incomplete)
gap_fraction <- rast(path_gap_frac)
fyl_VOM <- rast(path_VOM_fyl)
england <-
  vect(path_england) %>% 
  filter(CTRY21NM == "England")


# resample to geometry of gap fraction and fhd maps
rh90_incomplete <- terra::resample(rh90_incomplete, gap_fraction)


#===============================================================================
# Fylingdales
#===============================================================================

fyl_ext <- ext(fyl_VOM) %>% as.polygons()
crs(fyl_ext) <- crs(fyl_VOM)


# create RH90 map for Fylingdales
fyl_VOM_30m_rh90 <-
  terra::aggregate(
    fyl_VOM,
    fact = 30,
    fun = function(x) {quantile(x, 0.9, na.rm = TRUE)}
  )


# resample to geometry of gap fraction and fhd maps
fyl_VOM_30m_rh90 <- 
  terra::resample(
    fyl_VOM_30m_rh90,
    terra::crop(gap_fraction, fyl_ext, mask = TRUE)
  )


# mosaic fylingdales into RH90 map
rh90_1 <- terra::mosaic(rh90_incomplete, fyl_VOM_30m_rh90,
                        fun = "last")


#===============================================================================
# empty tiles
#===============================================================================

vom_files <-
  list.files(
    path = dir_VOM,
    pattern =  "\\.tif$",
    recursive = TRUE,
    full.names = TRUE,
    ignore.case = TRUE)


# create vect of erroneous regions
sp_ext <- ext(480000, 485070, 199940, 201560)
su_ext <- ext(490000, 495070, 129940, 132880)


# function to calculate rh90 from VOM for ext
rh90_from_ext <- function(ext){
  
  vect <- vect(ext, crs = "epsg:27700")
  
  intersections <- list()
  
  for (i in seq(length(vom_files))) {
    
    r <- rast(vom_files[[i]])
    p <- as.polygons(ext(r), crs = "epsg:27700")
    
    int <- terra::intersect(vect, p)
    
    if (is.empty(int) == FALSE) {
      intersections[[i]] = vom_files[[i]] 
    }
  }
  
  vom_tile_path <- unlist(intersections)
  
  # load VOM tile(s), crop and calculate RH90
  if (length(vom_tile_path) > 1) {
    
    vom_tiles_list <- lapply(vom_tile_path, rast)
    vom_tiles_list_clip <- terra::crop(sprc(vom_tiles_list), vect)
    vom_tile_clip <- mosaic(vom_tiles_list_clip)
    
  } else{
    
    vom_tile <- rast(vom_tile_path)
    vom_tile_clip <- terra::crop(vom_tile, vect, mask = TRUE)
    
  }
  
  vom_tile_rh90 <- 
    terra::aggregate(
      vom_tile_clip,
      fact = 30,
      fun = function(x) {quantile(x, 0.9, na.rm = TRUE)}
    )
  
  # resample to geometry of gap fraction and fhd maps
  vom_tile_rh90 <- 
    terra::resample(
      vom_tile_rh90,
      terra::crop(gap_fraction, vect, mask = TRUE)
    )
  
  return(vom_tile_rh90)
}

sp_rh90 <- rh90_from_ext(sp_ext)
su_rh90 <- rh90_from_ext(su_ext)


# mosaic tile into RH90 map
rh90_2 <- terra::mosaic(rh90_1, sp_rh90, su_rh90,
                        fun = "last")


#===============================================================================
# Final clean and tidy
#===============================================================================

# clip to England
rh90_final <- terra::crop(rh90_2, england, mask = TRUE)


# tidy
varnames(rh90_final) <- "rh90"
names(rh90_final) <- "rh90_30m"


# write
writeRaster(rh90_final,
            path_rh90,
            overwrite = TRUE)

