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
path_dean_catalogs <- "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/Dean_lidar/Forest_of_Dean/"
path_dean_dtmOut <- paste0(path_dean_catalogs, "dtms/")
path_dean_chmOut <- paste0(path_dean_catalogs, "chms/")
path_private_catalogs <- "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/Private_sites_lidar/"
path_private_lidar <- paste0(path_private_catalogs, "Fell_Site_Subsets_Lidar_Point_Cloud_Data/")
path_private_shapes <- paste0(path_private_catalogs, "shapes/")

# # Read in mangaement data and tidy ---- !#
# # Read in and tidy shapefiles ---- !#
# dean <- st_read(paste0(path_supportShapes,
#                        "Dean.shp"), quite = TRUE)# Forest of dean boundaries
# coupe <- st_read(paste0(path_managementShapes,
#                         "management_coupe.gpkg"))# Read in forest of dean management coupe
# sub <- st_read(paste0(path_managementShapes,
#                       "dean_subcompartment.gpkg"))# Read in sub-compartment info
# # fix column names
# colnames(sub) <- sub("^subCompartment\\.\\.\\.INV_COMPDATA_",
#                          "",
#                          colnames(sub)) # fix names
# comp <- read.csv(paste0(path_managementShapes, "deanComponents.csv"))# read in component information
# #View(comp)
# # join management coupe data to subcompartment data
# dean_management <- st_join(sub, coupe[, c("management_prescription", "next_intervention_year", "next_intervention_type")], largest = TRUE)
#  deanSub <- inner_join(dean_management, comp[ , c("rel_fw_guid", "last_thinned", "next_thin_date",
#                        "selection_type", "spis",
#                         "areap", "plyr")],
#                       by = c("fw_guid" = "rel_fw_guid")) |>
#    filter(!is.na(last_thinned) & areap > 50) |>
#    select(scpt, cpmt, management_prescription, last_thinned,
#           next_thin_date, selection_type, spis, plyr,
#           next_intervention_year, next_intervention_type) |>
#   rename("species" = "spis")
#   
# 
# st_write(deanSub, paste0(path_managementShapes, "dean_subcompartment_merged.gpkg"))
deanSub <- st_read(paste0(path_managementShapes, "dean_subcompartment_merged.gpkg"))











# constants ---- !#
gapHeight <-  2; gapSize <-  10 # detect gap constants
strata <- c(0, 1, 2, 5, 8, 20)
