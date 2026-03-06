source("WP3/code/mapped_outputs/0_setup_gaps.R")
source("WP3/code/mapped_outputs/1_functions.R")

path_folder <- paste0(path_Z, "gap_fraction/nfi_2020_analysis/")

library(ggplot2); theme_set(theme_bw())
library(viridis)

theme <-  
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        strip.background = element_rect(fill = "white"),
        text = element_text(size = 12),
        legend.margin = margin(0, 0, 0, 0),
        legend.box.margin = margin(0, 0, 0, 0))

# ----- read in data -----
nfi_gap_frac <- vect(paste0(path_folder, "nfi_2020_gap_fraction.gpkg"))

# convert to df
df_nfi_gf <-
  nfi_gap_frac %>% 
  as_tibble() %>% 
  drop_na(district) %>% # Non England areas
  select(OBJECTID, Category, IFT_IOA, Area_ha, district, d_code, gap_fraction_30m) %>% 
  mutate(
    decile = case_when(
      between(gap_fraction_30m, 0, 0.1) ~ "0.1",
      between(gap_fraction_30m, 0.1, 0.2) ~ "0.2",
      between(gap_fraction_30m, 0.2, 0.3) ~ "0.3",
      between(gap_fraction_30m, 0.3, 0.4) ~ "0.4",
      between(gap_fraction_30m, 0.4, 0.5) ~ "0.5",
      between(gap_fraction_30m, 0.5, 0.6) ~ "0.6",
      between(gap_fraction_30m, 0.6, 0.7) ~ "0.7",
      between(gap_fraction_30m, 0.7, 0.8) ~ "0.8",
      between(gap_fraction_30m, 0.8, 0.9) ~ "0.9",
      between(gap_fraction_30m, 0.9, 1.0) ~ "1.0")) %>% 
  left_join(df_nfi_gf %>% 
              group_by(d_code) %>% 
              summarise(district_area = sum(Area_ha)),
            by = "d_code")

total_area <- sum(unique(df_nfi_gf$district_area))

# ----- tables -----

df_deciles <- 
  df_nfi_gf %>% 
  drop_na() %>% 
  group_by(decile) %>% 
  summarise(area = sum(Area_ha)) %>% 
  mutate(area_prop = area / total_area) 

write.csv(df_deciles,
          paste0(path_folder, "gap_fraction_deciles.csv"))


df_district_deciles <- 
  df_nfi_gf %>% 
  drop_na() %>% 
  group_by(district, d_code, district_area, decile) %>% 
  summarise(area = sum(Area_ha)) %>% 
  mutate(area_prop = area / district_area) %>% 
  ungroup() %>% 
  select(-district_area)
            
write.csv(df_district_deciles,
          paste0(path_folder, "district_gap_fraction_deciles.csv"))

# ----- graphs -----

ggsave_small <- function(ggplot, file) {
  
  ggsave(filename = paste0(path_folder, file, ".png"),
         plot = ggplot,
         dpi = 300,
         units = "cm",
         height = 12,
         width = 18)
}

gg_gf_violin <- 
  ggplot(data = df_nfi_gf,
         aes(x = district,
             y = gap_fraction_30m,
             fill = district)) +
    geom_violin(alpha = 0.5) +
    geom_boxplot(width = 0.1,
                 outliers = FALSE) +
    geom_hline(yintercept = 0.1,
               linetype = 2) +
    labs(x = "District",
         y = "Gap fraction",
         title = "Distribution of Gap Fraction in NFI Woodlands") +
    theme +
    theme(legend.position = "none")
  
ggsave_small(gg_gf_violin, "gf_violin")


gg_gf_deciles <- 
  ggplot(data = df_district_deciles %>% drop_na(),
         aes(x = district,
             y = area_prop,
             fill = decile)) +
  geom_col(position = position_stack(reverse = TRUE)) +
  labs(x = "District",
       y = "Proportion of District Woodland Area",
       title = "Gap Fraction Deciles in NFI Woodlands",
       fill = "Gap Fraction \nDecile") +
  scale_fill_manual(values = viridis(10)) +
  theme +
  theme(axis.text.x = element_text(angle = 15, vjust = 0.6))

ggsave_small(gg_gf_deciles, "gf_deciles")
