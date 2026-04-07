library(tidyverse)
library(terra)
library(sf)
library(lidR)
library(lidaRtRee)
library(landscapemetrics)
library(ggthemes)
#library(ggpmisc)
library(broom)
library(tidyterra)
#library(rnaturalearth)






# Data paths ---- !#

path_Z <- "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/"
path_Z_raw_data <- paste0(path_Z, "02_data/00_raw_data/")
path_Z_proc_data <- paste0(path_Z, "02_data/01_processed_data/")
path_Z_proc_data_WP4 <- paste0(path_Z_proc_data, "WP4/")

metricsPath <- paste0(path_Z_proc_data_WP4, "comparison_metrics.csv")

# Shapefile paths
shapePath <- paste0(path_Z_raw_data, "WP4/Shapes/")
NFIpath <- paste0(shapePath,"NFI/National_Forest_Inventory_England_2023.shp")
NFIsamplePath <- paste0(shapePath, "NFI/nfi_sample.shp")

# Raster paths
rastPath <- paste0(path_Z_proc_data_WP4, "CHM/")
sCHMPath <- paste0(rastPath, "Synthetic_CHMs/")
CHMPath <- paste0(rastPath, "LiDAR_CHMs/")
sCHMclipPath <- paste0(rastPath, "sCHM_clip/")
lCHMclipPath <- paste0(rastPath, "lCHM_clip/")

effCanPath <- paste0(rastPath, "30m_effCanopy_sCHM/")
gapPath <- paste0(rastPath, "gaps_sCHM/")


# Constants ---- !#
gapHeight <- 2; gapSize <- 10;
strata <- c(0, 1, 2, 10, 20, 50)

# Gap metrics
l_metrics = c("lsm_l_np", # Number of gap
              "lsm_l_ta") # Total gap Area)






# Get England Basemap for plotting ---- !#
# Get UK countries
uk <- ne_countries(scale = "medium", country = "United Kingdom", returnclass = "sf")

# Get subnational units (England, Scotland, Wales, NI)
uk_sub <- ne_states(country = "United Kingdom", returnclass = "sf")

england <- uk_sub[uk_sub$geonunit == "England", ] |> st_union()


