source("WP3/code/Analysis/0_setup.R")


# Read in model data ---- !#
models <- readRDS(paste0(num_data_path, "crawlerModels.rds"))
crawlData <- models[[1]]$data




#nrow(crawlData)





# Extract AICs ---- !#
aics <- map(models, .f = function(x) x$aic)

# The best model for spiders has both LiDAR and field variables
spiderMod <- models[[2]]
# The best model for q1 has only stem density
beetleMod <- models[[6]]
# The best model for q2 has only stem density
crawlerMod <- models[[7]]

bestMods <- list(spiderMod, beetleMod, crawlerMod)









# View model summaries ---- !#
#map(bestMods, ~sumFun(.x))





# View model diagnostics, ALL MODELS LOOK GOOD
#map(bestMods, ~plot(.x))








# Plot results ---- !#
# Define  structural variables
struct_vars <- c("stemDensity", "gap_prop", "mean30mFHD_gapless", "ttops_den")
response <- c("spiderSpp", "beetleSpp", "crawlerSpp")
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
