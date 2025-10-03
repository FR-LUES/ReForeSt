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
library(rnaturalearth)






# Data paths ---- !#
dataPath <- "WP4/data/"
metricsPath <- paste0(dataPath, "comparison_metrics.csv")
# Shapefile paths
shapePath <- "WP4/Shapes"
NFIpath <- paste0(shapePath,"/NFI/National_Forest_Inventory_England_2023.shp")
NFIsamplePath <- paste0(shapePath, "/NFI/nfi_sample.shp")

# Raster paths
rastPath <- "WP4/Image_data"
sCHMPath <- paste0(rastPath, "/Synthetic_CHMs/")
CHMPath <- paste0(rastPath, "/LiDAR_CHMs/")
sCHMclipPath <- paste0(rastPath, "/sCHM_clip/")
lCHMclipPath <- paste0(rastPath, "/lCHM_clip/")



# Constants ---- !#
gapHeight <- 2; gapSize <- 5;
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


