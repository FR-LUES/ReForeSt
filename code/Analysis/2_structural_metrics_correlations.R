source("code/Analysis/0_setup.R")
# This script explores correlations between structural variables to identify redundancies

# Plot a correlation matrix ---- !#
structure |>
  inner_join(plants, by = "ID") |>
  select(siteEffCan, mean30mEffCan, gap_prop, dbhSD, spp) |>
  ggpairs()

