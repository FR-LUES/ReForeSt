# This script merges the WrEN beetle and spider data

library(tidyverse)


# Read in data ---- !#
beetle <- read.csv("data/numerical_data/Beetles_ab.csv")
spider <- read.csv("data/numerical_data/Spiders_ab.csv")
ftcCrawler <- read.csv("data/numerical_data/FTC_crawler.csv")





# Tidy data ---- !#
# Tidy beetle fly data
# extract controls
beetleControls <- beetle |>
  select(Site_ID, No_of_traps) |>
  group_by(Site_ID) |>
  summarise(no_traps = max(No_of_traps)) |>
  rename("ID" = "Site_ID")
#Tidy data
beetleTidy <- beetle |>
  filter(Country == 1) |>
  group_by(Site_ID, Species) |>
  summarise(Count = sum(Species_occ)) |>
  select(Site_ID, Species, Count) |>
  mutate(Order = "Coleoptera",
         Source = "WrEN",
         Type = "PL") |>
  rename("ID" = "Site_ID")


# Tidy data
spiderTidy <- spider |> filter(Country == 1) |>
  group_by(Site_ID, Species) |>
  summarise(Count = sum(Species_occ)) |>
  select(Site_ID, Species, Count) |>
  mutate(Order = "Araneae",
         Source = "WrEN",
         Type = "PL") |>
  rename("ID" = "Site_ID")


# ftc Tidy
# Extract controls
ftcControls <- ftcCrawler |>
  group_by(ID) |>
  summarise(no_traps = length(unique(Plot)))
# tidy data
ftcTidy <- ftcCrawler |>
  group_by(ID, Order, Species, Type) |>
  summarise(Count = sum(Count)) |>
  mutate(Source = "FTC")
  

# Merge data and add control information ---- !#
masterAbundance <- rbind(beetleTidy, spiderTidy, ftcTidy)
controls <- rbind(beetleControls, ftcControls)
masterAbundance <- masterAbundance |>
  left_join(controls, by = "ID")#|>
  #filter(!is.na(Site))#|> 
#inner_join(mothControls, by = "Site")



# Merge field and spatial data with abundance data ---- !#
dbh <- read.csv("data/numerical_data/masterDBH.csv") |>
  select(-c(X))

masterAbundanceStructure <- masterAbundance |>
  left_join(dbh, by = "ID")


write.csv(masterAbundanceStructure, "data/numerical_data/masterCrawlingAbundance.csv")
 