source("code/Analysis/1_Functions.R")

# Packages
library(tidyverse)
library(brms)
library(sf)
library(GGally)
library(glmm)








# Paths ---- !#
# Data path
num_data_path <- "data/numerical_data/"
# Output paths
path_output <- "outputs/"
# Shapefile path
shapes_path <- "data/shapefiles/ReForeSt_shapes.gpkg"

# Plant data
plant_path <- paste0(num_data_path, "masterPlant.csv")
#Invert data
invert_path <- paste0(num_data_path, "masterInvert.csv")
# Crawler abundance path
crawler_path <- paste0(num_data_path, "masterCrawlingAbundance.csv")
# Flying abundance path
flyer_path <- paste0(num_data_path, "masterFlyingAbundance.csv")
# Structure data
structure_path <- paste0(path_output, "masterMetrics_df.csv")










# Read in and tidy the data ---- !#
# Structural data (dbh is already merged with species data)
structure <- read.csv(structure_path) |>
  select(ID, mean30mEffCan, gap_prop, siteEffCan)
# Landscape variables
landscape <- st_read(shapes_path) |> 
  select(ID, bl500_m, aw500_m,
         nearestBL, nearestAW, area_ha
  ) |>
  st_drop_geometry()
# Plant data
plants <- read.csv(plant_path) |>
  mutate(Age = case_when(Age == "Mature" ~ "250",
                         .default = Age),
         Age = as.numeric(Age)) |># Make age numeric and mark mature woodlands as 250 yo
  select(ID, Type, Age,
         spp, sppWoodland, sppSpecialist,
         sppGeneralist, Source,
         dbhSD, stemDensityHA) |>
  inner_join(structure, by = "ID") |># merge plant data with structure data
  inner_join(landscape, by = "ID") |># merge with landscape data
  filter(!(Type == "Mature" & Source == "NC"))# Filter out mature NC woodlands as not sampled properly
# Ground crawling inverts (Spiders and beetles only)
crawler <- read.csv(crawler_path) |>
  na.omit(Count) |>
  filter(Source == "WrEN")|>
  group_by(ID, Source, Type) |>
  summarise(q1 = hill_number(Count, 1),
            q0 = hill_number(Count, 0),# calculate hill numbers
            q2 = hill_number(Count, 2),
            abund = hill_number(Count, "abund"),
            stemDensity = mean(stemDensityHA, na.rm = TRUE),
            dbhSD = mean(dbhSD, na.rm = TRUE)) |>
  left_join(structure, by = "ID") |>
  left_join(landscape[, c("ID", "area_ha")], by = "ID") |>
  left_join(plants[, c("ID", "Age")], by = "ID")
# Flying inverts (Hove and crane flies only)
flies <- read.csv(flyer_path) |>
  na.omit(Count) |>
  group_by(ID) |>
  summarise(q1 = hill_number(Count, 1),
            q0 = hill_number(Count, 0),# calculate hill numbers
            q2 = hill_number(Count, 2),
            abund = hill_number(Count, "abund"),
            stemDensity = mean(stemDensityHA, na.rm = TRUE),
            dbhSD = mean(dbhSD, na.rm = TRUE)) |>
  left_join(structure, by = "ID") |>
  left_join(landscape[, c("ID", "area_ha")], by = "ID") |>
  left_join(plants[, c("ID", "Age")], by = "ID")










# Mediation models ---- !#
medVar1 <- "dbhSD"
medVar2 <- "mean30mEffCan"
medVar3 <- "gap_prop"
invertMed1 <- "stemDensityHA" # Only used in invert models
predMedVarPlants <- "Age * Type + Source"
predMedVarInverts <- "Age * Type" # Type and Source completely overlap for inverts

medMod1 <- bf(as.formula(paste0(medVar1, "~", predMedVarPlants)), family = Gamma(link = "log"))
medMod2 <- bf(as.formula(paste0(medVar2, "~", predMedVarPlants)), family = Gamma(link = "log"))
medMod3 <- bf(as.formula(paste0(medVar3, "~", predMedVarPlants)), family = Beta(link = "logit"))
medMod4 <- bf(as.formula(paste0(invertMed1, "~", predMedVarInverts)), family = Gamma(link = "log"))

# Group mediator models
plant_mediator_bfs <- list(
  medMod1,
  medMod2,
  medMod3
)
invert_mediator_bfs <- list(medMod1,
                            medMod2,
                            medMod3,
                            medMod4)

# Mediation variants for predicting species response as we want to test if field derived, LiDAR derived, or combined is best
plant_mediation_variants <- c(
  "dbhSD",
  "mean30mEffCan + gap_prop",
  "dbhSD + mean30mEffCan + gap_prop"
)

invert_mediation_variants <- c(
  "dbhSD + stemDensityHA",
  "mean30mEffCan + gap_prop",
  "dbhSD + stemDensityHA + mean30mEffCan + gap_prop"
)









