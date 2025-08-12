# This is a script of helper functions for comparing sCHM and LiDAR CHM rasters and their derived structure metrics



# Raster catalog engine for extracting areas of non adjacent rasters
#and saving them as R list ---- !#
# This function converts each raster extent into a vector
tifCat <- function(f){
 
  for(i in 1:length(f)){
    
    r <-  rast(f[i])
    p <- as.polygons(ext(r), crs = crs(r))
    p$path <- f[i]
    
    if(i == 1){ r_catalog = p}
    else{ r_catalog = rbind(r_catalog, p) }
  }
  return(r_catalog)
}

# This applies the above function to a folder and returns the feature vectors as an sf object
rastCat <- function(folder){
  
  files <- list.files(folder, full = TRUE)
  cat <- tifCat(files)
  return(st_as_sf(cat))
}


# For each polygon read in the corresponding raster and clip it to the feature extent
# Rasters are now returned as a list, the order of which corresponds to the order of your polygons.
clip_aoiRast <- function(pol, cat){
 # pol <- nfi
# cat <- sCHMs
  rastList <- list() # Create a list to store rasters
  for(i in 1:nrow(pol)){
    #i <- 95
    # update message
    message(paste0("Processing polygon ", i, " / ", nrow(pol)))
    
    # Find all rasters whose extents intersect the polygon
    overlaps <- st_filter(cat, pol[i, ], .predicate = st_intersects)
    
    # skip if no overlaps
    if(nrow(overlaps) == 0){
      next
    }
    
    # this loop deals with multiple tiles overlapping a single polyon
    rasters <- list()
    poly_vect <- vect(pol[i, ])  
    for(j in 1:nrow(overlaps)){
      #j <- 1
      r <- rast(overlaps$path[j])
      r_crop <- tryCatch({
        cropped <- terra::crop(r, poly_vect)
        masked <- terra::mask(cropped, buffer(poly_vect, 10))
        masked
      }, error = function(e) NULL)# Sometimes theres not enough overlap for a crop in which case we disregard
      
      if (!is.null(r_crop)) {
        rasters[[j]] <- r_crop
        }
      }
    
    
    # If more than one raster overlaps, mosaic them together
    rasters <- compact(rasters)# remove null elements
    if(length(rasters) > 1){
      rast_merged <- do.call(mosaic, rasters)
    } else {
      rast_merged <- rasters[[1]]
    }
    
    # Optional: give a name to the raster based on a polygon ID
    names(rast_merged) <- pol$OBJECTID[i]
    rastList[[i]] <- rast_merged
  }
    return(rastList)
}







# Function to match the order of polygons and chms
chmMatch <- function(chmDir, Shapes){
  chmDir <- sCHMclipPath
  Shapes <- nfi
  Files <- dir(chmDir) # Find files in the folder
  #chmIds <- as.numeric(gsub("\\.tif$", "", Files)) # Remove file name extensions and turn numeric
  chmIds <- gsub("\\.tif$", "", Files) # Remove file name extensions
  shapes_reordered <- Shapes[match(chmIds, Shapes$OBJECTID),]
  return(shapes_reordered)
}






# Extract metrics ---- !#
# Gap fraction
# chm is the canopy height model
# Shape is the corresponding SF object for the chm
gapsToRast <- function(chm, Shape){
  # Gap detection algorithm based on max height within gaps and a minimal surface area
  gapSF <- gap_detection(chm,
                         res = 1,
                         gap_max_height = gapHeight,
                         min_gap_surface = gapSize)
  
  # Areas external to the woodland are considered gaps to fill out raster
  # These areas are removed below
  gapMask <- mask(gapSF, buffer(vect(Shape), -1.5))# remove external area by masking by site
  # Identify where this area protruded to count gaps smaller than our minimum surface
  freqs <- freq(gapMask[[1]])
  freqsSubset <- freqs[freqs$count >= gapSize, ]
  validGaps <- unique(freqsSubset$value)
  
  # Remove small gaps using the earlier freqs subset
  gaps <- tidyterra::filter(gapMask, gap_id %in% validGaps)
  
  return(gaps)
}


# gap_raster is the gaps object
# site_ID is the ID of the site on which metrics are being calculated
calculate_gap_metrics = function(gap_rasters, site_IDs) {
  
  dfList <- c()
  for(i in 1:length(gap_rasters)){
  
  dfList[[i]] =
    calculate_lsm(landscape = gap_rasters[[i]][[1]],
                  level = c("landscape"),
                  what = c(l_metrics)) %>% 
    
    # pivot wider to give one row per gap/site
    pivot_wider(names_from = metric,
                values_from = value) %>%
    
    # add IDs
    mutate(
           "OBJECTID" = site_IDs[[i]],
           .before = id) %>%
    
    # tidy
    select(-c(layer, class, id))
  }
  
  df <- do.call(rbind, dfList)
  
  return(df)
}


# Top canopy heights----#!
# Top canopy heights----#!
# Entropy function to operate at varying resolutions
canopyEntropy <- function(heights, strata){
  # Tidy some ground heights
  heights[heights < 0] <- 0
  heights <- heights[!is.na(heights)]
  # Bin Heights into stratas
  bins <- cut(heights, strata, labels = FALSE, include.lowest = TRUE)
  # find frequency of values in each bin
  freqs <- table(factor(bins, levels = 1:(length(strata)-1)))
  
  # Calculate effective canopy layers
  total_values <- sum(freqs)
  proportions <- freqs/total_values
  shannon_index <- -1*sum(proportions * log(proportions), na.rm = TRUE)
  effectiveCanopyLayers <- exp(shannon_index) |> round(2)
  return(effectiveCanopyLayers)
}


# This function takes a CHM and masks it by a corresponding shapefile to remove edge effects
# It then calculates Shannon's diversity index using chm values based on user defined canopy height bins
# Strata is user defined height bins
effCanopyLayer <- function(chm, shape, strata){
  
  chmMask <- mask(chm, st_buffer(shape,-5))
  canopyLayers <- canopyEntropy(values(chm), strata = strata)
}


# Zonal eff Canopy layer function ---- !#
# This function is for computing effective canopy layers zonally at varying cell resolutions
zonal_effCanopyLayer <- function(chm, shape, res, strata){
  # Remove edge effects
  chm <- mask(chm, st_buffer(shape, 10))
  effCanopyRaster <- raster_metrics(chm,
                                    fun = function(x)
                                      data.frame(effCanopy = canopyEntropy(x, strata = strata)),
                                    res = res
  )
  return(effCanopyRaster)  
}







# Model function to extract R2 ---- !#
get_r2 <- function(df) {
  model <- lm(Imagery ~ LiDAR, data = df)
  glance(model)$r.squared
}
