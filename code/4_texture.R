# Preamble ---- !#
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


# Extract text metrics ---- !#
textMetrics <- map_dfr(chmRange, function(x) {
  return(chmTexture(chms[[x]], shapes[x,]))
}
)
# Round texture metrics
textMetricsRound <- textMetrics |> round(2)
# Attach metrics to site ID
textureMetrics_df <- cbind(ID = shapes$ID, textMetricsRound)
# Save metrics
write.csv(textureMetrics_df, paste0(path_outputs_texture, "textureMetrics.csv"))


