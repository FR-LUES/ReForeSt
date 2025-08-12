# This script is to merge the shapefiles of the WrEN, NC, and Fast tracking projects

library(sf)
library(tidyverse)

# Read in the shapefiles
wren <- st_read("Shapefiles/sites/WrEN_AW_sites.shp")# WrEN
nc <- st_read("Shapefiles/sites/Natural_Colonisation_Sites.shp")# Natural colonisation
ftc <- st_read("Shapefiles/sites/Sites_meta.gpkg")# Fast tracking

plot(ftc[c(3),])
# Tidy WrEN data
wren <- wren |>
  filter(Country == "England") |>
  select(SITE_ID) |>
  st_zm(drop = TRUE,
        what = "ZM") |>
  mutate(source = "WrEN") |>
  rename("ID" = "SITE_ID")

# Tidy NC data
nc <- nc |>
  select(SiteID) |>
  mutate(source = "NC") |>
  rename("ID" = "SiteID")

# Tidy ftc data
ftc <-  ftc |>
  st_transform(crs = st_crs(27700)) |>
  st_zm(drop = TRUE,
        what = "ZM") |>
  filter(Habtiat %in% c("Mature", "Planted")) |>
  select(layer)|>
  mutate(source = "FTC") |>
  rename("ID" = "layer") 


# Join shapefiles and save
master <- rbind(wren, nc, ftc)
st_write(master, "Shapefiles/ReForeSt_shapes.gpkg")  
  