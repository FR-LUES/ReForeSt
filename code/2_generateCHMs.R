source("code/0_setup.R")
source("code/1_Functions.R")


# ---- !# Clean and tidy data
# Read in shapefiles 
shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
# Read in LiDAR
lid <- readLAScatalog(paste0(path_test_data_las))
# Clip las catalog to the shape files so everything is in the same order
lidClip <- clip_roi(lid, shapes)

# Generate chms ---- !#
chms <- map(1:length(lidClip), .f = function(x) chmFunction(lidClip[[x]], 2))
x <- 1
# Save chms to file
map(1:length(chms), .f = function(x) writeRaster(chms[[x]], filetype = "Gtiff", filename = paste0(path_outputs,
                                                                                "chmRasters/",
                                                                                shapes[x,]$ID, ".tif")))


