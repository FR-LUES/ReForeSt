source("WP3/code/Analysis/0_setup.R")
# This script explores correlations between structural variables to identify redundancies

# Plot a correlation matrix ---- !#
flies |>
  select(mean30mFHD_gapless, understoryCover) |>
  ggplot(aes(x = understoryCover, y = mean30mFHD_gapless))+
  geom_point()+
  geom_smooth(method = "lm")+
  labs(x = "Log of sd DBH", y = "Effective # canopy layers")+
  theme_calc()


glimpse(flies)
structure |>
  select(mean30mFHD_gapless, mean30mFHD_gaps, ttops_den, gap_prop) |>
  ggpairs()
glimpse(structure)
