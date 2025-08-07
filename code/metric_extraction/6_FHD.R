# This script takes normalised point clouds and calculates the effective number of canopy stories. Including sub canopy layers. 
# These stories are calculated using predefined stratification.


# Now run in execution script ---- !#
# Preamble
# source("code/0_setup.R")
# source("code/1_Functions.R")
# # Load in data ---- !#
#clipped <- readLAScatalog(path_test_data_lasNormalised)# Read in LiDAR data
# # read in shapefiles
#shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
# ---- !#


Normalized <- clip_roi(pointsNormalized, shapes)

# Define range list for map functions
clipRange <- seq(1:length(clipped))
clipRange <- seq(1:length(Normalized))





# Extract site level canopy layering ---- !# 
siteLayers <- map(clipRange, .f = function(x) canopyEntropy(Normalized[[x]]@data$Z,
                                                            strata = strata) |> round(2))



# extract gridded effective canopy layers at 30 m resolution ---- !#
# Create the rasters
# 30 m 
effLayers30M <- map(clipRange, .f = function(x) pixel_metrics(Normalized[[x]],
                                                              func = ~canopyEntropy(Z, strata),
                                                              res = 30))
# 10 m
effLayers10M <- map(clipRange, .f = function(x) pixel_metrics(Normalized[[x]],
                                                              func = ~canopyEntropy(Z, strata),
                                                              res = 10))

# Save rasters in outputs
# 30 m
map(clipRange, .f = function(x) writeRaster(effLayers30M[[x]],
                                           filetype = "Gtiff",
                                           paste0(path_outputs,
                                                  "effectiveStoryRasters_30mRes/",
                                                  shapes[x,]$ID,".tif"),
                                           overwrite = TRUE))
# 10 m
map(clipRange, .f = function(x) writeRaster(effLayers10M[[x]],
                                           filetype = "Gtiff",
                                           paste0(path_outputs,
                                                  "effectiveStoryRasters_10mRes/",
                                                  shapes[x,]$ID, ".tif"),
                                           overwrite = TRUE))


# Extract and save numerical data ---- !#
# Site IDs
siteID <- shapes$ID
# mean and sd 10 m res gridded effective number of canopy layers
mean10mEffStor <- map(clipRange, function(x) mean(values(effLayers10M[[x]]), na.rm = TRUE) |> round(2))
sd10mEffStor <- map(clipRange, function(x) sd(values(effLayers10M[[x]]), na.rm = TRUE) |> round(2))
# mean and sd 30 m res gridded effective number of canopy layers
mean30mEffStor <- map(clipRange, function(x) mean(values(effLayers30M[[x]]), na.rm = TRUE) |> round(2))
sd30mEffStor <- map(clipRange, function(x) sd(values(effLayers30M[[x]]), na.rm = TRUE) |> round(2))
# Join as dataframe and save
effStorDF <- data.frame(ID = siteID, siteEffStories = unlist(siteLayers),
                       mean10mEffStories = unlist(mean10mEffStor), sd10mEffStories = unlist(sd10mEffStor),
                       mean30mEffStories = unlist(mean30mEffStor), sd30mEffStories = unlist(sd30mEffStor))

write.csv(effStorDF, paste0(path_outputs_effStory, "effectiveStory_layers.csv"))

