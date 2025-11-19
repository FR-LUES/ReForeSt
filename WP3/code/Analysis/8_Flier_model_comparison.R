source("WP3/code/Analysis/0_setup.R")


# Read in model data ---- !#
models <- readRDS(paste0(num_data_path, "flyModels.rds"))
flyData <- models[[1]]$data




#nrow(crawlData)





# Extract AICs ---- !#
aics <- map(models, .f = function(x) x$aic)
Hoverfly <- models[2]
Cranefly <- models[4]
total_fly <- models[7]
bestMods <- c(Hoverfly, Cranefly, total_fly)





# View model summaries ---- !#
# View model summaries ---- !#
map(bestMods, ~sumFun(.x))





# View model diagnostics, ALL MODELS LOOK GOOD
#map(bestMods, ~plot(.x))








# Plot results ---- !#
# Define  structural variables
struct_vars <- c("dbhSD", "gap_prop", "mean30mFHD_gapless")
response <- c("Hoverflyrichness", "Cranefliesrichness", "flyRichness")


plotList <- map(1:length(bestMods),
                .f = function(x) plot_struct_effects(bestMods[[x]],
                                                     flyData,
                                                     response_name = response[[x]],
                                                     struct_vars = struct_vars,
                                                     taxa = ""))

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
