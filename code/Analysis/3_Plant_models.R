source("code/Analysis/0_setup.R")









# Create model combinations ---- !#
# Group response models
responses <- c(
  "spp",
  "sppWoodland",
  "sppSpecialist"
)


# Find all possible model combinations
combos <- expand_grid(resp = responses,
            med = plantModelVariants,
            constants  = paste(c("area_ha", "Age * Type", "Source"),
                               collapse = " + "))
# Extract model names
modelNames <- map(1:nrow(combos),
                  function(x) paste0(combos$resp[x], " ~ ", combos$med[x]))






# Run the models ---- !#
plantModels <-  map(1:nrow(combos), function(x) {
    #x <- 1
    resp_name <- combos$resp[x]
    med_name <- combos$med[x]

    # Create formula
    responseF <- as.formula(paste0(resp_name, "~", med_name, "+", combos$constants[x]))
    
    # Run model
    glm(responseF, family = poisson(link = "log"), data = plants)
    
  })

# assign names to models
names(plantModels) <- modelNames

# Save models
saveRDS(plantModels, "data/numerical_data/plantModels.rds")
