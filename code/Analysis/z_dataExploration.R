source("code/Analysis/0_setup.R")




  


# Scatter plots for crawling inverts ---- !#
resp <- "q1"
crawler |> pivot_longer(-c(ID, !!sym(resp), abund, Source, Type), names_to = "Vars", values_to = "Value") |>
  ggplot(aes(x = Value, y = !!sym(resp))) +
  geom_point(size = 3)+
  theme_classic()+
  facet_wrap(~Vars, scales = "free")


# scatter plots for flying inverts ---- !#
resp <- "q1"
flies |> pivot_longer(-c(ID, !!sym(resp),  abund), names_to = "Vars", values_to = "Value") |>
  ggplot(aes(x = Value, y = !!sym(resp))) +
  geom_point(size = 3)+
  theme_classic()+
  facet_wrap(~Vars, scales = "free")


# Scatter plot for plants ---- !#
resp <- "sppSpecialist"
plants |> select(ID, Type, !!sym(resp), sppSpecialist,
                 Source, dbhSD, stemDensityHA,area_ha, mean30mEffCan,
                 gap_prop) |>
  pivot_longer(-c(ID, Type, , !!sym(resp), sppSpecialist, Source),
               names_to = "Vars", values_to = "Value") |>
  ggplot(aes(x = Value, y = !!sym(resp))) +
  geom_point(size = 3)+
  theme_classic()+
  facet_wrap(~Vars, scales = "free")

