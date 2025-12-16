# Load in libraries ---- !#
library(sf)
library(terra)
library(lidR)
library(tidyverse)




# file paths ---- !#
path_shared <- "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/ForestLabs data/"
path_labShapefiles <- paste0(path_shared, "Living LayersProjectShapefiles.shp")
path_subCompartment <- paste0(path_shared, "Sub-comp data.csv")
path_LiDAR <- paste0(path_shared, "nlp/")
path_dtm <- paste0("Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_Data/DTM/LIDAR_Composite_10m_DTM_2022.tif")



# Output paths
path_clipped_outputs <- paste0(path_shared, "lidar_clipped/")
path_normalised_outputs <- paste0(path_shared, "lidar_normalised/")
path_chm_outputs <- paste0(path_shared, "chms/")
