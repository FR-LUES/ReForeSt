##### metadata


##### packages

# need a line to install?

library(tidyverse)
library(lidR)
library(sf)
library(terra)
library(lidaRtRee)


##### paths

path_data = "data/"

path_test_data = paste0(path_data, "test_data/")
path_test_data_las = paste0(path_test_data, "point_clouds/")
path_test_data_shp = paste0(path_test_data, "shapes/")
path_test_data_chm = paste0(path_test_data, "chms/")

path_DASH_las = "/Workspace/Users/joseph.beesley@defra.onmicrosoft.com/ReForeSt_LiDAR_data/normalised"

path_outputs = "outputs/"


##### constants

# gap function
gapHeight <- 1
gapSize <- 5
strata <- c(0, 1, 2, 10, 20, 50)


