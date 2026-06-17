# script to reassemble gap map on FR Virtual Machine following export of tiles from DASH

source("WP3/code/mapped_outputs/0_setup.R")
source("WP3/code/mapped_outputs/1_functions.R")


# Mask Fylingdales area from NZ, SE and TA tiles
path_fyl <- paste0(path_gap_map_fyl, "fylingdales_VOM_gaps.tif")
fyl <- rast(path_fyl)
fyl_ext <- ext(fyl) %>% as.polygons()
crs(fyl_ext) <- crs(fyl)

for (t in c("NZ", "SE", "TA")) {
  
  file <- paste0(path_gap_map_100km, t, "_VOM_gaps.tif")
  r <- rast(file)
  r_mask <- mask(r, fyl_ext, inverse = TRUE)
  
  writeRaster(r_mask, file, overwrite = TRUE)
}


# Mosaic OS 100km and Fylingdales tiles
tiles <- list.files(path_gap_map_100km, pattern = "\\.tif$", full.names = TRUE)
tiles <- append(tiles, path_fyl)


# Create VRT and write
vrt <- vrt(tiles, paste0(path_gap_map_eng, "gap_map_1m.vrt"), overwrite = TRUE)
writeRaster(vrt, paste0(path_gap_map_eng, "gap_map_1m.tif"), overwrite = TRUE)
