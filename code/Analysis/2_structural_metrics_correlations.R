source("code/Analysis/0_setup.R")
# This script explores correlations between structural variables to identify redundancies

# Plot a correlation matrix ---- !#
structure |>
  select(siteEffCan, mean30mEffCan, gap_prop,
         patch_den, cohesion, area_mn,
         glcmContrast_mean, glcmEntropy_mean) |>
  ggpairs(structure[, -c(1)])

