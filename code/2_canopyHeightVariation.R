source("code/0_setup.R")
source("code/1_Functions.R")

# ---- !# Clean and tidy data
# Read in shapefiles 
shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
# Read in LiDAR
lid <- readLAScatalog(paste0(path_test_data_las))
# Clip las catalog to the shape files so everything is in the same order
lidClip <- clip_roi(lid, shapes)

# ---- !# Extract site level Top height diversity metric
siteTHD <- map(1:nrow(shapes), .f = function(x) effCanopyLayer(lidClip[[x]]@data$Z, strata = strata))


# ---- !# Extract gridded THD metrics
# Define pixel metrics function
pixEff <- function(lidar, resolution)
  {thdRaster <- pixel_metrics(lidar,
                              func = effCanopyLayer(Z, strata = strata),
                              res = resolution)
return(thdRaster)}

# Create thd rasters
# 30 m 
thd30M <- map(lidClip, .f = function(x) pixEff(x, 30))
# 10 m
thd10M <- map(lidClip, .f = function(x) pixEff(x, 10))

# Save rasters in outputs
# 30 m
map(1:length(thd30M), .f = function(x) writeRaster(thd30M[[x]],
                                                 filetype = "Gtiff",
                                                 paste0(path_outputs,
                                                        "thd30mRasters/",
                                                        shapes[x,]$ID)))
# 10 m
map(1:length(thd10M), .f = function(x) writeRaster(thd10M[[x]],
                                                   filetype = "Gtiff",
                                                   paste0(path_outputs,
                                                          "thd10mRasters/",
                                                          shapes[x,]$ID)))

