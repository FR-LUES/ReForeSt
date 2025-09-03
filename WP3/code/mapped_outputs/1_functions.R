

# FHD here is defined as the effective number of canopy layers - the exponent of shannon's eveness.
# This is calculated for the whole of england as its quicker than clipping las files to woodlands.
# Entropy function to operate at varying resolutions
fhdFunction <- function(heights, strata){
  # Tidy some ground heights
  heights[heights < 0] <- 0
  heights <- heights[!is.na(heights)]
  # Bin Heights into stratas
  bins <- cut(heights, strata, labels = FALSE, include.lowest = TRUE)
  # find frequency of values in each bin
  freqs <- table(factor(bins, levels = 1:(length(strata)-1)))
  # Calculate effective canopy layers
  total_values <- sum(freqs)
  proportions <- freqs/total_values
  shannon_index <- -1*sum(proportions * log(proportions), na.rm = TRUE)
  effectiveCanopyLayers <- exp(shannon_index) |> round(2)
  return(effectiveCanopyLayers)
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
