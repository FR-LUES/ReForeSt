source("code/Analysis/0_setup.R")





# Create model combinations ---- !#
# Group response models
responses <- c(
  "q0Log",
  "q1Log",
  "q2Log",
  "logAbund"
)


# Find all possible model combinations
combos <- expand_grid(resp = responses,
                      med = crawlModelVariants,# same model varients as plants
                      constants  = paste(c("area_ha", "Age"),
                                         collapse = " + "))
# Extract model names
modelNames <- map(1:nrow(combos),
                  function(x) paste0(combos$resp[x], " ~ ", combos$med[x]))






crawlerModels <-  map(1:nrow(combos), function(x) {
  #x <- 1
  resp_name <- combos$resp[x]
  med_name <- combos$med[x]
  
  # Create formula
  responseF <- as.formula(paste0(resp_name, "~", med_name, "+", combos$constants[x]))
  
  # Run model
  glm(responseF, data = crawler)
  
})



crawlerModels[[1]]



# assign names to models
names(crawlerModels) <- modelNames

# Save models
saveRDS(crawlerModels, "data/numerical_data/crawlerModels.rds")
