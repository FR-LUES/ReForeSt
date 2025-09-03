

# FHD here is defined as the effective number of canopy layers - the exponent of shannon's eveness.
# This is calculated for the whole of england as its quicker than clipping las files to woodlands.
# Entropy function to operate at varying resolutions
fhdFunction<- function(cloud, strata){# Cloud is a vector of heights
  
  #cloud <- Normalized_gaps[[2]]@data$Z
  # Calculate the LAD profile of the height vector
  ladDF <- LAD(cloud, dz = 1, z0 = 1)
  
  # Filter out any NA or zero LAD values to avoid log(0)
  ladDF <- ladDF[ladDF$lad > 0, ]
  if(nrow(ladDF) == 0) {return(0)}# if there are no values then fhd is 0
  else{
    # Bin heights into strata
    ladDF$stratum <- cut(
      ladDF$z,
      breaks = strata,
      include.lowest = TRUE,
      right = FALSE
    )
    
    # Aggregate LAD within each stratum
    aggLAD <- ladDF |> group_by(stratum) |>
      summarise(lad = sum(lad))
    
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
  dtm <- rasterize_terrain(chunk, res = 1, algorithm = tin())
  normalized_chunk <- chunk - dtm
  fhdRast <- pixel_metrics(chunk, ~fhdFunction(Z, strata), res = 30)
  return(fhdRast)
}











# Mosaicing functions ---- !#
# This function will reference every .tif file in a directory, merge them, and save the merge to file

mosaicFunction <- function(directory, outPath) {
  #directory <- paste0(fhdOutPath, "/2017_2018_30m/")
  #outPath <- paste0(fhdOutPath, "/2017_2018_FHD_30mFULL.tif")
  VRT <- list.files(directory, pattern = ".vrt")[[1]]
  #VRT <- paste0(fhdOutPath, "/2017_2018_30m/2017_2018_FHD_30m.vrt")
  #outPath <- paste0(fhdOutPath, "/2017_2018_FHD_30mFULL.tif")
  vRast <- vrt(paste0(directory, VRT))
  writeRaster(vRast, outPath)

  
}
