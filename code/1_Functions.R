 
 shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
 lid <- readLAScatalog(path_test_data_las)
 lid <- clip_roi(lid, shapes)
# This script is to define functions needed to extract Structural metrics from the clipped and normalised NLP data.

# Read in constants----#!

# Functions ----#!
# Gap fraction function
# This function takes a point cloud and turns it into a shapefile denoting forest gaps
# The function returns an sf object
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

