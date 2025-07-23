library(lidR)
library(sf)
library(tidyverse)

# 1. Load catalog and shapefile
nlp <- readLAScatalog("LiDAR/NLP")
shapes <- st_read("Shapefiles/ReForeSt_shapes.gpkg") |> rename("Site" = "ID")
shapes <- st_buffer(shapes, 30)
shapes$year <- ""
# 2. Define output directory
outdir <- "LiDAR/nlpClipped/"

# 3. Loop over each polygon
for (i in seq_len(nrow(shapes))) {
  #i <- 1
  
  print(paste0(i, " / ", nrow(shapes)))
  this_plot <- shapes[i, ]
  plot_id <- this_plot$Site
  
  las_chunks <- clip_roi(nlp, this_plot)
  #plot(las_chunks)
  year <- las_chunks@header$`File Creation Year`
  shapes$year[i] <- year  
    # Write to output
    outname <- file.path(outdir, paste0("clip_", plot_id, ".laz"))
    writeLAS(las_chunks, outname)
  }
 
st_write(shapes, "Shapefiles/ReForeSt_shapes_buffered.gpkg")
 
