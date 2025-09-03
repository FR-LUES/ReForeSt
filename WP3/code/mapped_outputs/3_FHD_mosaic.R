source("WP3/code/mapped_outputs/1_functions.R")
source("WP3/code/mapped_outputs/0_setupMosaic.R")


# find folder name for each year of FHD maps
years <- list.dirs(paste0(fhdOutPath), recursive = FALSE) 
yearNames <- c("2017_2018_30M", 
               "2018_2019_30M", 
               "2019_2020_30M",
               "2020_2021_30M", 
               "2021_2022_30M")

map(1:length(years), .f = function(x) {
  mosaicFunction(paste0(years[[1]], "/"),
                 paste0(fhdOutPath, "/", yearNames[[1]], "FULL.tif"))
  })

