source("code/0_setup.R")
source("code/1_Functions.R")

# Clean and tidy data ---- !# 
# Read in shapefiles 
shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
# Read in chms
chms <- map(dir(path_test_data_chm), function(x)
                                      rast(paste0(path_test_data_chm, x)))
# Order shapes to match chms
shapes <- chmMatch(path_test_data_chm, shapes)
# Define range list for map functions
chmRange <- seq(1:length(chms))



# ---- !# Extract site level Top height diversity metric
siteTHD <- map(chmRange, .f = function(x) effCanopyLayer(chms[[x]],
                                                         shapes[x,],
                                                         strata = strata))



# Gridded effective canopy layer rasters
# Create thd rasters
# 30 m 
effCan30M <- map(chmRange, .f = function(x) zonal_effCanopyLayer(chms[[x]],
                                                                 shapes[x,],
                                                                 res = 30,
                                                                 strata = strata))
# 10 m
effCan10M <- map(chmRange, .f = function(x) zonal_effCanopyLayer(chms[[x]],
                                                                   shapes[x,],
                                                                   res = 10,
                                                                   strata = strata))

# Save rasters in outputs
# 30 m
map(chmRange, .f = function(x) writeRaster(effCan30M[[x]],
                                                 filetype = "Gtiff",
                                                 paste0(path_outputs,
                                                        "effectiveCanopyRasters_30mRes/",
                                                        shapes[x,]$ID,".tif")))
# 10 m
map(chmRange, .f = function(x) writeRaster(thd10M[[x]],
                                                   filetype = "Gtiff",
                                                   paste0(path_outputs,
                                                          "effectiveCanopyRasters_10mRes/",
                                                          shapes[x,]$ID, ".tif")))

