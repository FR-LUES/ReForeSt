source("WP3/code/Analysis/0_setup.R")


# Read in model data ---- !#
models <- readRDS(paste0(num_data_path, "plantModels.rds"))
plantData <- models[[1]]$data










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
struct_vars <- c("dbhSD", "gap_prop", "mean30mFHD_gaps")
response <- c("spp", "sppWoodland", "sppSpecialist")
plotList <- map(1:length(bestMods),
                .f = function(x) plot_struct_effects(bestMods[[x]],
                                                     plantData,
                                                     response_name = response[[x]],
                                                     struct_vars = struct_vars,
                                                     taxa = "Plant")
)


# Create a new PowerPoint
ppt <- read_pptx()

for (plotGroup in plotList) {
  for (p in plotGroup) {
    ppt <- add_slide(ppt, layout = "Blank", master = "Office Theme") %>%
      ph_with(dml(ggobj = p), location = ph_location_fullsize())
  }
}

print(ppt, target = "WP3/outputs/figures/plant_structural_effects.pptx")
