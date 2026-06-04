# script to XXX on FR Virtual Machine following export of tiles from DASH

#===============================================================================
# Preamble
#===============================================================================

source("WP3/code/mapped_outputs/0_setup_gaps.R")
source("WP3/code/mapped_outputs/1_functions.R")

# read in data
rh90_incomplete <- rast(paste0(path_Z_rh90, "drafts/rh90_incomplete_2020_30m.tif"))
gap_fraction <- rast(path_Z_gap_frac_eng)
fyl_VOM <- rast(path_VOM_fyl)
england <-
  vect("Z:/CESB/Land Use and Ecosystem Service/LUES_Sware/PersonalFolders/Joe/Data/ONS_Open_Geography/Countries_Dec_2021_GB_BFC_2022_6264036014383714060.gpkg") %>% 
  filter(CTRY21NM == "England")


#===============================================================================
# Fylindales
#===============================================================================

# create RH90 map for Fylingdales
fyl_VOM_30m_rh90 <-
  terra::aggregate(
    fyl_VOM,
    fact = 30,
    fun = function(x) {
      quantile(x, 0.9, na.rm = TRUE)}
  )


# remove fylingdales area from RH90 map
fyl_ext <- ext(fyl_VOM_30m_rh90) %>% as.polygons()
crs(fyl_ext) <- crs(fyl_VOM_30m_rh90)

rh90_incomplete_mask <- mask(rh90_incomplete, fyl_ext, inverse = TRUE)


# mosaic fylingdales into RH90 map
rh90_sprc <- sprc(list(rh90_incomplete_mask, fyl_VOM_30m_rh90))
rh90_1 <- terra::mosaic(rh90_sprc)


#===============================================================================
# empty tiles
#===============================================================================

vom_files <-
  list.files(
    path = path_Vom,
    pattern =  "\\.tif$",
    recursive = TRUE,
    full.names = TRUE,
    ignore.case = TRUE)


# create vect of erroneous regions buffered by 30m
sp_ext <- ext(480000, 485000, 200000, 201500)
su_ext <- ext(490000, 495000, 130000, 132500)


# function to calculate rh90 for ext
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
  
  # load VOM tile, crop and calculate RH90
  vom_tile <- rast(vom_tile_path)
  vom_tile_clip <- terra::crop(vom_tile, vect, mask = TRUE)
  
  vom_tile_rh90 <- 
    terra::aggregate(
      vom_tile_clip,
      fact = 30,
      fun = function(x) {
        quantile(x, 0.9, na.rm = TRUE)}
    )
  
  return(vom_tile_rh90)
}

sp_rh90 <- rh90_from_ext(sp_ext)
su_rh90 <- rh90_from_ext(su_ext)


# remove tile areas from RH90 map
rh90_1_mask <- mask(rh90_1, ext(sp_rh90), inverse = TRUE)
rh90_1_mask <- mask(rh90_1, ext(su_rh90), inverse = TRUE)


# mosaic tile into RH90 map
rh90_sprc <- sprc(list(rh90_1_mask, sp_rh90, su_rh90))
rh90_2 <- terra::mosaic(rh90_sprc)


#===============================================================================
# Final clean and tidy
#===============================================================================

# resample to geometry of gap fraction and fhd maps
rh90 <- terra::resample(rh90_2, gap_fraction)


# clip to England
rh90_final <- terra::crop(rh90, england, mask = TRUE)


# tidy
varnames(rh90_final) <- "rh90"
names(rh90_final) <- "rh90_30m"


# write
writeRaster(rh90_final,
            paste0(path_Z_rh90, "rh90_england_2020_30m.tif"),
            overwrite = TRUE)

