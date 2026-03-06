.libPaths("C:/R-Packages/")
source("WP3/code/metric_extraction/0_setup.R")
library(ggplot2); theme_set(theme_bw())

theme <-  
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        strip.background = element_rect(fill = "white"),
        text = element_text(size = 12),
        legend.margin = margin(0, 0, 0, 0),
        legend.box.margin = margin(0, 0, 0, 0))


# ----- read in data -----

df_metrics <- read.csv(paste0(path_outputs, "masterMetrics_df.csv"))
df_dbh <- read.csv(paste0(path_data, "numerical_data/masterDBH.csv"))

df <-
  df_metrics %>%
  left_join(df_dbh, by = "ID") %>% 
  select(-X) %>% 
  filter(dbhSD > 0) %>% 
  drop_na()

# ----- plot and write -----
gg <- 
  ggplot(data = df,
         aes(x = log(dbhSD),
             y = siteFHD_gapless)) +
   geom_point() +
   geom_smooth(method = "lm") +
   labs(x = "Log of standard deviation of DBH",
        y = "Effective number of canopy layers") +
   theme

  
ggsave(filename = paste0(path_outputs, "FHD_sdDBH.png"),
       plot = gg,
       dpi = 300,
       units = "cm",
       height = 12,
       width = 18)
