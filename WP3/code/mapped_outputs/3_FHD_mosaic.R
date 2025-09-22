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
map(2, .f = function(x) {
  tifs <- list.files(paste0(years[[2]]), full.names = TRUE)
  vrt(tifs, paste0(years[[2]], "/", yearNames[[2]], ".vrt"), overwrite = TRUE)
  #vrt(vrt, paste0(fhdOutPath, years[[4]], "/", yearNames[[4]], ".vrt")) # Not needed
  }
  )

# Mosaic as vrt
map(2, .f = function(x) {
  mosaicFunction(paste0(years[[x]], "/"),
                 paste0(fhdOutPath, yearNames[[x]]))
  }
  )


# Plot the mosaic ---- !#
# find files
tif_files <- list.files(fhdOutPath, pattern = "\\.tif$", full.names = TRUE)
# Read them as SpatRasters
ras_list <- sprc(tif_files)

# Mosaic them into a single raster
mosaic_ras <- merge(ras_list, first = TRUE)

ggplot()+
  geom_spatraster(data = mosaic_ras)+
  scale_fill_viridis(option = "A", , na.value = "white")+
  theme_minimal()

# zoomed in
pt <- vect(cbind(-2.36, 55.13), crs = "EPSG:4326")   # lon/lat
pt_bng <- project(pt, "EPSG:27700")            # transform to BNG
# centre point in BNG (EPSG:27700)
x <- 411712   # Easting
y <- 447609  # Northing

# half-width of 10 km square
half <- 20000   # 5 km in each direction

# make extent
e <- ext(x - half, x + half, y - half, y + half)

# crop your mosaic raster (already in BNG)
mosaic_crop <- crop(mosaic_ras, e)
# plot
ggplot() +
  geom_spatraster(data = mosaic_crop) +
  scale_fill_viridis(option = "A", na.value = "white") +
  theme_minimal()
