source("code/Analysis/0_setup.R")
# This script explores correlations between structural variables to identify redundancies

# Read in the structural data ---- !#
structure <- read.csv(structure_path)


# Plot a correlation matrix ---- !#
structure |>
  select(siteEffCan, mean30mEffCan, gap_prop,
         patch_den, cohesion, area_mn,
         glcmContrast_mean, glcmEntropy_mean) |>
  ggpairs(structure[, -c(1)])




# View relationships

df  |> select(spp, stemDensityHA, dbhMean, dbhSD,
              area_ha, siteEffCan, mean10mEffCan, 
              sd10mEffCan, mean30mEffCan, sd30mEffCan,
              gap_prop, patch_den, , area_mn,
              area_sd, cohesion, glcmEntropy_mean, glcmEntropy_sd,
             glcmContrast_mean, glcmContrast_sd) |> pairs()
  
  
  pivot_longer(-c(spp), names_to = "Variable", values_to = "Value") |>
  ggplot(aes(x = Value, y = spp))+
  geom_point()+
  facet_wrap(~Variable, scales = "free")+
  theme_classic()
