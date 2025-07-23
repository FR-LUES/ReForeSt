source("code/Analysis/0_setup.R")
source("code/analysis/1_Functions.R")



invertData <- inverts |>
  inner_join(structure, by = "ID") |>
  mutate(stemDensityHA = stemDensityHA + 0.001,
         dbhSD = dbhSD + 0.001) # Making sure works with gamma dist








# Create model combinations ---- !#
# Group response models
responses <- c(
  "Hoverflyrichness",
  "Cranefliesrichness",
  "Mothrichness"
)


# Find all possible model combinations
combos <- expand_grid(resp = responses,
                      med = invert_mediation_variants,
                      constants  = paste(c("area_ha", "Age * Type", "Source", "bl500_m"),
                                         collapse = " + "))

modelNames <- map(1:nrow(combos),
                  function(x) paste0(combos$resp[x], " ~ ", combos$med[x]))








# Run the models ---- !#
invertModels <-  map(1:nrow(combos), function(x) {
  
  resp_name <- combos$resp[x]
  med_name <- combos$med[x]
  
  # Create bfs
  responseBF <- bf(as.formula(paste0(resp_name, "~", med_name, "+", combos$constants[x])),
                   family = poisson(link = "log"))
  
  
  
  # Chose priors
  modelPriors <- make_priors(include_dbhSD = grepl("dbhSD",  combos$med[x]),
                             include_mean30mEffCan = grepl("mean30mEffCan",combos$med[x]),
                             include_gap_prop = grepl("gap_prop", combos$med[x]),
                             include_stem_dens = grepl("stemDensityHA", combos$med[x]),
                             respo = resp_name)
  
  
  formulas <- c(list(responseBF), invert_mediator_bfs) |>
    as.list() |>
    reduce(`+`)
  
  modelFunction(form = formulas,
                data = invertData,
                priors = modelPriors)
  
  
})

# assign names to models
names(plantModels) <- modelNames

# Save models
saveRDS(plantModels, "data/numerical_data/invertModels.rds")