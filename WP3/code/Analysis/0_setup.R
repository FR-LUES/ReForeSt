source("WP3/code/Analysis/1_Functions.R")

# Packages
library(tidyverse)
library(brms)
library(sf)
library(GGally)
library(glmm)
library(sjPlot)
library(ggthemes)
library(officer)
library(rvg)





# Paths ---- !#
wpPath <- "WP3/"
# Data path
num_data_path <- paste0(wpPath, "data/numerical_data/")
# Output paths
path_output <- paste0(wpPath,"outputs/")
# Shapefile path
shapes_path <- paste0(wpPath,"data/shapefiles/ReForeSt_shapes.gpkg")

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
  select(ID, mean30mFHD_gaps, gap_prop, ttops_den_las)
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
         Age = as.numeric(Age), # Make age numeric and mark mature woodlands as 250 yo
         Type = factor(Type, levels = c("NC", "PL", "Mature"))) |># Change reference level of type
  select(ID, Type, Age,
         spp, sppWoodland, sppSpecialist,
         sppGeneralist, Source,
         dbhSD, stemDensityHA) |>
  inner_join(structure, by = "ID") |># merge plant data with structure data
  inner_join(landscape, by = "ID") |># merge with landscape data
  filter(!(Type == "Mature" & Source == "NC"))# Filter out mature NC woodlands as not sampled properly
# Ground crawling inverts (Spiders and beetles only)
crawler <- read.csv(crawler_path) |>
  na.omit(Count)|>
  group_by(ID, Source, Type) |>
  summarise(q1 = hill_number(Count, 1),
            q0 = hill_number(Count, 0),# calculate hill numbers
            q2 = hill_number(Count, 2),
            abund = hill_number(Count, "abund"),
            stemDensity = mean(stemDensityHA, na.rm = TRUE),
            dbhSD = mean(dbhSD, na.rm = TRUE)) |>
  left_join(structure, by = "ID") |>
  left_join(landscape[, c("ID", "area_ha")], by = "ID") |>
  left_join(plants[, c("ID", "Age")], by = "ID") |>
  mutate(q0Log = log(q0+1),
         q1Log = log(q1+1),
         q2Log = log(q2 +1),
         logAbund = log(abund+1))

# Flying inverts (Hove and crane flies only)
flies <- read.csv(flyer_path) |>
  na.omit(Count) |>
  group_by(ID) |>
  summarise(q1 = hill_number(Count, 1),
            q0 = hill_number(Count, 0),# calculate hill numbers
            q2 = hill_number(Count, 2),
            abund = hill_number(Count, "abund"),
            dbhSD = mean(dbhSD, na.rm = TRUE),
            understoryCover = mean(meanUnderstoryCover, na.rm = TRUE)) |>
  left_join(structure, by = "ID") |>
  left_join(landscape[, c("ID", "area_ha")], by = "ID") |>
  left_join(plants[, c("ID", "Age")], by = "ID") |>
  mutate(q0Log = log(q0+1),
         q1Log = log(q1+1),
         q2Log = log(q2 +1),
         logAbund = log(abund+1))








# Create model combinations ---- !#
# Define predictors
lid1 <- " gap_prop "
lid2 <- " mean30mFHD_gaps "
lid3 <- " ttops_den_las "

field1 <- " dbhSD "
field2 <- " stemDensity "
field3 <- " understoryCover "
# plant models
plantModel1 <- paste0(c(field1, lid1, lid2), collapse = "+")
plantModel2 <- paste0(c(lid1, lid2), collapse = "+")
plantModel3 <- paste0(field1)
plantModelVariants <- c(plantModel1, plantModel2, plantModel3)


# crawler models
crawlModel1 <- paste0(c(field2, lid1, lid2, lid3), collapse = "+")
crawlModel2 <- paste0(c(lid1, lid2, lid3), collapse = "+")
crawlModel3 <- paste0(field2)
crawlModelVariants <- c(crawlModel1, crawlModel2, crawlModel3)

# Fly models
flyModel1 <- paste0(c(field1, field3, lid1, lid2), collapse = "+")
flyModel2 <- paste0(c(lid1, lid2), collapse = "+")
flyModel3 <- paste0(c(field1, field3), collapse = "+")
flyModelVariants <- c(flyModel1, flyModel2, flyModel3)


