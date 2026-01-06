# List 100km tiles
OS_folders_100km <- list.dirs(path_export_10km_DASH, recursive = F, full.names = F)

# Mosaic each OS 100km tile
map(1:length(OS_folders_100km), .f = function(x) {
  
  mosaicFunction_DASH(paste0(path_export_10km_DASH, OS_folders_100km[[x]]),
                      path_export_100km_DASH,
                      paste0(OS_folders_100km[[x]], "_VOM_gaps"))
  }

)

# Mosaic OS 100km tiles to England
mosaicFunction_DASH(path_export_100km_DASH,
                    path_export_eng_DASH,
                    "england_VOM_gaps")


# Clip to England
england <- vect("/dbfs/mnt/base/unrestricted/source_ordnance_survey_data_hub/dataset_boundary_line/format_SHP_boundary_line/SNAPSHOT_2025_10_02_boundary_line/GB/english_region_region.shp") %>% terra::aggregate() 
england_VOM_gaps <- rast(paste0(path_export_eng_DASH, "england_VOM_gaps.tif"))
england_VOM_gaps_clip <- mask(england_VOM_gaps, england)

# Use a local path for writing
localPath <- "/tmp/england_VOM_gaps_clip.tif"
writeRaster(england_VOM_gaps_clip, localPath, overwrite = T)

# Copy to DBFS
file.copy(localPath, paste0(path_export_eng_DASH, "england_VOM_gaps_clip.tif"))
file.remove(localPath)