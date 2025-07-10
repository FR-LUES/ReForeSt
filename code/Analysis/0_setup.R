# Packages
library(tidyverse)
library(GGally)
library(lavaan)

# Paths
# Data path
num_data_path <- "data/numerical_data/"
# Output paths
path_output <- "outputs/"
# Plant data
plant_path <- paste0(num_data_path, "masterPlant.csv")
# structure data
structure_path <- paste0(path_output, "masterMetrics_df.csv")
