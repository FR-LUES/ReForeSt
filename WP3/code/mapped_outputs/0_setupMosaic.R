
# Load libraries ---- !#
library(future)
library(furrr)
library(common) # For file find
library(terra)
library(fs)
library(lidR)
library(tidyverse)
library(sf)
library(tidyterra)
library(viridis)
# Set up futures session ---- !#
plan(multisession, workers = 3L)

# Paths ---- !#
path_Z <- "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/"
path_Z_raw_data <- paste0(path_Z, "02_data/00_raw_data/")
path_Z_proc_data <- paste0(path_Z, "02_data/01_processed_data/")

wpPath <- paste0(path_Z_raw_data, "WP3/") # Work package path
dataPath <- paste0(wpPath, "data/")# Path to data
shapesPath <- paste0(dataPath, "shapefiles/") # Path to shapefiles


sharePath <- "Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_Data/"
nlpPath <- paste0(sharePath, "EA_Lidar_NP1m_Point_Cloud")
catalogPath <- paste0(sharePath, "nlp_catalog_shapefile/nlpCat.shp") # Path to NLP catalog

# Output paths
fhdOutPath <- path_gap_map <- paste0(path_Z_proc_data, "fhd_map/")
