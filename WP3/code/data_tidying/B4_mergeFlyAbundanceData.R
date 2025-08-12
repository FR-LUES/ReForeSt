# This script merges the WrEN moth, cranefly, and hoverfly data 

library(tidyverse)


# Read in data ---- !#
hover <- read.csv("data/numerical_data/WrEN_Hoverflies_ab.csv")
crane <- read.csv("data/numerical_data/WrEN_Craneflies_ab.csv")



# Tidy data ---- !#
# Tidy hover fly data
# extract controls
hoverControls <- hover |>
  group_by(Site, Collection) |>
  summarise(Hover_trap_day = max(Jul_day))
# tidy data
hoverTidy <- hover |>
  filter(Country == "England") |>
  group_by(Site, Species) |>
  summarise(Count = sum(Count, na.rm = TRUE)) |>
  mutate(Taxa = "Hoverfly") |>
  rename("ID" = "Site")

# Tidy cranefly data
# extract controls
craneControls <- crane |>
  group_by(Site, Collection) |>
  summarise(crane_trap_day = max(Jul_day))
# Tidy data
craneTidy <- crane |>
  filter(Country == "England") |>
  group_by(Site, Species) |>
  summarise(Count = sum(Count, na.rm = TRUE))|>
  mutate(Taxa = "Cranefly") |>
  rename("ID" = "Site")

# # Tidy moth data, NO MOTHS FOR ENGLAND...
# mothControls <- moth |> select(Site_id, No.traps) |>
#   rename("Site" = "Site_id", "moth_no_traps" = "No.traps") |>
#   mutate(Site = as.character(Site))
# mothTidy <- moth |> pivot_longer(-c(Site_id, No.traps), values_to = "Count", names_to = "Species") |>
#   rename("Site" = "Site_id") |> select(Site, Species, Count) |> mutate(Taxa = "Moth")
# 
# 
# 
# 
# 



# Merge data and add control information ---- !#
masterAbundance <- rbind(hoverTidy, craneTidy)# |>
  #left_join(hoverControls, by = "Site") |> 
  #inner_join(craneControls, by = "Site") #|> 
  #inner_join(mothControls, by = "Site")






# Merge field and spatial data with abundance data ---- !#
dbh <- read.csv("data/numerical_data/masterDBH.csv")
understory <- read.csv("data/numerical_data/WrEN_understoryCover.csv") |>
  group_by(Site) |> summarize(meanUnderstoryCover = mean(Under.cover))
masterAbundanceStructure <- masterAbundance |>
  left_join(dbh, by = c("ID")) |>
  left_join(understory, by = c("ID" = "Site"))
  



write.csv(masterAbundanceStructure, "data/numerical_data/masterFlyingAbundance.csv")
