# Packages
library(tidyverse)
library(brms)
library(sf)
library(GGally)







# Paths ---- !#
# Data path
num_data_path <- "data/numerical_data/"
# Output paths
path_output <- "outputs/"
# Shapefile path
shapes_path <- "data/shapefiles/ReForeSt_shapes.gpkg"

# Plant data
plant_path <- paste0(num_data_path, "masterPlant.csv")
# structure data
structure_path <- paste0(path_output, "masterMetrics_df.csv")










# Read in and tidy the data ---- !#
structure <- read.csv(structure_path) |># Structural data
  select(ID, mean30mEffCan, gap_prop, siteEffCan)
plants <- read.csv(plant_path) |> # Plant data
  select(ID, Type, Age,
         spp, sppWoodland, sppSpecialist,
         sppGeneralist, Source,
         dbhSD
  )
landscape <- st_read(shapes_path) |> # Landscape variables
  select(ID, bl500_m, aw500_m,
         nearestBL, nearestAW, area_ha
  ) |>
  st_drop_geometry()





# Mediation models ---- !#
medVar1 <- "sdDBH"
medVar2 <- "mean30mEffCan"
medVar3 <- "gap_prop"
predMedVar1 <- "Age"

medMod1 <- bf(as.formula(paste0(medVar1, "~", predMedVar1)))
medMod2 <- bf(as.formula(paste0(medVar2, "~", predMedVar1)))
medMod3 <- bf(as.formula(paste0(medVar3, "~", predMedVar1)))



# Priors --- !#
# We set the priors for all mediation models in our analysis scripts


