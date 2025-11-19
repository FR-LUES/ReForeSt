source("WP3/code/Analysis/0_setup.R")
# This script explores correlations between structural variables to identify redundancies

# Plot a correlation matrix ---- !#
flies |>
  select(sd30mFHD_gapless, Cranefliesrichness) |>
  ggplot(aes(x = sd30mFHD_gapless, y = Cranefliesrichness))+
  geom_point()+
  geom_smooth(method = "lm")+
  labs(x = "sd30mFHD_gapless", y = "spp")+
  theme_calc()


