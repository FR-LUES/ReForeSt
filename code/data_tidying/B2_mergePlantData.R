# This script merges the ground flora data from WrEN, NC, and FTC
# The DBH data is then merged with the plant data
# Landscape variables are merged
# LiDAR metrics are merged
library(tidyverse)
library(sf)

## MERGE PLANT DATA##########
# Read in data
wren <- read.csv("data/numerical_data/WrENPlantData.csv")# WrEN data
nc <- read.csv("data/numerical_data/NCplantData.csv")# NC data
ftc <- read.csv("data/numerical_data/FTCplantData.csv") |>
  filter(Tree != 1) |> mutate(Age = case_when(Type == "Mature" ~ 250,
                                              .default = 25))# FTC data



# Summarize wren data by site
wrenSum <- wren |>
  group_by(SiteID, Type, Age) |>
  summarise(
    spp = length(unique(Latin.name)),
    sppWoodland = sum(!(h.Code == "Non-woodland")),
    sppGeneralist = sum(h.Code == "Generalist"),
    sppSpecialist = sum(h.Code == "Specialist"),
    .groups = "drop") |> rename("ID" = "SiteID") |>
  mutate(Source = "WrEN")

# Summarize NC data
ncSum <- nc |>
  group_by(ID, Type, Age) |>
  summarise(
    spp = length(unique(Latin.name)),
    sppWoodland = sum(!(h.Code == "Non-woodland")),
    sppGeneralist = sum(h.Code == "Generalist"),
    sppSpecialist = sum(h.Code == "Specialist"),
    .groups = "drop")|>
  mutate(Source = "NC")

# Summarize ftc data
ftcSum <- ftc |> group_by(Age, Source, Type, ID) |>
  summarise(
    spp = length(unique(Latin.name)),
    sppWoodland = sum(!(h.Code == "Non-woodland")),
    sppGeneralist = sum(h.Code == "Generalist"),
    sppSpecialist = sum(h.Code == "Specialist"),
    .groups = "drop")

# Bind all the plant data
masterPlant <- rbind(wrenSum, ncSum, ftcSum)
      
### MERGE DBH DATA ##########
dbh <- read.csv("data/numerical_data/masterDBH.csv") |>
  select(!c(X)) |>
  group_by(ID) |>
  summarize(stemDensityHA = mean(stemDensityHA),
            dbhSD = mean(dbhSD))

# Join plant and dbh data
masterPlant <- left_join(masterPlant, dbh, by = "ID")



# save data for now
write.csv(masterPlant, "data/numerical_data/masterPlant.csv")
