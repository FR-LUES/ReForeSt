source("WP3/code/Analysis/0_setup.R")
# This script explores correlations between structural variables to identify redundancies

# Plot a correlation matrix ---- !#
plants |>
  select( mean30mEffStories, dbhSD) |>
  ggplot(aes(x = log(dbhSD+1), y = mean30mEffStories))+
  geom_point()+
  theme_calc()

