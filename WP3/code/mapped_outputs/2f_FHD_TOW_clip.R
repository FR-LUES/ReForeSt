source("WP3/code/mapped_outputs/0_setup_gaps.R")
source("WP3/code/mapped_outputs/1_functions.R")

# load in FHD data
fhd <- rast(paste0(path_fhd, "fhd_england_2020_30m.tif"))


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
  
  path_out <- paste0(path_fhd, "TOW_mask/fhd_TOW_", region, ".tif")
  writeRaster(fhd_tow, path_out)
  
  rm(tow); gc()
}


# mosaic
files <- list.files(paste0(path_fhd, "TOW_mask/"), pattern = "\\.tif$", full.names = TRUE)

fhd_tow_full_vrt <- vrt(files,
                        paste0(path_fhd, "TOW_mask/fhd_england_TOW_2020_30m.vrt"),
                        overwrite = TRUE)

writeRaster(fhd_tow_full_vrt,
            paste0(path_fhd, "fhd_england_TOW_2020_30m.tif"),
            overwrite = TRUE)



# merge NFI and TOW maps

fhd_nfi <- rast(paste0(path_fhd, "fhd_england_NFI_2020_30m.tif"))
fhd_tow <- rast(paste0(path_fhd, "fhd_england_TOW_2020_30m.tif"))

fhd_nfi_tow <- terra::merge(fhd_nfi, fhd_tow)


writeRaster(fhd_nfi_tow,
            paste0(path_fhd, "fhd_england_NFI_TOW_2020_30m.tif"),
            overwrite = TRUE)
