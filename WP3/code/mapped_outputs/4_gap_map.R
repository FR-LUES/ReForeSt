source("WP3/code/mapped_outputs/0_setup_gaps.R")
source("WP3/code/mapped_outputs/1_functions.R")

# Read in data ---- !#
nfi <- vect(path_NFI, layer = "NFI2020_Interim_v1_WoodlandMap")
vomShapes <- vect(path_VOM_catalog)


gaps_all <- list()
for (i in seq_along(vomShapes$location)) {
  #i <- 10
  tileName <- vomShapes$location[[i]]
  vomTile  <- rast(paste0(path_Vom, tileName))
  
  # Mask VOM by NFI (woodland only)
  vomForest <- mask(vomTile, nfi)
  nfiTile <- crop(nfi, ext(vomTile))
  
  # Generate tiles for this VOM raster (e.g. 1000m × 1000m tiles)
  tiles <- rast(extent = ext(vomForest),
                             resolution = 1000,
                             crs = crs(vomForest)) |> as.polygons() 
  # list to store chunks from this tile
  gap_list <- list()
  
  for(k in seq(along = 1:nrow(tiles))) {
    cat("Processing tile", k, "of", nrow(tiles), "for VOM", i, "\n")
   #k <- 100
   # subset nfi to tile
   
   
    gaps_k <- process_tile(
      rast_full = vomForest,
      tile_sf   = tiles[k,],
      gapMask = nfiTile,
      bufferVal = 20
    )
    
    gap_list[[k]] <- gaps_k
  }
  
  # Merge all cleaned gaps per VOM tile
  gaps_all[[i]] <- do.call(rbind, gap_list)
  
  # Do something with gaps_all (save, export, etc.)
}
