source("WP4/code/0_setup.R")
source("WP4/code/1_functions.R")
library(ggplot2); theme_set(theme_bw())

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
                                      "Gap fraction", "Number of gaps", "Gap area", "Tree tops")))
#glimpse(metrics)
# Plot comparisons ---- !#
gg <- 
  ggplot(data = plot_data,
         aes(x = LiDAR, y = Imagery)) +
  geom_abline(colour = "#801650",
              linewidth = 1) +
  geom_smooth(method = "lm",
              se = FALSE,
              colour = "#28A197",
              linewidth = 1) +
  geom_point(size = 2,
             colour = "#12436D") +
  facet_wrap(~Variable,
             scales = "free") +
  geom_text(aes(x = -Inf, y = Inf, label = label),  # top-left of each facet
            hjust = -0.3, vjust = 1.2, inherit.aes = FALSE,
            size = 4) +
   labs(x = "lCHM-derived value",
        y = "sCHM-derived value") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        strip.background = element_rect(fill = "white"),
        text = element_text(size = 12),
        legend.margin = margin(0, 0, 0, 0),
        legend.box.margin = margin(0, 0, 0, 0))


ggsave(filename = paste0(path_Z_proc_data_WP4, "Figures/sCHM_lCHM_comparisons.png"),
       plot = gg,
       dpi = 300,
       units = "cm",
       height = 12,
       width = 18)

