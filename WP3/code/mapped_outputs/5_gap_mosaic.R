source("WP3/code/mapped_outputs/0_setup_gaps.R")
source("WP3/code/mapped_outputs/1_functions.R")

# Mosaic OS 100km tiles
tiles <- list.files("Z:/Projects/FRD_Programme/FRD_20 ReForeSt/gap_map/england_tiles/", pattern = "\\.tif$", full.names = TRUE)

# Create VRT and write
vrt <- vrt(tiles, paste0(path_export_eng, "england_VOM_gaps_clip.vrt"), overwrite = TRUE)
writeRaster(vrt, paste0(path_export_eng, "england_VOM_gaps_clip.tif"), overwrite = TRUE)