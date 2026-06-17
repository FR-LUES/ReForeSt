# List 100km tiles
OS_folders_100km <- list.dirs(dir_gap_map_10km_DASH, recursive = F, full.names = F)

# Mosaic each OS 100km tile
map(1:length(OS_folders_100km), .f = function(x) {
  
  mosaicFunction_DASH(paste0(dir_gap_map_10km_DASH, OS_folders_100km[[x]]),
                      dir_gap_map_100km_DASH,
                      paste0(OS_folders_100km[[x]], "_VOM_gaps"))
  }
)


# Mask Fylingdales area from NZ, SE and TA tiles
path_fyl <- paste0(dir_gap_map_fyl_DASH, "fylingdales_VOM_gaps.tif")
fyl <- rast(path_fyl)
fyl_ext <- ext(fyl) %>% as.polygons()
crs(fyl_ext) <- crs(fyl)

for (t in c("NZ", "SE", "TA")) {
  
  file <- paste0(dir_gap_map_100km_DASH, t, "_VOM_gaps.tif")
  r <- rast(file)
  r_mask <- mask(r, fyl_ext, inverse = TRUE)
  
  # Use a local path for writing
  localPath <- paste0("/tmp/", t, "_VOM_gaps.tif")
  writeRaster(r_mask, localPath, overwrite = TRUE)
  
  # Copy to DBFS
  file_out <- paste0(dir_gap_map_100km_DASH, t, "_VOM_gaps_clip.tif")
  file.copy(localPath, file_out, overwrite = TRUE)
  file.remove(localPath)
  print(t)
}


# Mosaic OS 100km and Fylingdales tiles
tiles <- list.files(dir_gap_map_100km_DASH, pattern = "\\.tif$", full.names = TRUE)
tiles <- append(tiles, path_fyl)

# remove NZ, SE and TA (unclipped)
remove_tiles <- c("/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/100km_mosaic//NZ_VOM_gaps.tif",
                  "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/100km_mosaic//SE_VOM_gaps.tif",
                  "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/100km_mosaic//TA_VOM_gaps.tif")
tiles <- tiles[!tiles %in% remove_tiles]


# Create VRT 
vrt <- vrt(tiles, paste0(dir_gap_map_eng_DASH, "gap_map_1m_preclip.vrt"), overwrite = TRUE)

# Use a local path for writing
localPath <- "/tmp/gap_map_1m_preclip.tif"
writeRaster(vrt, localPath, overwrite = TRUE)
  
# Copy to DBFS
file.copy(localPath, paste0(dir_gap_map_eng_DASH, "gap_map_1m_preclip.tif"), overwrite = TRUE)
file.remove(localPath)
  

# Clip to England
england <- vect(path_eng_DASH) %>% terra::aggregate() 
england_VOM_gaps <- rast(paste0(dir_gap_map_eng_DASH, "gap_map_1m_preclip.tif"))
england_VOM_gaps_clip <- mask(england_VOM_gaps, england)
names(england_VOM_gaps_clip) <- "gap_map_1m"

# Use a local path for writing
localPath <- "/tmp/gap_map_1m.tif"
writeRaster(england_VOM_gaps_clip, localPath, overwrite = TRUE)

# Copy to DBFS
file.copy(localPath, path_gap_map, overwrite = TRUE)
file.remove(localPath)
