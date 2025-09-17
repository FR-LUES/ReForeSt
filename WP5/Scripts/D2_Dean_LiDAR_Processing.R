source("WP5/Scripts/0_setup.R")
source("WP5/Scripts/1_functions.R")

# DO NOT JUST RUN THIS WHOLE SCRIPT, THIS SCRIPT HAS MANY SECTIONS OF PROCESSING AND YOU SHOULD PICK AND CHOOSE WHICH YOU NEED.
# E.G. IF YOU ALREADY HAVE DTMS. DO NOT RECREATE THEM HERE
#plan(multisession(workers = 5))


# Read in catalogs

# 2017
lid_2017 <- readLAScatalog(paste0(path_catalogs, "P_10633_20171130_20180420"))
#catalog_laxindex(lid_2017)
opt_chunk_size(lid_2017) <- 3000

lid_2024 <- readLAScatalog(paste0(path_catalogs, "P_13111_20240201"))
#catalog_laxindex(lid_2024)
opt_chunk_size(lid_2024) <- 3000









# Create dtms for catalogs
#2017
opt  <- list(raster_alignment = 1, # catalog_apply will adjust the chunks if required
             automerge = TRUE)      # catalog_apply will merge the outputs into a single raster
# opt_output_files(lid_2017) <- paste0(path_dtmOut, "/2017/2017dtm_{XCENTER}_{YCENTER}") # 2017 outputs
# catalog_map(lid_2017, dtm_function, .options = opt) # Clip 2017 to dean sites
# 
#opt_restart(lid_2024) <- 1 # restart from error
#lid_2024@output_options$drivers$SpatRaster$param$overwrite <- TRUE# Overwrite existing rasters
#opt_output_files(lid_2024) <- paste0(path_dtmOut, "/2024/2024dtm_{XCENTER}_{YCENTER}") # 2014 outputs
#catalog_map(lid_2024, dtm_function, .options = opt) # Clip 2014 to dean sites







# Normalize height using dtms
# 2017
dtm2017 <- rast(paste0(path_dtmOut, "/2017/FUN.vrt"))
opt_restart(lid_2017) <- 1 # restart from error
opt_output_files(lid_2017) <- paste0(path_catalogs, "/Normalised/2017/{XCENTER}_{YCENTER}_normalised")
catalog_map(lid_2017, normalize_height, algorithm = dtm2017)

# 2024
#vrt(list.files(paste0(path_dtmOut, "/2024/"), full.names = TRUE), paste0(path_dtmOut, "/2024/FUN.vrt"))
dtm2024 <- rast(paste0(path_dtmOut, "/2024/FUN.vrt"))
opt_output_files(lid_2024) <- paste0(path_catalogs, "/Normalised/2024/{XCENTER}_{YCENTER}_normalised")
opt_restart(lid_2024) <- 1
catalog_map(lid_2024, normalize_height, algorithm = dtm2024)







# Create canopy height models ---- !#
# read in normalised point clouds
norm_2017 <- readLAScatalog(paste0(path_catalogs, "Normalised/2017/"))
opt_chunk_size(norm_2017) <- 3000
#catalog_laxindex(norm_2017)
opt_output_files(norm_2017) <- paste0(path_chmOut, "2017/{XCENTER}_{YCENTER}_chm")

norm_2024 <- readLAScatalog(paste0(path_catalogs, "Normalised/2024"))
opt_chunk_size(norm_2024) <- 3000
#catalog_laxindex(norm_2024)
opt_output_files(norm_2024) <- paste0(path_chmOut, "2024/{XCENTER}_{YCENTER}_chm")

# rasterize them
opt_restart(norm_2017) <- 1
norm_2017@output_options$drivers$SpatRaster$param$overwrite <- TRUE# Overwrite existing rasters
catalog_map(norm_2017, rasterize_canopy, algorithm = dsmtin(), res = 1, .options = opt)
catalog_map(norm_2024, rasterize_canopy, algorithm = dsmtin(), res = 1, .options = opt)

vrt(list.files(paste0(path_chmOut, "/2024/"), full.names = TRUE), paste0(path_chmOut, "/2024/chm_2024.vrt"))

# Convert to tifs
chm2017 <- rast(paste0(path_chmOut, "/2017/chm_2017.vrt"))
writeRaster(chm2017, paste0(path_chmOut, "/2017/chm_2017.tif"))











# Inspect canopy height models ---- !#
#2024
chm2024 <- rast(paste0(path_chmOut, "/2024/chm_2024.tif"))
chm2024 <- aggregate(chm2024, factor = 5) # aggregate for plotting
chm2024 <- classify(chm2024, cbind(71, Inf, NA)) # Remove birds lol

# Plot in tmap
ggplot()+
  geom_spatraster(data = chm2024)+
  scale_fill_viridis(option = "A")+
  labs(fill = "Height(m)", title = "Forest of Dean 2024")+
  theme_minimal()


chm2017 <- rast(paste0(path_chmOut, "/2017/chm_2017.tif"))
chm2017 <- aggregate(chm2017, factor = 5) # aggregate for plotting
chm2017 <- classify(chm2017, cbind(71, Inf, NA)) # Remove birds lol

# Plot in tmap
ggplot()+
  geom_spatraster(data = chm2017)+
  scale_fill_viridis(option = "A")+
  labs(fill = "Height(m)", title = "Forest of Dean 2017")+
  theme_minimal()
