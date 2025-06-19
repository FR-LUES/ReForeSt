##### metadata


##### packages

# need a line to install?

library(tidyverse)
library(tidyterra)
library(hablar) # convert() function
library(sf)
library(terra)
library(lidR)
library(lidaRtRee)
library(landscapemetrics)
library(GLCMTextures)

##### paths

path_data = "data/"


path_test_data = paste0(path_data, "test_data/")
path_test_lasClipped = paste0(path_test_data, "clipped_pointClouds/")
path_test_data_lasNormalised = paste0(path_test_data, "normalised_pointClouds/")

path_test_data_shp = paste0(path_test_data, "shapes/")
path_test_data_chm = paste0(path_test_data, "chms/")

path_DASH_las = "/Workspace/Users/joseph.beesley@defra.onmicrosoft.com/ReForeSt_LiDAR_data/normalised"

path_outputs = "outputs/"
path_outputs_gap = paste0(path_outputs, "gap_analysis/")
path_outputs_effCan = paste0(path_outputs, "effective_canopy_layers/")
path_outputs_texture = paste0(path_outputs, "textureMetrics/")

##### constants

# gap analysis

gapHeight = 2 # m
gapSize = 5 # m2

p_metrics = c("lsm_p_area",
              "lsm_p_perim",
              "lsm_p_para",
              "lsm_p_enn")

l_metrics = c("lsm_l_np",
              "lsm_l_pd",
              "lsm_l_area_mn",
              "lsm_l_area_sd",
              "lsm_l_enn_mn",
              "lsm_l_enn_sd",
              "lsm_l_cohesion")

# canopy height variation

strata <- c(0, 1, 2, 10, 20, 50)



