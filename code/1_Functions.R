# This script is to define functions needed to extract Structural metrics from the clipped and normalised NLP data.

# Functions ----#!
# Gap fraction function ----#
# This function takes a point cloud and turns it into a shapefile denoting forest gaps
# The function returns an sf object

# LiDAR is the point cloud
# Shape is the corresponsing SF object for the point cloud
gapsToDF <- function(LiDAR, Shape){
  
  # Gap detection algorithm based on max height within gaps and a minimal surface area
  gapSF <- gap_detection(LiDAR,
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
# This function takes a vector of height values and bins them into user defined height bins
# It then calculates Shannon's diversity index as if each bin was a species
# The frequency within each bin is a species richness

# Height vector is a vector of height values
# Strata is user defined heigh bins
effCanopyLayer <- function(heightVector, strata){
  #heightVector <- lid[[1]]@data$Z
  #strata <- c(0, 2, 10, 15, 30, 50)
  # Remove erroneous negative values
  heights <- heightVector[heightVector >= 0]
  print(paste0(length(heightVector) - length(heights), " Negative values removed"))
  
  # Bin Heights into stratas
  bins <- cut(heights, strata, labels = FALSE, include.lowest = TRUE)
  # find frequency of values in each bin
  freqs <- table(factor(bins, levels = 1:length(strata)-1))
  
  # Calculate effective canopy layers
  total_values <- sum(freqs)
  proportions <- freqs/total_values |> round(3)
  shannon_index <- sum(proportions * log(proportions), na.rm = TRUE)
  effectiveCanopyLayers <- exp(shannon_index)
  return(effectiveCanopyLayers)
  
}