# This script takes the NLP point clouds and generates canopy height models CHMs
# We will also create normalised point clouds

# Now run in execution script ---- !#
# Preamble
# source("code/0_setup.R")
# source("code/1_Functions.R")
# # Load in data ---- !#
# clipped <- readLAScatalog(path_test_lasClipped)# Read in LiDAR data
# # read in shapefiles
# shapes <- st_read(paste0(path_test_data_shp, "testShapes_buffered.gpkg"))
# ---- !#




# Reclip to order
clipped <- clip_roi(clipped, shapes_buffered)
names <- shapes_buffered$Site # names for saving later

# Create dtms ---- !#
dtms <- map(1:length(clipped),
            .f = function(x) 
              rasterize_terrain(clipped[[x]], res = 1,
                                algorithm = tin(),
                                shape = st_as_sfc(shapes_buffered[x,])))

# Create dsms ---- !#
dsms <- map(1:length(clipped),
            .f = function(x)
              rasterize_canopy(clipped[[x]], res = 1,
                               algorithm = dsmtin(),
                               shape = st_as_sfc(shapes_buffered[x,])))

# Create normalized point clouds ---- !#
pointsNormalized <- map(1:length(clipped), 
                        function(x)
                          clipped[[x]] - dtms[[x]])
map(1:length(pointsNormalized), function(x) writeLAS(pointsNormalized[[x]], paste0(path_test_data_lasNormalised, names[[x]], ".laz")))


# Create chms ---- !#
chms <- map(1:length(dtms), .f = function(x)
  dsms[[x]] - dtms[[x]])

# remove erroneous negative numbers
chmsCleaned <- map(1:length(chms), .f = function(x)
  classify(chms[[x]], rcl = matrix(c(-500, 0, 0),
                                   ncol = 3, byrow = TRUE)))
# Smooth to fill in gaps
chmsSmooth <- map(chmsCleaned, function(x)
  focal(x, w = 3, fun =  mean))

#save chms
map(1:length(chmsSmooth), .f = function(x) writeRaster(chmsSmooth[[x]], paste0(path_test_data_chm, names[[x]],".tif"), overwrite = TRUE))


