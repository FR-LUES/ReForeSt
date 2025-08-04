library(tidyverse)
library(sjPlot)
# Read in data
plants <- read.csv("data/numeric_data/masterPlant.csv")

plants <- plants |> mutate(nearestAW = case_when(is.na(nearestAW) ~ 1000,
                                                 .default = nearestAW),
                           Age = case_when(Type == "Mature" ~ "250",
                                           .default = Age),
                           Age = as.numeric(Age)) |>
  filter(!(Source %in% c("NC", "FTC") & Age == 250))
         
plot(plants$Age, plants$dbhSD)
pairs(plants |> select(-c(area_m, X, ID, Source, Type)))
head(plants)
plants |> select(-c(spp, sppWoodland, sppSpecialist, X, ID, Type, Source)) |>
  pivot_longer(!c(sppGeneralist), names_to = "Variable", values_to = "Metric") |>
  ggplot(aes(x = Metric, y = sppGeneralist))+
  geom_point()+
  geom_smooth(method = "glm", method.args = list(family = "poisson"))+
  facet_wrap(~Variable, scales = "free")

model <- glm(sppWoodland ~ Source+ area_ha + aw500_m + dbhSD + stemDensityHA, family = "poisson", data = plants)

plot_model(model, type = "pred")

par(mfrow = c(1, 2))
ggplot(data = plants, aes(x = Age, y = stemDensityHA))+
  geom_point()+
  geom_smooth(method = "lm")+
  theme_classic()

ggplot(data = plants, aes(x = Age, y = sppSpecialist))+
  geom_point()+
  geom_smooth(method = "lm")+
  theme_classic()
