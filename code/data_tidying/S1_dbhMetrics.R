# This script calculates dbh metrics for nc and ftc to match the WrEN data
library(tidyverse)

# Read in dbh data
wren <- read.csv("data/numerical_data/wren_dbh.csv")
ftc <- read.csv("data/numerical_data/ftc_dbh.csv") |>
  mutate(dbh = as.numeric(dbh))
nc <- read.csv("data/numerical_data/nc_dbh.csv")

# summarize ftc dbh data to match WrEN data
ftcSum <- ftc |>
  mutate(dbh = as.numeric(dbh)) |>
  group_by(ID) |>
  summarize(stemNumber = length(dbh),
            numberPlots = length(unique(plotID)),
            dbhMean = round(mean(dbh, na.rm = TRUE), 1),
            dbhSD = round(sd(dbh, na.rm = TRUE), 1)) |>
  mutate(stemDensityHA = round((stemNumber / 60) * 10000, 0)) |>
  select(-c(stemNumber, numberPlots))

# Summarize nc dbh data to match WrEN data
ncSum <- nc |>
  mutate(dbh = as.numeric(dbh)) |>
  group_by(ID) |>
  summarize(stemNumber = length(dbh),
            numberPlots = length(unique(plotID)),
            dbhMean = round(mean(dbh, na.rm = TRUE), 1),
            dbhSD = round(sd(dbh, na.rm = TRUE), 1)) |>
  mutate(stemDensityHA = round((stemNumber / 314) * 10000, 0)) |>
  select(-c(stemNumber, numberPlots))

# Remove columns from wren data to make it match
wrenSum <- wren |> group_by(ID) |>
  summarize(stemDensityHA = mean(treeDensity),
            dbhMean = mean(dbhMean, na.rm = TRUE),
            dbhSD = mean(dbhSD, na.rm = TRUE)) |>
  select(ID, stemDensityHA, dbhMean, dbhSD)

# Combine data and save
masterDBH <- rbind(wrenSum, ftcSum, ncSum)
write.csv(masterDBH, "data/numerical_data/masterDBH.csv")

