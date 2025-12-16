
# Load libraries ---- !#
library(future)
library(furrr)
library(common) # For file find
library(terra)
library(fs)
library(lidR)
library(tidyverse)
library(sf)
#library(viridis)

# Set up futures session ---- !#
plan(multisession, workers = 2)











# Paths ---- !#
# Input paths
wpPath <- "WP3/" # Work package path
dataPath <- paste0(wpPath, "data/")# Path to data
shapesPath <- paste0(dataPath, "shapefiles/") # Path to shapefiles
# z drive paths
sharePath <- "Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_Data/"
nlpPath <- paste0(sharePath, "EA_Lidar_NP1m_Point_Cloud")
catalogPath <- paste0(sharePath, "nlp_catalog_shapefile/nlpCat_22_24_merged.shp") # Path to NLP catalog

# Output paths
fhdOutPath <- "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/fhd_map/"












# Constants ---- !#
strata <- c(0, 1, 2, 5, 8, 20, 100)









#Find collection of tiles to map over ---- !#
#This is run once and takes about a day. Afterwards the list is saved as an rds to be read in.

# # # # #Read in nlp catalog
#  nlpCat <- st_read(catalogPath)
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
#   search_path <- file.path(nlpPath, yr)
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
#    saveRDS(tileFiles, file.path(sharePath, paste0("nlp_file_list_", yr, ".rds")))
# 
#    message("Saved file list for year ", yr)
# }
# # 


# Read in las catalog ---- !#
# List the per-year RDS files
year_files <- dir_ls(sharePath, regexp = "nlp_file_list_.*\\.rds$")

# Extract LAZ lists for each year
tileFiles <- map(year_files, function(rds){
  read_rds(rds) |>
  unlist() |>
  na.omit() |> # remove NAs
  unique()})
names(tileFiles) <- basename(year_files) |> tools::file_path_sans_ext()

# Read in the catalogs
ctgs <- map(tileFiles, function(laz){
  readLAScatalog(laz, select = "xyzc")
})
names(ctgs) <- names(tileFiles)








# Find missing tiles ---- !#
# When processing the map some tiles turned out to be missing and so we find them here and reprocess in he procressing script
ctg <- readLAScatalog(tileFiles$nlp_file_list_2020_2021[
  grepl("P_10707", tileFiles$nlp_file_list_2020_2021)
])

