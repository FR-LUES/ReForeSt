source("WP3/code/metric_extraction/0_setup.R")
library(ggplot2); theme_set(theme_void())

theme <-  
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        strip.background = element_rect(fill = "white"),
        text = element_text(size = 12),
        legend.margin = margin(0, 0, 0, 0))


fhd <- rast("Z:/Projects/FRD_Programme/FRD_20 ReForeSt/02_data/01_processed_data/fhd_map/fhd_full_30m_corrected.tif")

thetford_ext <- ext(572885, 587885, 278923, 298923)
thetford_ext <- ext(572885, 590000, 278923, 298923)

fhd_thetford <- terra::crop(fhd, thetford_ext)


# ----- plots -----

gg_eng <-
  ggplot() +
  geom_spatraster(
    data = fhd,
    show.legend = FALSE) +
  scale_fill_viridis(na.value = NA) +
  theme

gg_thetford <- 
ggplot() +
  geom_spatraster(
    data = fhd_thetford,
    show.legend = TRUE) +
  scale_fill_viridis(na.value = NA) +
  labs(title = "Thetford Forest",
       fill = "Effective # \ncanopy layers\n") +
  theme


gg <- ggarrange(gg_eng, gg_thetford, ncol = 2, nrow = 1)


ggsave(filename = paste0(path_outputs, "fhd_example.png"),
       plot = gg,
       dpi = 300,
       units = "cm",
       height = 12,
       width = 14)
