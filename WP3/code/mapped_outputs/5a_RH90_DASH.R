OS_folders_100km <- list.dirs(path_Vom_DASH, recursive = F, full.names = F)


# Loop over 100km tiles
for (i in 1:length(OS_folders_100km)) {
  
OS_grid_100km <- OS_folders_100km[[i]]
OS_folders_10km <- list.dirs(paste0(path_Vom_DASH, OS_grid_100km), recursive = F, full.names = F)

  # Loop over 10km sub-tiles
  for (j in 1:length(OS_folders_10km)) {
  
    OS_grid_10km <- OS_folders_10km[[j]]
  
    # Build VOM for OS 10km grid square 
    tiles_paths <- list.files(path = paste0(path_Vom_DASH, OS_grid_100km, "/" ,OS_grid_10km),
                              pattern = ".tif$",
                              recursive = T,
                              full.names = T)

    if (length(tiles_paths) == 0) {
      cat("No .tif files found for", OS_grid_10km, "- skipping.\n")
      next
    }

    tiles_VOM <- lapply(tiles_paths, rast)

    if (length(tiles_paths) == 1) {
      OS_VOM <- rast(tiles_VOM)
    } else {
      OS_VOM <- do.call(mosaic, tiles_VOM)
    }

    OS_VOM_30m_rh90 <-
        terra::aggregate(
            OS_VOM,
            fact = 30,
            fun = function(x, na.rm = TRUE) {
                quantile(x, 0.9, na.rm = na.rm)},
            na.rm = TRUE
        )

    # Export rh90 raster for 10km tile
    exportFilename <- paste0(OS_grid_10km, "_VOM_rh90.tif")
    exportFolder <- paste0(path_rh90_tiles_DASH, OS_grid_100km, "/")
    exportPath <- paste0(exportFolder, exportFilename) # DASH path
    dir.create(exportFolder, recursive = T, showWarnings = F)

    # Use a local path for writing
    localPath <- paste0("/tmp/", exportFilename)
    writeRaster(OS_VOM_30m_rh90, localPath, overwrite = T)

    # Copy to DBFS
    file.copy(localPath, exportPath)
    file.remove(localPath)
    
    cat("Processed VOM tile for", OS_grid_10km, "\n")

    gc()
  }
}