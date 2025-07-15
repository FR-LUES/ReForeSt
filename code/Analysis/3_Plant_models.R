source("code/Analysis/0_setup.R")

# Merge data ---- !#
plantData <- structure |>
  inner_join(plants, by = "ID") |>
  inner_join(landscape, by = "ID")

# Build model paths ---- !#
# Total species richness response
sppResponse <- bf(spp ~ medVar1 + medVar2 + medVar3 + area_ha + Age + Type + Source)



plot(plantData$Type, plantData$spp)


View(plantData)



# Run models ---- !#
sppModel <- brm(sppResponse,
                family = poisson(),
                data = plantData,
                chains = 4, 
                iter = 4000,
                sample_prior = "yes"
                )
