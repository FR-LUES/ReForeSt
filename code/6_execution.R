# This script is to execute the entire processing pipeline
# It reads in the data needed for all scripts and then runs the preamble script followed by all metric extraction scripts
# Finally we combine all metrics into one dataframe

# Run preamble script and function script---- !#
source("code/0_setup.R")
source("code/1_Functions.R")
# Read in data for chm script ---- !#
clipped <- readLAScatalog(path_test_lasClipped)# Read in LiDAR data for the CHM script to process
shapes_buffered <- st_read(paste0(path_test_data_shp, "testShapes_buffered.gpkg"))# Read in buffered shapefiles for chm processing

# Run CHM script ---- !#
source("code/2_CHMS.R")


# Read in data for metric extraction scripts ---- !#
shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg")) # Read in non-buffered shapes for masking
chms <- map(dir(path_test_data_chm), function(x)
  rast(paste0(path_test_data_chm, x))) # read in CHMs created by chm script
shapes <- chmMatch(path_test_data_chm, shapes) # Order shapefiles to match chms

# Run metric extraction scripts ---- !#
source("code/3_canopyHeightVariation.R")
source("code/4_gap_analysis.R")
source("code/5_texture.R")


# Combine dataframe ---- !#
master_metrics_df <- effCanDF |> left_join(df_l_metrics_all, by = c("ID" = "site_id")) |>
  left_join(textureMetrics_df, by = "ID")
write_csv(master_metrics_df, paste0(path_outputs, "masterMetrics_df.csv"))
