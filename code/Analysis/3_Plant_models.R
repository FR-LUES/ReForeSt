source("code/Analysis/0_setup.R")
source("code/analysis/1_Functions.R")


# Merge data ---- !#
plantData <- structure |>
  inner_join(plants, by = "ID") |># merge plant data with structure data
  inner_join(landscape, by = "ID") |># merge with landscape data
  mutate(gap_prop = betaSqueeze(gap_prop),# squeeze gap proportion to makesure values aren't 0 or 1
         dbhSD = dbhSD + 0.001,
         Age = as.numeric(Age)) |>  # So that dbhSD can be modelled as Gamma
  filter(!(Type == "Mature" & Source == "NC"))# Filter out mature NC woodlands









# Create model combinations ---- !#
# Group response models
responses <- c(
  "spp",
  "sppWoodland",
  "sppSpecialist"
)


# Find all possible model combinations
combos <- expand_grid(resp = responses,
            med = mediation_variants,
            constants  = paste(c("area_ha", "Age * Type", "Source"),
                               collapse = " + "))

modelNames <- map(1:nrow(combos),
                  function(x) paste0(combos$resp[x], " ~ ", combos$med[x]))








# Run the models ---- !#
plantModels <-  map(1:nrow(combos), function(x) {
    
    resp_name <- combos$resp[x]
    med_name <- combos$med[x]

    # Create bfs
    responseBF <- bf(as.formula(paste0(resp_name, "~", med_name, "+", combos$constants[x])),
                     family = poisson(link = "log"))
    
    
    
    # Chose priors
    modelPriors <- make_priors(include_dbhSD = grepl("dbhSD",  combos$med[x]),
                               include_mean30mEffCan = grepl("mean30mEffCan",combos$med[x]),
                               include_gap_prop = grepl("gap_prop", combos$med[x]),
                               respo = resp_name)
    
    
    formulas <- c(list(responseBF), mediator_bfs) |>
      as.list() |>
      reduce(`+`)
    
    modelFunction(form = formulas,
                  data = plantData,
                  priors = modelPriors)
    
    
  })

# assign names to models
names(plantModels) <- modelNames

# Save models
saveRDS(plantModels, "data/numerical_data/plantModels.rds")
