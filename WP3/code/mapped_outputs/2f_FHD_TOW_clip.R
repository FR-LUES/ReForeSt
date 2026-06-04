source("WP3/code/mapped_outputs/0_setup_gaps.R")
source("WP3/code/mapped_outputs/1_functions.R")

# load in FHD data
fhd <- rast("Z:/Projects/FRD_Programme/FRD_20 ReForeSt/02_data/01_processed_data/fhd_map/fhd_england_2020_30m.tif")


# Loop through TOW regions
tow_regions <- c(
  "East_Midlands",
  "Eastern",
  "London",
  "North_East",
  "North_West",
  "South_East",
  "South_West",
  "West_Midlands",
  "Yorkshire_and_the_Humber"
)

for (region in tow_regions) {
  
  path_in <- paste0("Z:/Common/TOW/TOW_v2/", region, "_TOW_V5.gpkg")
  tow <- vect(path_in)
  
  fhd_tow <- terra::mask(fhd, tow)
  
  path_out <- paste0(path_Z_proc_data, "fhd_map/TOW_mask/fhd_TOW_", region, ".tif")
  writeRaster(fhd_tow, path_out)
  
  rm(tow); gc()
}


# mosaic
files <- list.files(paste0(path_Z_proc_data, "fhd_map/TOW_mask/"), pattern = "\\.tif$", full.names = TRUE)

fhd_tow_full_vrt <- vrt(files,
                        paste0(path_Z_proc_data, "fhd_map/TOW_mask/fhd_england_TOW_2020_30m.vrt"),
                        overwrite = TRUE)

writeRaster(fhd_tow_full_vrt,
            paste0(path_Z_proc_data, "fhd_map/fhd_england_TOW_2020_30m.tif"),
            overwrite = TRUE)
