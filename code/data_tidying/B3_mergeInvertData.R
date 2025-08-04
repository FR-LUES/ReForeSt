# This script merges the invert data of WrEN, NC, and FTC with their respective dbh data 

# Landscape variables are merged
# LiDAR metrics are merged
library(tidyverse)
library(sf)


### MERGE DBH DATA ##########
dbh <- read.csv("data/numeric_data/masterDBH.csv")

# Join plant and dbh data
masterInvert <- read.csv("data/numeric_data/masterInvert.csv") |>
  left_join(dbh, by = "ID")

### MERGE LANDSCAPE VARIABLES #####
lsVars <- st_read("data/shapefiles/ReforeSt_shapes.gpkg")

# join landscape variables to plant data
masterInvert <- inner_join(masterInvert, st_drop_geometry(lsVars), by = c("ID" = "ID", "Source" = "Source"))


# Merge age information #####
plant <- read.csv("data/plant/masterPlant.csv")
masterInvert <- inner_join(masterInvert, plant[, c("Age", "ID")], by = "ID")
# save data for now
write.csv(masterInvert, "data/numeric_data/masterInvert.csv")
View(masterInvert)
