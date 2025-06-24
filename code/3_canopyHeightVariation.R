
# # Now run in exectution script ---- !#
# # Preamble ---- !#
# source("code/0_setup.R")
# source("code/1_Functions.R")
# 
# 
# 
# 
# # Clean and tidy data ---- !# 
# # Read in shapefiles 
# shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
# # Read in chms
# chms <- map(dir(path_test_data_chm), function(x)
#                                       rast(paste0(path_test_data_chm, x)))
# # Order shapes to match chms
# shapes <- chmMatch(path_test_data_chm, shapes)
# # ---- !#


# Define range list for map functions
chmRange <- seq(1:length(chms))



# Extract site level Top height diversity metric ---- !# 
siteEffCan <- map(chmRange, .f = function(x) effCanopyLayer(chms[[x]],
                                                         shapes[x,],
                                                         strata = strata) |> round(2))



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
map(chmRange, .f = function(x) writeRaster(effCan10M[[x]],
                                                   filetype = "Gtiff",
                                                   paste0(path_outputs,
                                                          "effectiveCanopyRasters_10mRes/",
                                                          shapes[x,]$ID, ".tif")))


# Extract and save numerical data ---- !#
# Site IDs
siteID <- shapes$ID
# mean and sd 10 m res gridded effective number of canopy layers
mean10mEffCan <- map(chmRange, function(x) mean(values(effCan10M[[x]]), na.rm = TRUE) |> round(2))
sd10mEffCan <- map(chmRange, function(x) sd(values(effCan10M[[x]]), na.rm = TRUE) |> round(2))
# mean and sd 30 m res gridded effective number of canopy layers
mean30mEffCan <- map(chmRange, function(x) mean(values(effCan30M[[x]]), na.rm = TRUE) |> round(2))
sd30mEffCan <- map(chmRange, function(x) sd(values(effCan30M[[x]]), na.rm = TRUE) |> round(2))
# Join as dataframe and save
effCanDF <- data.frame(ID = siteID, siteEffCan = unlist(siteEffCan),
                        mean10mEffCan = unlist(mean10mEffCan), sd10mEffCan = unlist(sd10mEffCan),
                        mean30mEffCan = unlist(mean30mEffCan), sd30mEffCan = unlist(sd30mEffCan))

write.csv(effCanDF, paste0(path_outputs_effCan, "effectiveCanopy_layers.csv"))
