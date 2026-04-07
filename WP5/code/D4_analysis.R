source("WP5/code/0_setup.R")
source("WP5/code/1_functions.R")



# Read in metrics data ---- !#
metrics <- read.csv(paste0(path_Z_proc_data_WP5, "metrics.csv"))

# wrangle into long form
metrics <- metrics |>
  mutate(stemChange = stems_2024 - stems_2017,
         fhdChange = meanFHD_2024 - meanFHD_2017,
         gapChange = gapArea_2024 - gapArea_2017)


# Plot differences in metrics between thinned and unthinned ---- !#

# Stems
ggplot(data = metrics, aes(x = last_thinned, y = stemChange))+
  geom_boxplot(alpha = 0.3)+
  geom_jitter(alpha = 0.5)+
  labs(x = "Last thinning period", y = "Change in # tree's detected (2017-2024)")+
  scale_x_discrete(labels = c("< 2016", "2017 < 2024"))+
  theme_classic()

# gaps
gg_gaps <- 
ggplot(data = metrics, aes(x = last_thinned, y = gapChange))+
  geom_violin() +
  geom_hline(yintercept  = 0, colour = "black", linetype = 2, linewidth = 0.5) +
  geom_boxplot(width = 0.1, outliers = FALSE) +
  labs(x = "",
       y = parse(text = "Gap~area~change~(m^2)")) +
  scale_x_discrete(labels = c("Unthinned", "Thinned")) +
  theme_classic() +
  ylim(-1000, 1000) +
  theme(text = element_text(size = 12))


# height
gg_height <- 
ggplot(data = metrics, aes(x = last_thinned, y = heightChange))+
  geom_violin() +
  geom_hline(yintercept  = 0, colour = "black", linetype = 2, linewidth = 0.5) +
  geom_boxplot(width = 0.1, outliers = FALSE) +
  labs(x = "",
       y = "Mean height change (m)") +
  scale_x_discrete(labels = c("Unthinned", "Thinned")) +
  theme_classic() +
  theme(text = element_text(size = 12))

# fhd
gg_fhd <- 
ggplot(data = metrics, aes(x = last_thinned, y = fhdChange))+
  geom_violin() +
  geom_hline(yintercept  = 0, colour = "black", linetype = 2, linewidth = 0.5) +
  geom_boxplot(width = 0.1, outliers = FALSE) +
  labs(x = "",
       y = "Effective canopy layers change")+
  scale_x_discrete(labels = c("Unthinned", "Thinned")) +
  theme_classic() +
  theme(text = element_text(size = 12))

gg <- ggarrange(gg_height, gg_gaps, gg_fhd, ncol = 3, nrow = 1)


ggsave(filename = paste0(path_Z_proc_data_WP5, "Figures/dean_thinned_metrics.png"),
       plot = gg,
       dpi = 300,
       units = "cm",
       height = 8,
       width = 18)



 # Plot differences between selection types ---- !#
# fhd
ggplot(data = thinOnly, aes(x = selection_type, y = heightChange))+
  geom_boxplot(alpha = 0.3)+
  geom_jitter(alpha = 0.5)+
  labs( y = "Change in effective layers (2017-2024)")+
  scale_x_discrete()+
  theme_classic()




# ----- Statistical tests -----

thinned <- metrics %>% filter(last_thinned == "2017<2024")
unthinned <- metrics %>% filter(last_thinned == "< 2016")

# Height change
hist(thinned$heightChange, breaks = 30) # skewed, not normal
hist(unthinned$heightChange, breaks = 30) # normal

wilcox.test(thinned$heightChange, unthinned$heightChange) # p-value = 3.768e-11


# FHD change
hist(thinned$fhdChange, breaks = 30) # normalish with a bit of skew
hist(unthinned$fhdChange, breaks = 30) # normal

t.test(thinned$fhdChange, unthinned$fhdChange) # assumes normality | p-value = 3.27e-09
wilcox.test(thinned$fhdChange, unthinned$fhdChange) # p-value = 6.26e-09


# Gap change
hist(thinned$gapChange, breaks = 100) # normal, outliers
hist(unthinned$gapChange, breaks = 100) # normal, outliers

t.test(thinned$gapChange, unthinned$gapChange) # assumes normality | p-value = 0.0003189
wilcox.test(thinned$gapChange, unthinned$gapChange) # p-value = 2.799e-14
