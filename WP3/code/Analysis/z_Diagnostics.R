source("WP3/code/Analysis/0_setup.R")
source("WP3/code/analysis/1_Functions.R")

# Read in data ---- !#
models <- readRDS(paste0(num_data_path, "plantModels.rds"))





# Test if residuals correlate with sampling effort ---- !#
resids <- map(1:length(models), 
              .f = function(x)
                residCorr(models[[x]], models[[x]]$data$Source)
)









# Inspect posterior predictions ---- !#
map(1:length(models), .f = function(x) pp_response(models[[x]]))






ppComp(models[[2]])


# Compare prior distributions to posterior distributions ---- !#
map(1:length(models), .f = function(x) ppComp(models[[x]]))
