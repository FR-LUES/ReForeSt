
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




# Function to produce dtms for catalogs
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


