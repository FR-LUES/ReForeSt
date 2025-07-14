source("code/Analysis/0_setup.R")
View(plantData)
# Merge data ---- !#
plantData <- structure |>
  inner_join(plants, by = "ID") |>
  inner_join(landscape, by = "ID")

# Build model paths ---- !#
# Total species richness response
sppResponse <- bf(spp ~ mean30mEffCan + gap_prop + area_ha + Age + Type + Source)









# Run models ---- !#
sppModel <- brm(sppResponse,
                family = poisson(),
                data = plantData,
                chains = 4, 
                iter = 4000,
                sample_prior = "yes"
                )
