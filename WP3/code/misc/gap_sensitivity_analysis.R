### preamble
 
source("./code/0_setup.R")
source("./code/1_Functions.R")

library(cowplot)
library(viridis)
 
scale_values <- function(x){x/max(x)}

### data import

shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
chms <- map(dir(path_test_data_chm), function(x) rast(paste0(path_test_data_chm, x)))

# Order shapes to match chms
shapes <- chmMatch(path_test_data_chm, shapes)

### gap metrics

gap_heights <- c(1, 2, 5)
gap_sizes <- c(5, 10, 20)

### loop over test sites

i <- 1

for (n in 1:nrow(shapes)) {
  
  site_boundary <- shapes[n, ]
  site_chm <- chms[[n]]
  site_id <-  site_boundary$ID
  
  datalist_metrics <- list()
  
  ### loop over gaps metrics
  
  for (gapHeight in gap_heights) { 
  
    for (gapSize in gap_sizes) {
  
      # extract gaps
    
      gaps <- gapsToRast(site_chm, site_boundary)

      # assign raster
      
      assign(paste0("gaps_", site_id, "_height_", gapHeight, "_area_", gapSize), gaps)
      
      # calculate metrics
    
      df_metrics <- calculate_gap_metrics(gaps[[1]], site_id)
    
      # add site area and gap proportion
    
      df_metrics <-
        df_metrics %>% 
        dplyr::mutate(site_area = st_area(site_boundary) / 10000, # convert m2 to ha
                      gap_prop = ta / site_area,
                      patch_den = np / site_area,
                      gap_size = gapSize,
                      gap_height = gapHeight) %>%
        convert(num(site_area, gap_prop, patch_den)) %>% 
        filter(level == "landscape") %>%
        select(c("site_id", "gap_size", "gap_height", "site_area", "gap_prop", "patch_den", str_remove(l_metrics, "lsm_l_")))
    
      # add to datalist
      datalist_metrics[[i]] <- df_metrics
      
      print(i)
      i <- i + 1
    }
  }
  
  df_metrics_site <- 
    dplyr::bind_rows(datalist_metrics)
  
  rm(datalist_metrics)
  
  df_metrics_site_long <- 
    df_metrics_site %>%
    mutate(across(all_of(c("gap_prop", "patch_den", str_remove(l_metrics, "lsm_l_"))), scale_values)) %>% 
    pivot_longer(cols = gap_prop:cohesion,
                 names_to = "metric",
                 values_to = "value")
  
  chm_plot <- 
    ggplot() +
    geom_spatraster(data = site_chm,
                    show.legend = F) +
    scale_fill_viridis() +
    theme_void()

  sensitivity_plot <- 
    ggplot(data = df_metrics_site_long,
           aes(x = as.factor(gap_height),
               y = as.factor(gap_size),
               size = value,
               colour = metric)) +
      geom_point() +
      labs(x = "Gap Height (m)",
           y = "Gap Size (m2)",
           title = "Sensitivity Analysis of Gap Parameters",
           subtitle = paste0("Site: ", site_id),
           size = "Scaled Value") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5),
            plot.subtitle = element_text(hjust = 0.5)) +
      scale_colour_discrete(guide = "none") +
      facet_wrap("metric")
  
  combined_plot <- plot_grid(chm_plot, sensitivity_plot)

  ggsave(filename = paste0(path_outputs_gap_sensitivity, "gap_sensitivity_", site_id, ".jpg"),
         plot = combined_plot,
         units = "cm",
         width = 24,
         height = 12)

}

### look at gap rasters

par(mfrow = c(3, 3))

for (gapHeight in gap_heights) { 
  
  for (gapSize in gap_sizes) {
    
    terra::plot(get(paste0("gaps_", site_id, "_height_", gapHeight, "_area_", gapSize))[[1]],
                legend = F,
                main = paste0("height_", gapHeight, "_area_", gapSize))
    
  }
}

par(mfrow = c(1, 1))
