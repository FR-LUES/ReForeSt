# read in packages ---- !#
library(sf)
library(terra)
library(tidyverse)
library(lidaRtRee)
library(tidyterra)







# Paths
path_lues <- "Z:/CESB/Land Use and Ecosystem Service/GIS_Data/"
path_Vom <- paste0(path_lues, "EA_VOM/EA_VOM/")
path_VOM_catalog <- paste0(path_Vom, "VOM_TILES.gpkg")
path_NFI <- paste0(path_lues, "NFI_data/TimeSeriesWoodlandMaps.gdb")

path_export <- "WP3/data/gap_map/VOM_tiles/"

# DASH paths
path_Vom_DASH <- "/dbfs/mnt/base/unrestricted/source_environment_agency/dataset_national_lidar_programme_vom/format_GEOTIFF_national_lidar_programme_vom/LATEST_national_lidar_programme_vom/VOM/VOM/"
path_NFI_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/input/NFI/TimeSeriesWoodlandMaps.gdb" 
path_export_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/VOM_tiles/" 

# Gap params ---- !#
gapHeight <- 2
gapSize <- 10
