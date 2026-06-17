# Packages
library(sf)
library(terra)
library(tidyverse)
#library(lidaRtRee)
library(tidyterra)

# FR paths
path_Z <- "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/"
path_Z_raw_data <- paste0(path_Z, "02_data/00_raw_data/")
path_Z_proc_data <- paste0(path_Z, "02_data/01_processed_data/")

path_gap_map <- paste0(path_Z_proc_data, "gap_map/")
path_gap_map_100km <- paste0(path_gap_map, "100km_tiles/")
path_gap_map_fyl <- paste0(path_gap_map, "fylingdales_tile/")
path_gap_map_eng <- paste0(path_gap_map, "england/")
path_Z_gap_frac_eng <- paste0(path_Z_proc_data, "gap_fraction/gap_fraction_england_NFI_2020_30m.tif")

path_rh90 <- paste0(path_Z_proc_data, "rh90_map/")

path_lues <- "Z:/CESB/Land Use and Ecosystem Service/GIS_Data/"
path_Vom <- paste0(path_lues, "EA_VOM/EA_VOM/")
path_VOM_fyl <- paste0(path_Vom, "V2_VOM_P_130241.tif")
path_VOM_catalog <- paste0(path_Vom, "VOM_TILES.gpkg")
path_NFI <- paste0(path_Z_raw_data, "NFI/NFI2020.gpkg")


# DASH paths
path_eng_DASH <- "/dbfs/mnt/base/unrestricted/source_ordnance_survey_data_hub/dataset_boundary_line/format_SHP_boundary_line/SNAPSHOT_2025_10_02_boundary_line/GB/english_region_region.shp"
path_Vom_DASH <- "/dbfs/mnt/base/unrestricted/source_environment_agency/dataset_national_lidar_programme_vom/format_GEOTIFF_national_lidar_programme_vom/LATEST_national_lidar_programme_vom/VOM/VOM/"
path_NFI_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/input/NFI/TimeSeriesWoodlandMaps.gdb" 

path_fhd_map_eng <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/fhd_map/"
path_fhd_map_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/fhd_map/fhd_england_2020_30m.tif"

path_gap_map_10km_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/VOM_tiles/" 
path_gap_map_100km_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/100km_mosaic/" 
path_gap_map_fyl_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/fylingdales_tile/" 
path_gap_map_eng_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/england_mosaic/"
path_gap_map_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/england_mosaic/gap_map_1m.tif"

path_gap_frac_tiles_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_fraction/tiles/"
path_gap_frac_eng_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_fraction/england_mosaic/"

path_rh90_tiles_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/rh90_map/VOM_tiles/" 
path_rh90_eng_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/rh90_map/england_mosaic/"


# Gap params
gapHeight <- 2
gapSize <- 10
