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
         dbhSD, no.Plots, area_ha)|>
  mutate(sampleArea = case_when(Source == "WrEN" ~ area_ha  |> round(3),
                                Source != "WrEN" ~ (no.Plots * 4) / 10000 |> round(3))#,
        # spp = round(spp/sampleArea, 3),
         #sppWoodland = round(sppWoodland/sampleArea, 3),
         #sppSpecialist = round(sppSpecialist/sampleArea, 3)# Convert species richness data to densities
  )
landscape <- st_read(shapes_path) |> # Landscape variables
  select(ID, bl500_m, aw500_m,
         nearestBL, nearestAW
  ) |>
  st_drop_geometry()










# Mediation models ---- !#
medVar1 <- "dbhSD"
medVar2 <- "mean30mEffCan"
medVar3 <- "gap_prop"
predMedVar1 <- "Age * Type + Source"

medMod1 <- bf(as.formula(paste0(medVar1, "~", predMedVar1)), family = Gamma(link = "log"))
medMod2 <- bf(as.formula(paste0(medVar2, "~", predMedVar1)), family = Gamma(link = "log"))
medMod3 <- bf(as.formula(paste0(medVar3, "~", predMedVar1)), family = Beta(link = "logit"))

# Group mediator models
mediator_bfs <- list(
  medMod1,
  medMod2,
  medMod3
)

# Mediation variants for predicting species response as we want to test if field derived, LiDAR derived, or combined is best
mediation_variants <- c(
  "dbhSD",
  "mean30mEffCan + gap_prop",
  "dbhSD + mean30mEffCan + gap_prop"
)









