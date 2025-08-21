source("WP3/code/Analysis/0_setup.R")


# Read in model data ---- !#
models <- readRDS(paste0(num_data_path, "crawlerModels.rds"))
crawlData <- models[[1]]$data




#nrow(crawlData)





# Extract AICs ---- !#
aics <- map(models, .f = function(x) x$aic)

# The best model for q0 has both LiDAR and field variables
q0Mod <- models[[1]]
# The best model for q1 has only stem density
q1Mod <- models[[6]]
# The best model for q2 has only stem density
q2Mod <- models[[9]]
# the best model for abundance includes all variables
abundMod <- models[[10]]
bestMods <- list(q0Mod, q1Mod, q2Mod, abundMod)









# View model summaries ---- !#
map(bestMods, ~sumFun(.x))





# View model diagnostics, ALL MODELS LOOK GOOD
map(bestMods, ~plot(.x))








# Plot results ---- !#
# Define  structural variables
struct_vars <- c("stemDensity", "gap_prop", "mean30mEffStories")
response <- c("q0Log", "q1Log", "q2Log", "logAbund")
plotList <- map(1:length(bestMods),
                .f = function(x) plot_struct_effects(bestMods[[x]],
                                                     crawlData,
                                                     response_name = response[[x]],
                                                     struct_vars = struct_vars,
                                                     taxa = "Crawling invert")
)

# Save plots
# Create a new PowerPoint
ppt <- read_pptx()

for (plotGroup in plotList) {
  for (p in plotGroup) {
    ppt <- add_slide(ppt, layout = "Blank", master = "Office Theme") %>%
      ph_with(dml(ggobj = p), location = ph_location_fullsize())
  }
}

print(ppt, target = "WP3/outputs/figures/crawler_structural_effects.pptx")
