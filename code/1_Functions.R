# # This section is only for testing functions ---- !#
# 
# 
# # Read in constants
# source("code/0_setup.R")
# 
# # Read in test data and reorder shapefiles
# shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
# shapes <- chmMatch(path_test_data_chm, shapes)
# chms <- map(dir(path_test_data_chm), function(x) rast(paste0(path_test_data_chm, x)))
# 







# This script is to define functions needed to extract
# structural metrics from the clipped and normalised NLP data.

# Functions ---- #!
# Function to match the order of polygons and chms
chmMatch <- function(chmDir, Shapes){
  Files <- dir(chmDir) # Find files in the folder
  chmIds <- as.numeric(gsub("\\.tif$", "", Files)) # Remove file name extensions and turn numeric
  shapes_reordered <- Shapes[match(chmIds, Shapes$ID),]
  return(shapes_reordered)
}

# Gap fraction function
# This function takes a point cloud and turns it into a shapefile denoting forest gaps
# The function returns an sf object

# LiDAR is the point cloud
# Shape is the corresponding SF object for the point cloud
gapsToDF <- function(chm, Shape){
  # Shape <- shapes[2,]
  # chm <- chms[[1]]
  # gapHeight <- gapHeight
  # gapSize <- 5
  # Gap detection algorithm based on max height within gaps and a minimal surface area
  gapSF <- gap_detection(chm,
                         res = 1,
                         gap_max_height = gapHeight,
                         min_gap_surface = gapSize)
  
  # Areas external to the woodland are considered gaps to fill out raster
  # These areas are removed below
  gapMask <- mask(gapSF, buffer(vect(Shape), -1.5))# remove external area by masking by nc site
  # Identify where this area protruded to count gaps smaller than our minimum surface
  freqs <- freq(gapMask[[1]])
  freqsSubset <- freqs[freqs$count >= gapSize, ]
  validGaps <- unique(freqsSubset$value)
  
  # Convert gaps to a shapefile for further analysis
  gapMaskShape <- as.polygons(gapMask[[1]]) |> st_as_sf()
  # Remove small gaps using the earlier freqs subset
  gaps <- filter(gapMaskShape, gap_id %in% validGaps)
  
  return(gaps)
}

# Effective canopy layer function----#!
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
