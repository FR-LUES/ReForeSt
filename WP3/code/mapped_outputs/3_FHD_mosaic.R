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
map(4, .f = function(x) {
  tifs <- list.files(paste0(years[[4]]), full.names = TRUE)
  vrt <- vrt(tifs, paste0(years[[4]], "/", yearNames[[4]], ".vrt"), overwrite = TRUE)
  #vrt(vrt, paste0(fhdOutPath, years[[4]], "/", yearNames[[4]], ".vrt")) # Not needed
  }
  )

# Mosaic as vrt
map(4, .f = function(x) {
  mosaicFunction(paste0(years[[x]], "/"),
                 paste0(fhdOutPath, yearNames[[x]]))
  }
  )


