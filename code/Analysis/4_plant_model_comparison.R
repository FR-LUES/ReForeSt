source("code/Analysis/0_setup.R")
source("code/analysis/1_Functions.R")

# Read in model data ---- !#
models <- readRDS(paste0(num_data_path, "plantModels.rds"))
plantData <- models[[1]]$data
glimpse(plantData)

# Assign loo scores ---- !#
loos <- lapply(models, loo, reloo = TRUE)
loo_compare(loos)

conditional_effects(models[[2]])
names(models)



