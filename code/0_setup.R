##### metadata


##### packages

# need a line to install?

library(tidyverse)
library(hablar) # convert() function
library(lidR)
library(sf)
library(terra)
library(lidaRtRee)
library(landscapemetrics)
library(vectormetrics) # developmental


##### paths

path_data = "data/"

path_test_data = paste0(path_data, "test_data/")
path_test_data_las = paste0(path_test_data, "point_clouds/")
path_test_data_shp = paste0(path_test_data, "shapes/")

path_DASH_las = "/Workspace/Users/joseph.beesley@defra.onmicrosoft.com/ReForeSt_LiDAR_data/normalised"

path_outputs = "outputs/"
path_outputs_csv = paste0(path_outputs, "csv/")


##### constants

# gap analysis

gapHeight = 1 # units, m?
gapSize = 0.2 # units, ha?


