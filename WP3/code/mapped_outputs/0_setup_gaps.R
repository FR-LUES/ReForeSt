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


# Gap params ---- !#
gapHeight <- 2
gapSize <- 10
