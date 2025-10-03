source("WP3/code/Analysis/0_setup.R")


# Read in model data ---- !#
models <- readRDS(paste0(num_data_path, "flyModels.rds"))
flyData <- models[[1]]$data




#nrow(crawlData)





# Extract AICs ---- !#
aics <- map(models, .f = function(x) x$aic)

# Using only LiDAR is no worse than field for species richness
q0Mod <- models[[3]]
# LiDAR is best for q1
q1Mod <- models[[5]]
# LiDAR is best for q2
q2Mod <- models[[8]]
# Field is best for abundance
abundMod <- models[[12]]
bestMods <- list(q0Mod, q1Mod, q2Mod, abundMod)






# View model summaries ---- !#
map(bestMods, ~sumFun(.x))





# View model diagnostics, ALL MODELS LOOK GOOD
map(bestMods, ~plot(.x))








# Plot results ---- !#
# Define  structural variables
struct_vars <- c("dbhSD", "understoryCover", "gap_prop", "mean30mFHD_gaps")
response <- c("q0Log", "q1Log", "q2Log", "logAbund")
plotList <- map(1:length(bestMods),
                .f = function(x) plot_struct_effects(bestMods[[x]],
                                                     flyData,
                                                     response_name = response[[x]],
                                                     struct_vars = struct_vars,
                                                     taxa = "Flying invert"))

## Save plots
# Create a new PowerPoint
ppt <- read_pptx()

for (plotGroup in plotList) {
  for (p in plotGroup) {
    ppt <- add_slide(ppt, layout = "Blank", master = "Office Theme") %>%
      ph_with(dml(ggobj = p), location = ph_location_fullsize())
  }
}

print(ppt, target = "WP3/outputs/figures/flying_structural_effects.pptx")
