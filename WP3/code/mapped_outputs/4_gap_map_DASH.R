source("WP3/code/mapped_outputs/0_setup_gaps.R")
source("WP3/code/mapped_outputs/1_functions.R")

# Read in NFI and filter
nfi <- vect(path_NFI_DASH, layer = "NFI2020_Interim_v1_WoodlandMap") %>%
  filter(!IFT_IOA %in% c("Cloud \\ shadow", "Uncertain"))


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

    # Mask OS VOM by NFI (woodland only)
    nfiTile <- crop(nfi, ext(OS_VOM))
    vomForest <- mask(OS_VOM, nfiTile)

    # Generate 1km tiles for this 10km VOM raster
    tiles <- rast(extent = ext(OS_VOM),
                  resolution = 1000,
                  crs = crs(OS_VOM)) |>
    as.polygons() 

    gap_list <- list()

    for(k in 1:nrow(tiles)) {
      
      # Identify gaps in 1km tiles
      gaps_k <- process_tile(
        rast_full = vomForest,
        tile_sf   = tiles[k,],
        gapMask = nfiTile,
        bufferVal = 20)  

      gap_list[[k]] <- gaps_k
    }

    # Mosaic 1km tiles to 10km tile
    gaps_OS_10km <- do.call(mosaic, gap_list)
  
    # Export gap raster for 10km tile
    exportFilename <- paste0(OS_grid_10km, "_VOM_gaps.tif")
    exportFolder <- paste0(path_export_10km_DASH, OS_grid_100km, "/")
    exportPath <- paste0(exportFolder, exportFilename) # DASH path
    dir.create(exportFolder, recursive = T, showWarnings = F)

    # Use a local path for writing
    localPath <- paste0("/tmp/", exportFilename)
    writeRaster(gaps_OS_10km, localPath, overwrite = T)

    # Copy to DBFS
    file.copy(localPath, exportPath)
    file.remove(localPath)
    
    cat("Processed VOM tile for", OS_grid_10km, "\n")

    gc()
  }
}