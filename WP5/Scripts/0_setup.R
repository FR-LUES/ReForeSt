library(tidyverse)
library(sf)


# Folder paths ---- !#
path_supportShapes <- "Shapes/Support_shapes/"
path_managementShapes <- "Shapes/Management_shapes/"







# Read in mangaement data and tidy ---- !#
# Read in and tidy shapefiles ---- !#
dean <- st_read(paste0(path_supportShapes,
                       "Dean.shp"))# Forest of dean boundaries
coupe <- st_read(paste0(path_managementShapes,
                        "management_coupe.gpkg"))# Read in forest of dean management coupe
sub <- st_read(paste0(path_managementShapes,
                      "dean_subcompartment.gpkg"))# Read in sub-compartment info
# fix column names
colnames(sub) <- sub("^subCompartment\\.\\.\\.INV_COMPDATA_",
                         "",
                         colnames(sub)) # fix names
comp <- read.csv(paste0(path_managementShapes, "deanComponents.csv"))# read in component information

# join management coupe data to subcompartment data
dean_management <- st_join(sub, coupe[, c("management_prescription")], largest = TRUE)
deanSub <- inner_join(dean_management, comp[ , c("rel_fw_guid", "last_thinned",
                       "selection_type", "spis",
                       "areap", "plyr")],
                      by = c("fw_guid" = "rel_fw_guid")) |>
  filter(!is.na(last_thinned) & areap == 100) |>
  select(scpt, cpmt, management_prescription, last_thinned, selection_type, spis, plyr) |>
  rename("species" = "spis")
  colnames(sub)

#st_write(deanSub, paste0(path_managementShapes, "dean_subcompartment_merged.gpkg"))



