source("code/Analysis/0_setup.R")
source("code/analysis/1_Functions.R")


# Merge data with LiDAR metrics ---- !#
flies <- flies |>
  na.omit(Count) |>
  rename("ID" = "Site") |>
  group_by(ID) |>
  summarise(q1 = hill_number(Count, 1),
            q0 = hill_number(Count, 0),
            q2 = hill_number(Count, 2),
            abund = hill_number(Count, "abund"),
            stemDensity = mean(stemDensityHA, na.rm = TRUE),
            dbhSD = mean(dbhSD, na.rm = TRUE),
            understoryCover = mean(meanUnderstoryCover, na.rm = TRUE)) |>
  left_join(structure, by = "ID") |>
  left_join(landscape[, c("ID", "area_ha")], by = "ID") |>
  left_join(plants[, c("ID", "Age")], by = "ID")










# Exploration plots ---- !#
flies |> pivot_longer(-c(ID, q1, q0, q2, abund), names_to = "Vars", values_to = "Value") |>
  ggplot(aes(x = Value, y = abund)) +
  geom_point(size = 3)+
  theme_classic()+
  facet_wrap(~Vars, scales = "free") 


# Local variables to test = understory cover and sdDBH


