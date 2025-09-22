library(tidyverse)
library(sf)
library(lidR)
library(future)
library(terra)
library(tmap)
library(tidyterra)
library(viridis)
library(lidaRtRee)
library(future)
library(furrr)

#lidR# Folder paths ---- !#
pathWP5 <- "WP5/"
path_supportShapes <- paste0(pathWP5, "Shapes/Support_shapes/")
path_managementShapes <- paste0(pathWP5, "Shapes/Management_shapes/")
path_LiDAR <- paste0(pathWP5, "LiDAR/")

# Output paths
path_catalogs <- "Z:\\Projects\\FRD_Programme\\FRD_20 ReForeSt\\Dean_lidar\\Forest_of_Dean\\"
path_dtmOut <- paste0(path_catalogs, "dtms/")
path_chmOut <- paste0(path_catalogs, "chms/")


# Read in mangaement data and tidy ---- !#
# Read in and tidy shapefiles ---- !#
#dean <- st_read(paste0(path_supportShapes,
                       #"Dean.shp"), quite = TRUE)# Forest of dean boundaries
coupe <- st_read(paste0(path_managementShapes,
                        "management_coupe.gpkg"))# Read in forest of dean management coupe
sub <- st_read(paste0(path_managementShapes,
                      "dean_subcompartment.gpkg"))# Read in sub-compartment info
# fix column names
colnames(sub) <- sub("^subCompartment\\.\\.\\.INV_COMPDATA_",
                         "",
                         colnames(sub)) # fix names
comp <- read.csv(paste0(path_managementShapes, "deanComponents.csv"))# read in component information

# join management coupe data to subcompartment data
# dean_management <- st_join(sub, coupe[, c("management_prescription")], largest = TRUE)
# deanSub <- inner_join(dean_management, comp[ , c("rel_fw_guid", "last_thinned",
#                        "selection_type", "spis",
#                        "areap", "plyr")],
#                       by = c("fw_guid" = "rel_fw_guid")) |>
#   filter(!is.na(last_thinned) & areap == 100) |>
#   select(scpt, cpmt, management_prescription, last_thinned, selection_type, spis, plyr) |>
#   rename("species" = "spis")
#   colnames(sub)

#st_write(deanSub, paste0(path_managementShapes, "dean_subcompartment_merged.gpkg"))
deanSub <- st_read(paste0(path_managementShapes, "dean_subcompartment_merged.gpkg"))











# constants ---- !#
gapHeight = 2; gapSize = 10 # detect gap constants
