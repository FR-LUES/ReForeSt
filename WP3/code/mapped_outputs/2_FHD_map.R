source("WP3/code/mapped_outputs/0_setup.R")
source("WP3/code/mapped_outputs/1_functions.R")

ctg <- ctgs[[6]]
#lidR::catalog_laxindex(ctg) # create lax index to speed up processing

# Set catalog options
opt_chunk_size(ctg) <- 5000       # in meters, adjust to tile size
opt_chunk_buffer(ctg) <- 20       # buffer to avoid edge artifacts
opt_progress(ctg) <- TRUE # Progress bar
ctg@output_options$drivers$SpatRaster$param$overwrite <- TRUE# Overwrite existing rasters
ctg@processing_options$stop_early <- TRUE
opt  <- list(raster_alignment = 30, # catalog_apply will adjust the chunks if required
        automerge = TRUE)      # catalog_apply will merge the outputs into a single raster


# Set where results will be written
opt_output_files(ctg) <- paste0(fhdOutPath, "2020_2021_30m/2020_2021_{XCENTER}_{YCENTER}_FHD_30m")


#opt_restart(ctg) <- 1 # For restarting from errors.

# Apply pixel metrics to catalog (this will write rasters to disk, not memory)
start_time <- Sys.time()
catalog_map(
  ctg,
  fhdMap_function,
  .options = opt
)
end_time <- Sys.time()
end_time - start_time

#lidR::catalog_apply(ctg, function(chunk) { print(is.empty(chunk)); return(NULL) })
