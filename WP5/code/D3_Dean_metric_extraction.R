source("WP5/Scripts/0_setup.R")
source("WP5/Scripts/1_functions.R")

# Read in CHM ---- !#
chm2017 <- rast(paste0(path_chmOut, "/2017/chm_smooth_2017.tif")) 
chm2024 <- rast(paste0(path_chmOut, "/2024/chm_smooth_2024.tif"))
# Spatial information is consistent, however one raster is slightly larger than the other.
chm2024 <- crop(chm2024, ext(chm2017)) # make extents align, they are off by a meter.





# filter dean sub to only polygons which have been thinned between 2017 and 2024 ---- !#
deanSub_buffered <- deanSub |>
  filter((last_thinned > 2017 & last_thinned < 2024) | (last_thinned < 2017 & next_thin_date > 2024)) |>
  mutate(last_thinned = case_when(last_thinned < 2017 ~ "< 2016",
                                  .default = "2017<2024")) |>
  st_buffer(20) # A buffered version for LiDAR processing
# and a non-buffered version for metric extraction
deanSub_og <- deanSub |>
  filter((last_thinned > 2017 & last_thinned < 2024) | (last_thinned < 2017 & next_thin_date > 2024)) |>
  mutate(last_thinned = case_when(last_thinned < 2017 ~ "< 2016",
                                  .default = "2017<2024"))

# Crop CHMs to dean polygons ---- !#
# 2017
chm2017_crop <- map(1:nrow(deanSub_buffered),
                    .f = function(i){
                      chm2017 |>
                        crop(deanSub_buffered[i,]) |>
                        mask(deanSub_buffered[i,])})

# 2024
chm2024_crop <- map(1:nrow(deanSub_buffered),
                    .f = function(i){
                      chm2024 |>
                        crop(deanSub_buffered[i,]) |>
                        mask(deanSub_buffered[i,])})








# Difference raster ---- !#
# This raster will register changes in height between years
difference <- map(1:length(chm2024_crop), .f = function(x) chm2024_crop[[x]] - chm2017_crop[[x]])

# Extract differences to shapefiles
heightChange <- map(1:length(difference), .f = function(x)
  zonal(difference[[x]], vect(deanSub_og[x,]), fun = "mean", na.rm = TRUE))
deanSub_og$heightChange <- unlist(heightChange)







# Gaps
# Extract gaps as rasters
gaps2017 <- map(1:nrow(deanSub_og),
                       .f = function(x){
                         x <- 3
                         gaps <- gapsToRast(chm2017_crop[[x]], deanSub_og[x,])
                         plot(gaps)
                         expanse(gaps$gap_id)
                         print(x)
                         return(gaps)})
gaps2024 <- map(1:nrow(deanSub_og),
                .f = function(x){
                  gaps2 <- gapsToRast(chm2024_crop[[x]], deanSub_og[x,])
                  plot(gaps2)
                  expanse(gaps2$gap_id)
                  print(x)
                  return(gaps)  
                })

# calculate gap area for each polygon
gapArea2017 <- map_dbl(gaps2017, .f = function(i){
  area <- expanse(i$gap_id)[,2]
  return(area)})
deanSub_og$gapArea_2017 <- unlist(gapArea2017)

gapArea2024 <- map_dbl(gaps2024, .f = function(i){
  area <- expanse(i$gap_id)[,2]
  return(area)})
deanSub_og$gapArea_2024 <- unlist(gapArea2024)







# Foliage height diversity ---- !#
fhd2017 <- map(1:length(chm2017_crop), .f = function(x)
  zonal_effCanopyLayer(chm2017_crop[[x]], deanSub_og[x, ], res = 30, strata = strata)
  )
fhd2024 <- map(1:length(chm2024_crop), .f = function(x)
  zonal_effCanopyLayer(chm2024_crop[[x]], deanSub_og[x, ], res = 30, strata = strata)
)


deanSub_og$meanFHD_2017 <- map_dbl(fhd2017, .f = function(x) mean(values(x), na.rm = TRUE))
deanSub_og$meanFHD_2024 <- map_dbl(fhd2024, .f = function(x) mean(values(x), na.rm = TRUE))











# Stem density ---- !#
stems2017 <- map(1:length(chm2017_crop), .f = function(x)
  ttopsFunction(chm2017_crop[[x]], deanSub_og[x, ])
)
stems2024 <- map(1:length(chm2024_crop), .f = function(x)
  ttopsFunction(chm2024_crop[[x]], deanSub_og[x, ])
)

deanSub_og$stems_2017 <- map_dbl(1:nrow(deanSub_og), .f = function(x)
  nrow(stems2017[[x]])
)
deanSub_og$stems_2024 <- map_dbl(1:nrow(deanSub_og), .f = function(x)
  nrow(stems2024[[x]])
)




# save data
st_write(deanSub_og, paste0(pathWP5, "Shapes/metrics_shapes.gpkg"))
write.csv(st_drop_geometry(deanSub_og), paste0(pathWP5, "Data/metrics.csv"))
