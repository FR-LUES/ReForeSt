source("WP3/code/mapped_outputs/1_functions.R")
source("WP3/code/mapped_outputs/0_setupMosaic.R")


# find folder name for each year of FHD maps
years <- list.dirs(paste0(fhdOutPath), recursive = FALSE) 
yearNames <- c("2017_2018_30M", 
               "2018_2019_30M", 
               "2019_2020_30M",
               "2020_2021_30M", 
               "2021_2022_30M")

# Create vrt for each year
map(1, .f = function(x) {
  tifs <- list.files(paste0(years[[1]]), full.names = TRUE)
  vrt(tifs, paste0(years[[1]], "/", yearNames[[1]], ".vrt"), overwrite = TRUE)
  #vrt(vrt, paste0(fhdOutPath, years[[4]], "/", yearNames[[4]], ".vrt")) # Not needed
  }
  )

# Mosaic from vrt
map(1, .f = function(x) {
  mosaicFunction(paste0(years[[x]], "/"),
                 paste0(fhdOutPath, yearNames[[x]]))
  }
  )


# Plot the mosaic ---- !#
# find files
tif_files <- list.files(fhdOutPath, pattern = "\\.tif$", full.names = TRUE)
# Read them as SpatRasters
ras_list <- sprc(rev(tif_files))

# Mosaic them into a single raster
mosaic_ras <- mosaic(ras_list, fun = "last")
writeRaster(mosaic_ras, paste0(fhdOutPath, "/FHD_full_30m.tif"))
# plot to check
ggplot()+
  geom_spatraster(data = mosaic_ras)+
  scale_fill_viridis(option = "A", , na.value = "white")+
  theme_minimal()

# zoomed in
pt <- vect(cbind(2.5519, 51.8000), crs = "EPSG:4326")   # lon/lat
pt_bng <- project(pt, "EPSG:27700")            # transform to BNG
# centre point in BNG (EPSG:27700)
x <- 362700   # Easting
y <- 210753  # Northing

# half-width of 10 km square
half <- 6000   # 5 km in each direction

# make extent
e <- ext(x - half, x + half, y - half, y + half)

# crop your mosaic raster (already in BNG)
mosaic_crop <- crop(mosaic_ras, e)
# plot
ggplot() +
  geom_spatraster(data = mosaic_crop) +
  scale_fill_viridis(option = "A", na.value = "white") +
  theme_minimal()
