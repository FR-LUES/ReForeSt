source("WP3/code/mapped_outputs/0_setup.R")
source("WP3/code/mapped_outputs/1_functions.R")

# Set catalog options
opt_chunk_size(ctg) <- 1000       # in meters, adjust to tile size
opt_chunk_buffer(ctg) <- 50         # buffer to avoid edge artifacts
opt_progress(ctg) <- TRUE
opt_select(ctg) <- "xyzc"   # read only the coordinates. # Only read point info
opt  <- list(raster_alignment = 30, # catalog_apply will adjust the chunks if required
        automerge = TRUE)      # catalog_apply will merge the outputs into a single raster






# Set where results will be written
opt_output_files(ctg) <- paste0(fhdOutPath, "{XCENTER}_{YCENTER}_FHD_30m")

# Apply pixel metrics to catalog (this will write rasters to disk, not memory)
catalog_map(
  ctg,
  fhdMap_function,
  .options = opt
)

