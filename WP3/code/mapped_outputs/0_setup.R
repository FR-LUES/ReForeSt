
# Load libraries ---- !#
library(future)
library(furrr)
library(common) # For file find
library(terra)
library(tidyterra)
library(fs)
library(lidR)
library(tidyverse)
library(sf)
library(viridis)
library(lidaRtRee)


# Set up futures session ---- !#
#plan(multisession, workers = 2)


# Directories and Paths ---- !#
dir_Z <- "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/"
dir_Z_raw_data <- paste0(dir_Z, "02_data/00_raw_data/")
dir_Z_proc_data <- paste0(dir_Z, "02_data/01_processed_data/")
dir_EA_data <- "Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_Data/"
dir_NLP <- paste0(dir_EA_data, "EA_Lidar_NP1m_Point_Cloud")
dir_VOM <- "Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_VOM/EA_VOM/"

path_NLP_catalog <- paste0(dir_EA_data, "nlp_catalog_shapefile/nlpCat_22_24_merged.shp")
path_DTM <- paste0(dir_EA_data, "DTM/LIDAR_Composite_10m_DTM_2022.tif")
path_VOM_fyl <- paste0(dir_VOM, "V2_VOM_P_130241.tif")
path_NFI <- paste0(dir_Z_raw_data, "NFI/NFI2020.gpkg")
path_england <- "Z:/CESB/Land Use and Ecosystem Service/LUES_Sware/PersonalFolders/Joe/Data/ONS_Open_Geography/Countries_Dec_2021_GB_BFC_2022_6264036014383714060.gpkg"



dir_fhd <- paste0(dir_Z_proc_data, "fhd_map/")
dir_fhd_map_incomplete <- paste0(dir_fhd, "fhd_incomplete_2020_30m.tif")
dir_fhd_map <- paste0(dir_fhd, "fhd_england_2020_30m.tif")
dir_fhd_map_NFI <- paste0(dir_fhd, "fhd_england_NFI_2020_30m.tif")
dir_fhd_map_TOW <- paste0(dir_fhd, "fhd_england_TOW_2020_30m.tif")
dir_fhd_map_NFI_TOW <- paste0(dir_fhd, "fhd_england_NFI_TOW_2020_30m.tif")

dir_gap_map <- paste0(dir_Z_proc_data, "gap_map/")
dir_gap_map_100km <- paste0(dir_gap_map, "100km_tiles/")
dir_gap_map_fyl <- paste0(dir_gap_map, "fylingdales_tile/")
dir_gap_map_eng <- paste0(dir_gap_map, "england/")
path_gap_map_fyl <- paste0(dir_gap_map_fyl, "fylingdales_VOM_gaps.tif")
path_gap_map <- paste0(dir_gap_map_eng, "gap_map_1m.tif")

dir_gap_frac <- paste0(dir_Z_proc_data, "gap_fraction/")
path_gap_frac <- paste0(dir_gap_frac, "gap_fraction_england_NFI_2020_30m.tif")

dir_rh90 <- paste0(dir_Z_proc_data, "rh90_map/")
path_rh90_incomplete <- paste0(dir_rh90, "drafts/rh90_incomplete_2020_30m.tif")
path_rh90 <- paste0(dir_rh90, "rh90_england_2020_30m.tif")
path_rh90_NFI <- paste0(dir_rh90, "rh90_england_NFI_2020_30m.tif")
path_rh90_TOW <- paste0(dir_rh90, "rh90_england_TOW_2020_30m.tif")
path_rh90_NFI_TOW <- paste0(dir_rh90, "rh90_england_NFI_TOW_2020_30m.tif")





# DASH paths
path_eng_DASH <- "/dbfs/mnt/base/unrestricted/source_ordnance_survey_data_hub/dataset_boundary_line/format_SHP_boundary_line/SNAPSHOT_2025_10_02_boundary_line/GB/english_region_region.shp"
dir_VOM_DASH <- "/dbfs/mnt/base/unrestricted/source_environment_agency/dataset_national_lidar_programme_vom/format_GEOTIFF_national_lidar_programme_vom/LATEST_national_lidar_programme_vom/VOM/VOM/"
path_NFI_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/input/NFI/TimeSeriesWoodlandMaps.gdb" 

dir_fhd_map_eng <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/fhd_map/"
path_fhd_map_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/fhd_map/fhd_england_2020_30m.tif"

dir_gap_map_10km_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/VOM_tiles/" 
dir_gap_map_100km_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/100km_mosaic/" 
dir_gap_map_fyl_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/fylingdales_tile/" 
dir_gap_map_eng_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/england_mosaic/"
path_gap_map <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_map/england_mosaic/gap_map_1m.tif"

path_gap_frac_tiles_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_fraction/tiles/"
path_gap_frac_eng_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/gap_fraction/england_mosaic/"

dir_rh90_tiles_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/rh90_map/VOM_tiles/" 
dir_rh90_eng_DASH <- "/dbfs/mnt/lab/unrestricted/joebeesley/ReForeSt_data/output/WP3/rh90_map/england_mosaic/"











# Constants ---- !#
strata <- c(0, 1, 2, 5, 8, 20, 100)

gapHeight <- 2
gapSize <- 10



#Find collection of tiles to map over ---- !#
#This is run once and takes about a day. Afterwards the list is saved as an rds to be read in.

# # # # #Read in nlp catalog
#  nlpCat <- st_read(path_NLP_catalog)
# # #
# # #
# #  # Extract tile IDs
# fileIds <- unique(paste0(nlpCat$TILENAME, "_", nlpCat$POLYGON_ID))
# #
# #  # Find the most recent laz file for each tile
# years <- c("2023_2024", "2022_2023", "2021_2022", "2020_2021", "2019_2020", "2018_2019", "2017_2018")
# #
# #  # Loop over each year and collect all .laz files that match any tile
#  for (yr in years) {
#     #yr <- years[[1]]
#   search_path <- file.path(dir_NLP, yr)
# 
#    # For each tile, find matching files
#    tileFiles <- future_map(fileIds, function(id) {
#      # Escape special characters in id for regex
#      #id <- fileIds[[1]]
# 
#      found <- dir_ls(
#        path    = search_path,
#        regexp  = paste0(id, ".*\\.laz$"),
#       recurse = TRUE
#      )
# 
#      if (length(found) == 0) return(NA_character_)
#      return(found)
#    }, .progress = TRUE)
# 
#    names(tileFiles) <- fileIds
# 
#    # Save RDS for this year
#    saveRDS(tileFiles, file.path(dir_EA_data, paste0("nlp_file_list_", yr, ".rds")))
# 
#    message("Saved file list for year ", yr)
# }
# # 


# Read in las catalog ---- !#
# List the per-year RDS files
#year_files <- dir_ls(dir_EA_data, regexp = "nlp_file_list_.*\\.rds$")

# Extract LAZ lists for each year
#tileFiles <- map(year_files, function(rds){
#  read_rds(rds) |>
#  unlist() |>
#  na.omit() |> # remove NAs
#  unique()})
#names(tileFiles) <- basename(year_files) |> tools::file_path_sans_ext()

# Read in the catalogs
#ctgs <- map(tileFiles, function(laz){
#  readLAScatalog(laz, select = "xyzc")
#})
#names(ctgs) <- names(tileFiles)








# Find missing tiles ---- !#
# When processing the map some tiles turned out to be missing and so we find them here and reprocess in he procressing script
#ctg <- readLAScatalog(tileFiles$nlp_file_list_2020_2021[
#  grepl("P_10707", tileFiles$nlp_file_list_2020_2021)
#])

