#testLAS <- readLAS(tileFiles[[3]][1000])

# FHD here is defined as the effective number of canopy layers - the exponent of shannon's eveness.
# This is calculated for the whole of england as its quicker than clipping las files to woodlands.
# Entropy function to operate at varying resolutions
fhdFunction<- function(cloud, strata){# Cloud is a vector of heights
  
  #centroid <- st_centroid(ctg@data) |> st_buffer(100)
  #cloudFull <- clip_roi(ctg, centroid)
  #cloud <- normalized_chunk@data$Z
  #cloud <- Normalized_gaps[[2]]@data$Z
  # Calculate the LAD profile of the height vector
  ladDF <- LAD(cloud, dz = 1, z0 = 1)
  
  # Filter out any NA or zero LAD values to avoid log(0)
  ladDF <- ladDF[ladDF$lad > 0, ]
  
  if(nrow(ladDF) == 0){
    return(0)} else{
    # Bin heights into strata
    ladDF$stratum <- cut(
      ladDF$z,
      breaks = strata,
      include.lowest = TRUE,
      right = FALSE
    )
    
    # Aggregate LAD within each stratum
    aggLAD <- ladDF |> group_by(stratum) |>
      summarise(lad = mean(lad))
    
    # Proportional LAD in each layer
    aggLAD$prop <- aggLAD$lad / sum(aggLAD$lad)
    
    # Shannon entropy
    H <- -sum(aggLAD$prop * log(aggLAD$prop))
    
    Hexp <- exp(H) |> round(2)
    return(Hexp)
  }
}




# This function will map the FHD function across a las catalog using catalog_map
fhdMap_function <- function(chunk) {
  # Define a global log file path (you can change this)
  log_file <- "tile_processing_log.txt"
  #chunk <- testLAS
  # Helper function for logging
  log_msg <- function(...) {
    msg <- paste0("[", Sys.time(), "] ", paste(..., collapse = ""), "\n")
    cat(msg, file = log_file, append = TRUE)
  }
  
  # ---- Start processing ----
  tile_name <- chunk@header$`File Source ID`
  log_msg("Starting: ", tile_name)
  
  if (is.empty(chunk)) {
    log_msg("Skipping empty tile: ", tile_name)
    return(NULL)
  }
  
  
  # Count ground points (ASPRS class 2)
  n_ground <- sum(chunk@data$Classification == 2, na.rm = TRUE)
  log_msg("Ground points in ", tile_name, ": ", n_ground)
  if (n_ground < 50) {
    log_msg("Too few ground points, skipping: ", tile_name)
    return(NULL)
  }
  
  # DTM and normalization
  dtm <- rasterize_terrain(chunk, res = 5, algorithm = tin())
  log_msg("DTM generated for ", tile_name)
  
  normalized_chunk <- chunk - dtm 
  log_msg("Normalization done for ", tile_name)
  
  # Compute FHD
  fhdRast <- pixel_metrics(normalized_chunk, ~fhdFunction(Z, strata), res = 30)
  log_msg("FHD raster created for ", tile_name)
  
  # Clean up and finish
  gc()
  log_msg("Completed: ", tile_name)
  
  return(fhdRast)
  }










# Mosaicing functions ---- !#
# This function will reference every .tif file in a directory, merge them, and save the merge to file

mosaicFunction <- function(directory, outPath, x) {# X is an index to be used inside a loop for referencing years.
  # directory <- paste0(years[[x]], "/")
  # outPath <- paste0(fhdOutPath, yearNames[[x]])
  
  # Remove problem tiles
  sources <- list.files(paste0(directory), pattern = "\\.tif$", full.names = TRUE)
  
  # find bad sources
  bad <- sapply(sources, function(f) {
    print(f)
    tryCatch({ r <- rast(f); ncell(r) == 0 }, error = function(e) TRUE)
  })
  
  # Create VRT with only good tiles
  vrt <- vrt(sources[!bad], paste0(years[[x]], "/", yearNames[[x]], ".vrt"), overwrite = TRUE)
  
  
  writeRaster(vrt, paste0(outPath, "_FULL", ".tif"), overwrite = TRUE)
}













# Gaps functions ---- !#

  
# chm is the canopy height model
# Shape is the corresponding SF object for the chm
gapsToRast <- function(chm, Shape){
  
   # chm <- rast_chunk
   # Shape <- nfiTile
  # Gap detection algorithm based on max height within gaps and a minimal surface area
  gapSF <- gap_detection(chm,
                         res = 1,
                         gap_max_height = gapHeight,
                         min_gap_surface = gapSize)
  
  # Areas external to the woodland are considered gaps to fill out raster
  # These areas are removed below
  masker <- mask(gapSF, buffer(Shape, -1.5))# remove external area by masking by site
  # Identify where this area protruded to count gaps smaller than our minimum surface
  freqs <- freq(masker[[1]])
  freqsSubset <- freqs[freqs$count >= gapSize, ]
  validGaps <- unique(freqsSubset$value)
  
  # Remove small gaps using the earlier freqs subset
  gaps <- tidyterra::filter(masker, gap_id %in% validGaps)
  
  return(gaps)
}





# Function to process gap detection in tiles
process_tile <- function(rast_full, tile_sf, bufferVal, gapMask) {
   # rast_full = vomForest
   # tile_sf   = tiles[k,]
   # gapMask = nfiTile
   # bufferVal = 20
  # Unbuffered tile extent
  
  buff_ext <- buffer(tile_sf, bufferVal)
  
  
  # Crop buffered raster
  rast_chunk <- crop(rast_full, buff_ext)
  
  if (is.null(rast_chunk)) return(NULL)
  
  # Run your existing gap logic
  gaps_chunk <- gapsToRast(rast_chunk, gapMask)
  gaps_chunk <- gaps_chunk$gap_id
  # Clip gap polygons back to original (unbuffered) tile extent
  gaps_clean <- crop(gaps_chunk, ext(tile_sf))
  
  # make gaps binary
  gaps_clean <- classify(gaps_clean, rcl <- matrix(c(
    -Inf, 0.05, 0,
    0.05, Inf, 1
  ), ncol = 3, byrow = TRUE))
  plot(gaps_clean)
  return(gaps_clean)
}
