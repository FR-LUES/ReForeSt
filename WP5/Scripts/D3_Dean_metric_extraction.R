source("WP5/Scripts/0_setup.R")
source("WP5/Scripts/1_functions.R")

# Read in CHM ---- !#
chm2017 <- rast(paste0(path_chmOut, "\\2017\\chm_2017.tif")) 
chm2024 <- rast(paste0(path_chmOut, "\\2024\\chm_2024.tif"))

# Crop CHMs to dean polygons
# filter dean sub to only polygons which have been thinned between 2017 and 2024
deanSub_years <- deanSub |>
  filter(last_thinned > 2017 & last_thinned < 2024)
# crop chms
# 2017
chm2017_crop <- map(1:nrow(deanSub_years),
                    .f = function(i){
                      chm2017 |>
                        crop(deanSub_years[i,]) |>
                        mask(deanSub_years[i,])})

# 2024
chm2024_crop <- map(1:nrow(deanSub_years),
                    .f = function(i){
                      chm2024 |>
                        crop(deanSub_years[i,]) |>
                        mask(deanSub_years[i,])})









# Extract metrics ---- !#
future::plan(multisession, workers = 3)
# Gaps
# Extract gaps as rasters
gaps2017 <- map(1:nrow(deanSub_years),
                       .f = function(x){
                         gaps <- gapsToRast(chm2017_crop[[x]], deanSub_years[x,])
                         print(x)
                         return(gaps)})
gaps2024 <- map(1:nrow(deanSub_years),
                .f = function(x){
                  gaps <- gapsToRast(chm2024_crop[[x]], deanSub_years[x,])
                  print(x)
                  return(gaps)  
                })

# calculate gap area for each polygon
gapArea2017 <- map_dbl(gaps2017, .f = function(i){
  area <- expanse(i$gap_id)[,2]
  return(area)})
deanSub_years$gapArea_2017 <- unlist(gapArea2017)

gapArea2024 <- map_dbl(gaps2024, .f = function(i){
  area <- expanse(i$gap_id)[,2]
  return(area)})
deanSub_years$gapArea_2024 <- unlist(gapArea2024)



