source("WP5/code/0_setup.R")
source("WP6/code/0_setup.R")
source("WP5/code/1_functions.R")

# ----- read in management history -----

df_management <-
  read.csv(paste0(path_livinglayers, "living_layers_management_FINAL.csv")) %>% 
  drop_na()


# ----- property shapefiles -----

properties <- unique(df_management$Property.ID)

prop_boundaries <- 
  st_read(path_labShapefiles) %>% 
  st_transform(crs = st_crs(27700)) %>% 
  filter(PROPERTYID %in% properties)


# ----- dates of LiDAR data for each property -----

nlp_catalog <- read_sf("Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_Data/nlp_catalog_shapefile/nlpCat_22_24_merged.shp")

# Spatial join region of interest and OS tiles
polygon_ids <- st_join(prop_boundaries, nlp_catalog)
nlp_summary <-
  polygon_ids %>%
  as_tibble() %>% 
  group_by(PROPERTYID, YEAR) %>% 
  tally()

print(nlp_summary)

# All sites have 2019 data only - no repeat data
