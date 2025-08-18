# This script takes normalised point clouds and calculates the effective number of canopy stories. Including sub canopy layers. 
# The script calculates this metric for both point clouds including gaps and not including gaps.
# These stories are calculated using predefined stratification.


# Now run in execution script ---- !#
# Preamble
# source("code/0_setup.R")
# source("code/1_Functions.R")
# # Load in data ---- !#
#Normalized <- readLAScatalog(path_test_data_lasNormalised)# Read in LiDAR data
# # read in shapefiles
#shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
# Read in chms
#chms <- map(dir(path_test_data_chm), function(x) rast(paste0(path_test_data_chm, x)))
# Order shapes to match chms
#shapes <- chmMatch(path_test_data_chm, shapes)







# ---- !#
# Clip point clouds to forest shapes
Normalized_gaps <- clip_roi(pointsNormalized, shapes)

# Define range list for map functions
clipRange <- seq(1:length(Normalized_gaps))

# remove gaps from forests to calculate metrics without gaps
shapesGapless <- map(clipRange, .f = function(x) gap_clip(shapes[x,], chms[[x]]))
shapesGapless <- do.call(rbind, shapesGapless) |> st_as_sf()

# Extract point clouds without gaps
Normalized_gapless <- clip_roi(pointsNormalized, shapesGapless)







# Exract FHD metrics including gaps
# Extract site level canopy layering ---- !# 
siteLayers_gaps <- map(clipRange, .f = function(x) canopyEntropy(Normalized_gaps[[x]]@data$Z,
                                                            strata = strata) |> round(2))



# extract gridded effective canopy layers at 30 m resolution ---- !#
# Create the rasters
# 30 m 
effLayers30M_gaps <- map(clipRange, .f = function(x) pixel_metrics(Normalized_gaps[[x]],
                                                              func = ~canopyEntropy(Z, strata),
                                                              res = 30))
# 10 m
effLayers10M_gaps <- map(clipRange, .f = function(x) pixel_metrics(Normalized_gaps[[x]],
                                                              func = ~canopyEntropy(Z, strata),
                                                              res = 10))

# Save rasters in outputs
# 30 m
map(clipRange, .f = function(x) writeRaster(effLayers30M_gaps[[x]],
                                           filetype = "Gtiff",
                                           paste0(path_outputs,
                                                  "effectiveStoryRasters_30mRes_wGaps/",
                                                  shapes[x,]$ID,".tif"),
                                           overwrite = TRUE))
# 10 m
map(clipRange, .f = function(x) writeRaster(effLayers10M_gaps[[x]],
                                           filetype = "Gtiff",
                                           paste0(path_outputs,
                                                  "effectiveStoryRasters_10mRes_WGaps/",
                                                  shapes[x,]$ID, ".tif"),
                                           overwrite = TRUE))








# Extract FHD metrics without gaps ---- !#
# Extract site level canopy layering ---- !# 
siteLayers_gapless <- map(clipRange, .f = function(x) canopyEntropy(Normalized_gapless[[x]]@data$Z,
                                                                 strata = strata) |> round(2))



# extract gridded effective canopy layers at 30 m resolution ---- !#
# Create the rasters
# 30 m 
effLayers30M_gapless <- map(clipRange, .f = function(x) pixel_metrics(Normalized_gapless[[x]],
                                                                   func = ~canopyEntropy(Z, strata),
                                                                   res = 30))
# 10 m
effLayers10M_gapless <- map(clipRange, .f = function(x) pixel_metrics(Normalized_gapless[[x]],
                                                                   func = ~canopyEntropy(Z, strata),
                                                                   res = 10))

# Save rasters in outputs
# 30 m
map(clipRange, .f = function(x) writeRaster(effLayers30M_gapless[[x]],
                                            filetype = "Gtiff",
                                            paste0(path_outputs,
                                                   "effectiveStoryRasters_30mRes_gapless/",
                                                   shapes[x,]$ID,".tif"),
                                            overwrite = TRUE))
# 10 m
map(clipRange, .f = function(x) writeRaster(effLayers10M_gaps[[x]],
                                            filetype = "Gtiff",
                                            paste0(path_outputs,
                                                   "effectiveStoryRasters_10mRes_gapless/",
                                                   shapes[x,]$ID, ".tif"),
                                            overwrite = TRUE))




# Extract and save numerical data ---- !#
# Site IDs
siteID <- shapes$ID
# mean and sd 10 m res gridded effective number of canopy layers
mean10mFHD_Gaps <- map(clipRange, function(x) mean(values(effLayers10M_gaps[[x]]), na.rm = TRUE) |> round(2))# w/Gaps
sd10mFHD_Gaps <- map(clipRange, function(x) sd(values(effLayers10M_gaps[[x]]), na.rm = TRUE) |> round(2))
mean10mFHD_Gapless <- map(clipRange, function(x) mean(values(effLayers10M_gapless[[x]]), na.rm = TRUE) |> round(2))# Gapless
sd10mFHD_Gapless <- map(clipRange, function(x) sd(values(effLayers10M_gapless[[x]]), na.rm = TRUE) |> round(2))

# mean and sd 30 m res gridded effective number of canopy layers
mean30mFHD_Gaps <- map(clipRange, function(x) mean(values(effLayers30M_gaps[[x]]), na.rm = TRUE) |> round(2))# w/Gaps
sd30mFHD_Gaps <- map(clipRange, function(x) sd(values(effLayers30M_gaps[[x]]), na.rm = TRUE) |> round(2))
mean30mFHD_Gapless <- map(clipRange, function(x) mean(values(effLayers30M_gapless[[x]]), na.rm = TRUE) |> round(2))# Gapless
sd30mFHD_Gapless <- map(clipRange, function(x) sd(values(effLayers30M_gapless[[x]]), na.rm = TRUE) |> round(2))

# Join as dataframe and save
fhdDF <- data.frame(ID = siteID, 
                    siteFHD_gaps = unlist(siteLayers_gaps),
                    siteFHD_gapless = unlist(siteLayers_gapless),
                    mean10mFHD_gaps = unlist(mean10mFHD_Gaps), sd10mFHD_gaps = unlist(sd10mFHD_Gaps),
                    mean30mFHD_gaps = unlist(mean30mFHD_Gaps), sd30mFHD_gaps = unlist(sd30mFHD_Gaps),
                    mean10mFHD_gapless = unlist(mean10mFHD_Gapless), sd10mFHD_gapless = unlist(sd10mFHD_Gapless),
                    mean30mFHD_gapless = unlist(mean30mFHD_Gapless), sd30mFHD_gapless = unlist(sd30mFHD_Gapless))

write.csv(fhdDF, paste0(path_outputs_effStory, "effectiveStory_layers.csv"))

