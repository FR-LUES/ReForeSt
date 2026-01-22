# Load in libraries ---- !#
.libPaths("C:/R-Packages/")
library(sf)
library(terra)
library(lidR)
library(tidyverse)
library(common)


# file paths ---- !#
data_date <- "2026-01-20"

path_root <- "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/ForestLabs data/"
path_shared <- paste0(path_root, data_date, "/")
#path_labShapefiles <- paste0(path_shared, "Living LayersProjectShapefiles.shp")
path_labShapefiles <- paste0(path_shared, "Living LayersProjectShapefiles_20-01-2026.shp")
path_subCompartment <- paste0(path_shared, "Sub-comp data.csv")
path_LiDAR <- paste0(path_root, "nlp/")
path_dtm <- "Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_Data/DTM/LIDAR_Composite_10m_DTM_2022.tif"
path_nlpcat <- "Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_Data/nlp_catalog_shapefile/nlpCat.shp"


# Output paths
path_clipped_outputs <- paste0(path_shared, "lidar_clipped/")
path_normalised_outputs <- paste0(path_shared, "lidar_normalised/")
path_chm_outputs <- paste0(path_shared, "chms/")
