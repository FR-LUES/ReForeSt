
# Load libraries ---- !#
library(future)
library(furrr)
library(common) # For file find
library(terra)
library(lidR)
library(tidyverse)
library(sf)




# Set up futures session ---- !#
plan(multisession, workers = 10L)
set_lidr_threads(2L)


is.parallelised(pixel_metrics())







# Paths ---- !#
# Input paths
wpPath <- "WP3/" # Work package path
dataPath <- paste0(wpPath, "data/")# Path to data
shapesPath <- paste0(dataPath, "shapefiles/") # Path to shapefiles
catalogPath <- paste0(shapesPath, "nlpCat.shp") # Path to NLP catalog
sharePath <- "//forestresearch.gov.uk/CESB/Land Use and Ecosystem Service/GIS_Data/EA_Data/"
nlpPath <- paste0(sharePath, "EA_Lidar_NP1m_Point_Cloud")

# Output paths
fhdOutPath <- "//forestresearch.gov.uk/projects/FRD_Programme/FRD_20/ReForeSt/fhd_map/"












# Constants
strata <- c(0, 1, 2, 5, 8, 20, 100)

# Find collection of tiles to map over ---- !#
# This is run once and takes about a day. Afterwards the list is saved as an rds to be read in.

# Read in nlp catalog
#nlpCat <- st_read(catalogPath)
# glimpse(nlpCat)
# # Extract tile IDs
# tileIds <- unique(nlpCat$TILENAME)
# # Set up years in search order (newest first)
# year_folders <- c("2021_2022", "2020_2021", "2019_2020")
# Find the most recent laz file for each tile

# tileFolders <- future_map(tileIds, function(id) {
#   # Look in each year until we find a match
#   for (yr in year_folders) {
#     search_path <- file.path(nlpPath, "/", yr)
#     #print(search_path)
#     found <- dir_ls(
#       path   = search_path,
#       regexp = paste0(id, ".*\\.laz$"),
#       recurse = TRUE
#     )
#     
#     if (length(found) > 0) {
#       return(found[1])  # return the first match and stop
#     }
#   }
#   return(NA_character_)  # if nothing found in any year
# }, .progress = TRUE)

# Save the list of files as rds file
#saveRDS(tileFolders, paste0(sharePath, "nlp_file_list.rds"))
detach("package:common", unload = TRUE)



# Read in las catalog ---- !#
tileFolders <- read_rds(paste0(sharePath, "nlp_file_list.rds"))
testFiles <- unlist(tileFolders[1:3])
ctg <- readLAScatalog(testFiles)
rm(tileFolders)

   