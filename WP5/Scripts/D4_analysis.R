source("WP5/Scripts/0_setup.R")
source("WP5/Scripts/1_functions.R")



# Read in metrics data ---- !#
metrics <- read.csv(paste0(pathWP5, "Data/metrics.csv"))

# wrangle into long form
metrics <- metrics |>
  mutate(stemChange = stems_2024 - stems_2017,
         fhdChange = meanFHD_2024 - meanFHD_2017,
         gapChange = gapArea_2024 - gapArea_2017)
thinOnly <- metrics |>
  filter(last_thinned == "2017<2024")

# Plot differences in metrics between thinned and unthinned ---- !#
# Stems
ggplot(data = metrics, aes(x = last_thinned, y = stemChange))+
  geom_boxplot(alpha = 0.3)+
  geom_jitter(alpha = 0.5)+
  labs(x = "Last thinning petriod", y = "Change in # tree's detected (2017-2024)")+
  scale_x_discrete(labels = c("< 2010", "2017 < 2024"))+
  theme_classic()

# gaps
ggplot(data = metrics, aes(x = last_thinned, y = gapChange))+
  geom_boxplot(alpha = 0.3)+
  geom_jitter(alpha = 0.5)+
  labs(x = "Last thinning petriod", y = "Log Change in gap area (2017-2024)")+
  scale_x_discrete(labels = c("< 2010", "2017 < 2024"))+
  theme_classic()+
  ylim(-1000, 1000)

# height
ggplot(data = metrics, aes(x = last_thinned, y = heightChange))+
  geom_boxplot(alpha = 0.3)+
  geom_jitter(alpha = 0.5)+
  labs(x = "Last thinning petriod", y = "Change in mean height (2017-2024)")+
  scale_x_discrete(labels = c("< 2010", "2017 < 2024"))+
  theme_classic()

# fhd
ggplot(data = metrics, aes(x = last_thinned, y = fhdChange))+
  geom_boxplot(alpha = 0.3)+
  geom_jitter(alpha = 0.5)+
  labs(x = "Last thinning petriod", y = "Change in effective layers (2017-2024)")+
  scale_x_discrete(labels = c("< 2010", "2017 < 2024"))+
  theme_classic()








 # Plot differences between selection types ---- !#
# fhd
ggplot(data = thinOnly, aes(x = selection_type, y = heightChange))+
  geom_boxplot(alpha = 0.3)+
  geom_jitter(alpha = 0.5)+
  labs( y = "Change in effective layers (2017-2024)")+
  scale_x_discrete()+
  theme_classic()
