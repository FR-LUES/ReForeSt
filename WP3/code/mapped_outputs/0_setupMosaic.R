
# Load libraries ---- !#
library(future)
library(furrr)
library(common) # For file find
library(terra)
library(fs)
library(lidR)
library(tidyverse)
library(sf)


# Set up futures session ---- !#
plan(multisession, workers = 3L)








# Paths ---- !#
# Input paths
wpPath <- "WP3/" # Work package path
dataPath <- paste0(wpPath, "data/")# Path to data
shapesPath <- paste0(dataPath, "shapefiles/") # Path to shapefiles
# z drive paths
sharePath <- "Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_Data/"
nlpPath <- paste0(sharePath, "EA_Lidar_NP1m_Point_Cloud")
catalogPath <- paste0(sharePath, "nlp_catalog_shapefile/nlpCat.shp") # Path to NLP catalog

# Output paths
fhdOutPath <- "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/fhd_map/"
