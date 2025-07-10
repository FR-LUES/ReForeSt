source("code/Analysis/0_setup.R")

# Read in the data ---- !#
structure <- read.csv(structure_path) |>
  select(ID, mean30mEffCan, gap_prop)
plants <- read.csv(plant_path) |>
  select(ID, Type, Age,
         spp, sppWoodland, sppSpecialist,
         sppGeneralist, Source, 
         )
glimpse(plants)
