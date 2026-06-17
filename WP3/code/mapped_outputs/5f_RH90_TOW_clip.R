source("WP3/code/mapped_outputs/0_setup.R")
source("WP3/code/mapped_outputs/1_functions.R")

# load in rh90 data
rh90 <- rast(path_rh90)


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
  
  rh90_tow <- terra::crop(rh90, tow, mask = TRUE)
  
  path_out <- paste0(dir_rh90, "TOW_mask/rh90_TOW_", region, ".tif")
  
  writeRaster(rh90_tow,
              path_out,
              overwrite = TRUE)
  
  rm(tow); gc()
}


# mosaic
files <-
  list.files(
    paste0(dir_rh90, "TOW_mask/"),
    pattern = "\\.tif$",
    full.names = TRUE)

rh90_tow_full_vrt <- 
  vrt(files,
      paste0(dir_rh90, "TOW_mask/rh90_england_TOW_2020_30m.vrt"),
      overwrite = TRUE)

writeRaster(rh90_tow_full_vrt,
            path_rh90_TOW,
            overwrite = TRUE)


# merge NFI and TOW maps

rh90_nfi <- rast(path_rh90_NFI)
rh90_tow <- rast(path_rh90_TOW)

rh90_nfi_tow <- terra::merge(rh90_nfi, rh90_tow)


writeRaster(rh90_nfi_tow,
            path_rh90_NFI_TOW,
            overwrite = TRUE)
