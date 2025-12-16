source("WP4/Scripts/0_setup.R")
source("WP4/Scripts/0_functions.R")


# Read in the data ---- !#
metrics <- read.csv(metricsPath) |>
  select(-c(X, taM))

metricsWide <-  metrics |>
  pivot_longer(cols = -c(OBJECTID, source, level, area),
               names_to = "Variable",
               values_to = "Value") |>
  pivot_wider(names_from = source, values_from = Value) |>
  mutate(LiDAR = round(LiDAR, 3),
         Imagery = round(Imagery, 3)) |> filter(area >= 500)


# Generate equations to link LiDAR and Imagery metrics ---- !#
r2_results <- metricsWide |>
  group_by(Variable) |>
  nest() |>
  mutate(r2 = map_dbl(data, get_r2)) |>
  select(Variable, r2)
#Join R2 labels to plotting data
plot_data <- metricsWide |>
  left_join(r2_results, by = "Variable") |>
  mutate(label = paste0("R² = ", round(r2, 2)),
         Variable = factor(Variable,
                           levels = c("mean30mEffCan", "gap_prop", "np", "ta", "ttops"),
                           labels = c("Effective # top canopy layers",
                                      "Gap proportion", "# Gaps", "Gap area", "Tree tops")))
#glimpse(metrics)
# Plot comparisons ---- !#
ggplot(data = plot_data, aes(x = LiDAR, y = Imagery))+
  geom_point(size = 2)+
  geom_abline(colour = "black", linewidth = 1.5)+
  geom_smooth(method = "lm", se = FALSE, colour = "red", linewidth = 1.5) +
  facet_wrap(~Variable, scales = "free")+
  geom_text(
            aes(x = -Inf, y = Inf, label = label),  # top-left of each facet
            hjust = -0.3, vjust = 1.2, inherit.aes = FALSE,
            size = 4) +
   labs(x = "LiDAR-derived value", y = "Imagery-derived value")+
   theme_calc()

View(plot_data)

