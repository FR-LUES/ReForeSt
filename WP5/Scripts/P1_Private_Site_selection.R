library(tidyverse)
library(sf)
library(lubridate)

# Read in data ---- !#
# Management data
fell <- st_read("Shapes/Management_shapes/Felling_Licence_Applications_England.shp") |>
  mutate(date_appro = as.Date(date_appro),
         date_expir = as.Date(date_expir)) |>
  filter(!(FEATDESC %in% c("Single tree", "1", "3", "Refused FLA")) &
           date_appro >= as.Date("2010-01-01") &
           date_appro <= as.Date("2018-12-31") &
           date_expir <= as.Date("2020-01-01"))

# manage <- st_read("Shapes/Management_shapes/Forestry_England_Management_Coupes.shp") |>
#   filter(management == "Group selection") |> st_make_valid()

# NFI data
nfi <- st_read("Shapes/Support_shapes/National_Forest_inventory_England_2023.shp") |>
  filter(IFT_IOA %in% c("Broadleaved", "Mixed mainly broadleaved"))

# Grant scheme data
wgs <- st_read("Shapes/Management_shapes/EWGS.shp") |>
  mutate(DateApprv = as.POSIXct(DateApprv / 1000, origin = "1970-01-01", tz = "UTC")) |>
  filter(c(WIG == "Y" | WMG == "Y") &
           DateApprv >= as.Date("2010-01-01")  &
           DateApprv <= as.Date("2020-12-31") &
           CurrStat == "Closed")


# Read in scan counts
scans <- st_read("Shapes/LiDAR_shapes/Repeat_Lidar_Survey_Count.shp") |>
  mutate(areaHA = Shape_Area / 10000) |>
  filter(Srvy_Count > 2 & areaHA >= 10)



# Intersect fell sites by lidar scans ---- !#
# Subset fell licences to only broadleaves
fellSubset <- fell[st_intersects(fell, nfi) |> lengths() > 0, ]
# Find areas with management grants
fellSubset <- fellSubset[st_intersects(fellSubset, wgs) |> lengths() > 0, ] |>
  st_join(wgs, largest = TRUE)
#select only fell licences which had management grant
fellSubset <- fellSubset[st_within(fellSubset, scans) |> lengths() > 0,]
st_write(fellSubset, "Shapes/fellSubset.shp")
write.csv(st_drop_geometry(fellSubset), "Data/fellSubset.csv")


fellSubset <- st_read("Shapes/fellSubset.shp")
felldf <- read.csv("Data/fellSubset.csv")

fellSubset <- fellSubset |> filter(OBJECTID %in% felldf$OBJECTID)
