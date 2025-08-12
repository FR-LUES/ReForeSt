source("WP3/code/Analysis/0_setup.R")


# Read in model data ---- !#
models <- readRDS(paste0(num_data_path, "plantModels.rds"))
plantData <- models[[1]]$data
glimpse(plantData)









# Extract AICs ---- !#
aics <- map(models, .f = function(x) x$aic)

# The best model for overall species includes both LiDAR and field variables
sppMod <- models[[1]]
# The best model for overall woodland species includes LiDAR and field variables
woodMod <- models[[4]]
# The best model for woodland specialists includes just dbhSD
specMod <- models[[9]]

bestMods <- list(sppMod, woodMod, specMod)









# View model summaries ---- !#
map(bestMods, ~sumFun(.x))





# View model diagnostics, ALL MODELS LOOK GOOD
#map(bestMods, ~plot(.x))








# Plot results ---- !#
# Define  structural variables
struct_vars <- c("dbhSD", "gap_prop", "mean30mEffStories")
response <- c("spp", "sppWoodland", "sppSpecialist")
plotList <- map(1:length(bestMods),
                .f = function(x) plot_struct_effects(bestMods[[x]],
                                                     plantData,
                                                     response_name = response[[x]],
                                                     struct_vars = struct_vars))

# Save plots
pdf("outputs/figures/plant_structural_effects.pdf", width = 8, height = 6)
for (p in plotList) {
  print(p)
}
dev.off()
