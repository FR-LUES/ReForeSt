# Preamble ---- !#
source("code/0_setup.R")
source("code/1_Functions.R")

# This script is to inspect within site variations in point densities to inspect potential sources of bias

# Load in data ---- !#
clipped <- readLAScatalog(path_test_lasClipped)# Read in LiDAR data
# read in shapefiles
shapes <- st_read(paste0(path_test_data_shp, "testShapes_buffered.gpkg"))
# Reclip to order
clipped <- clip_roi(clipped, shapes)





# Create Rasters for inspection ---- !# 
# Create density rasters at 1 m resolution
density_rasters <- map(clipped, ~ grid_density(.x, res = 3))
# Plot density rasters
map(density_rasters, ~ plot(.x))
