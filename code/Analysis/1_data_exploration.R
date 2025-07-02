source("code/Analysis/0_setup.R")

# read in data
structure <- read.csv(structure_path)
plant <- read.csv(plant_path)


# Merge data
df <- left_join(plant, structure, by = "ID")

# View relationships
sppVar <- df$sppWoodland
df  |> select(spp, stemDensityHA, dbhMean, dbhSD,
              area_ha, siteEffCan, mean10mEffCan, 
              sd10mEffCan, mean30mEffCan, sd30mEffCan,
              gap_prop, patch_den, , area_mn,
              area_sd, cohesion, glcmEntropy_mean, glcmEntropy_sd,
              glcmContrast_mean, glcmContrast_sd) |>
  pivot_longer(-c(spp), names_to = "Variable", values_to = "Value") |>
  ggplot(aes(x = Value, y = spp))+
  geom_point()+
  facet_wrap(~Variable, scales = "free")+
  theme_classic()
