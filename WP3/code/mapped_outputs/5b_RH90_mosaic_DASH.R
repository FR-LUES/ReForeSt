# Locate RH90 tiles
RH90_tiles_paths <- list.files(path_rh90_tiles_DASH,
                      pattern = "\\.tif$",
                      full.names = TRUE,
                      recursive = TRUE)

# Load in rasters and convert to SpatRasterCollection
RH90_tiles <- lapply(RH90_tiles_paths, rast)
RH90_tiles_rc <- sprc(RH90_tiles)

# Mosaic rasters
RH90_mosaic <- mosaic(RH90_tiles_rc, fun = "mean", resample = TRUE)

# Export rh90 raster 
exportFilename <- "rh90_30m_VOM_partial.tif"
exportFolder <- path_rh90_eng_DASH
exportPath <- paste0(exportFolder, exportFilename) # DASH path
dir.create(exportFolder, recursive = T, showWarnings = F)

# Use a local path for writing
localPath <- paste0("/tmp/", exportFilename)
writeRaster(RH90_mosaic, localPath, overwrite = T)

# Copy to DBFS
file.copy(localPath, exportPath)
file.remove(localPath)