
# lax index function as for some reason my lidr version doesn't have it.
# This function means that catalog_map functions only read in the required buffer and not entire surrounding tiles when calculating metrics

catalog_laxindex = function(ctg)
{
  stopifnot(is(ctg, "LAScatalog"))
  
  opt_chunk_size(ctg)   <- 0
  opt_chunk_buffer(ctg) <- 0
  opt_wall_to_wall(ctg) <- FALSE
  opt_output_files(ctg) <- ""
  
  create_lax_file = function(cluster) {
    rlas::writelax(cluster@files)
    return(0)
  }
  
  options <- list(need_buffer = FALSE, drop_null = FALSE)
  
  catalog_apply(ctg, create_lax_file,.options = options)
  return(invisible())
}










# Function to produce dtms for catalogs ---- !#
dtm_function <- function(chunk) {
  
  # Count ground points (ASPRS class 2)
  n_ground <- sum(chunk@data$Classification == 2, na.rm = TRUE)
  
  if (n_ground < 50) {
    return(NULL)
  } else{
    
    dtm <- rasterize_terrain(chunk, res = 1, algorithm = tin())
    gc()
    
    return(dtm)
  }
}









# Gap detect gap function ---- !#
# chm is the canopy height model
# Shape is the corresponding SF object for the chm
gapsToRast <- function(chm, Shape){
  
  #chm <- chm2017_crop[[2]]
  #Shape <- deanSub_og[2,]
  
  # Restrict CHM to inside polygon
  
  # Gap detection algorithm based on max height within gaps and a minimal surface area
  gapSF <- gap_detection(chm,
                         res = 1,
                         gap_max_height = gapHeight,
                         min_gap_surface = gapSize)
  #View(gap_detection)
  # Areas external to the woodland are considered gaps to fill out raster
  # These areas are removed below
  gapMask <- mask(gapSF, buffer(vect(Shape), -1.5))# remove external area by masking by site
  # Identify where this area protruded to count gaps smaller than our minimum surface
  freqs <- freq(gapMask[[1]])
  freqsSubset <- freqs[freqs$count >= gapSize, ]
  validGaps <- unique(freqsSubset$value)
  
  # Remove small gaps using the earlier freqs subset
  gaps <- tidyterra::filter(gapMask, gap_id %in% validGaps)
  
  return(gaps)
}






# FHD function ---- !#
# Entropy function to operate at varying resolutions
canopyEntropy <- function(heights, strata){
  # Tidy some ground heights
  heights[heights < 0] <- 0
  heights[heights > 60] <- NA # remove birds
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

# Zonal eff Canopy layer function ---- !#
# This function is for computing effective canopy layers zonally at varying cell resolutions
zonal_effCanopyLayer <- function(chm, shape, res, strata){
  # Remove edge effects
  chm <- mask(chm, st_buffer(shape, 10))
  effCanopyRaster <- raster_metrics(chm,
                                    fun = function(x)
                                      data.frame(effCanopy = canopyEntropy(x, strata = strata)),
                                    res = res
  )
  return(effCanopyRaster)  
}











# stem density function ---- !#
# return ttops points
ttopsFunction <- function(site_chm, site_boundary){
ttops_chm <-
  locate_trees(site_chm, algorithm = lmf(ws = 10)) |> 
  st_filter(site_boundary)
return(ttops_chm)
}

