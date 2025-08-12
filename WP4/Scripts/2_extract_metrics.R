source("Scripts/0_setup.R")
source("Scripts/0_functions.R")


# Read in Data ---- !#
sCHMs <-  map(dir(sCHMclipPath), function(x)
  rast(paste0(sCHMclipPath, x))) # read in sCHMs
# Aggregating sCHMs to save memory, remove when on better pc.
sCHMs <- map(sCHMs, .f = function(x) aggregate(x, fact = 4, fun = "mean")) 
lCHMs <- map(dir(lCHMclipPath), function(x)
  rast(paste0(lCHMclipPath, x))) # read lCHM
nfi <- st_read(NFIsamplePath)# read in NFI
nfi <- chmMatch(sCHMclipPath, nfi) # Order shapefiles to match chms
#set range for map function
range <- 1:length(sCHMs)








# Calculate gap fraction ---- !# 
sGaps <- map(range, .f = function(x)
  gapsToRast(sCHMs[[x]], nfi[x,]))# synthetic gaps
lGaps <- map(range, .f = function(x)
  gapsToRast(lCHMs[[x]], nfi[x,]))# LiDAR gaps

sGap_metrics <- calculate_gap_metrics(sGaps, nfi$OBJECTID) |> mutate(source = "Imagery")
lGap_metrics <- calculate_gap_metrics(lGaps, nfi$OBJECTID) |> mutate(source = "LiDAR")
gap_metrics <- rbind(sGap_metrics, lGap_metrics) |>
  mutate(across(everything(), ~replace_na(.x, 0)))
gap_metrics$taM <- gap_metrics$ta * 10000 # Convert gap area to m^2
gap_metrics$gap_prop <- gap_metrics$taM / st_area(nfi) # Calculate gap_proportion

# Examples of house errors over small areas make a big difference
plot(sCHMs[[20]])
plot(lCHMs[[20]])


# Effective top canopy layers ---- !#
# Gridded effective canopy layer rasters
# Create the rasters
# 30 m 
sEffCan30M <- map(range, .f = function(x) zonal_effCanopyLayer(sCHMs[[x]],
                                                                 nfi[x,],
                                                                 res = 30,
                                                                 strata = strata))

lEffCan30M <- map(range, .f = function(x) zonal_effCanopyLayer(lCHMs[[x]],
                                                               nfi[x,],
                                                               res = 30,
                                                               strata = strata))

# Extract means
# mean and sd 30 m res gridded effective number of canopy layers
sMean30mEffCan <- map(range, function(x) mean(values(sEffCan30M[[x]]), na.rm = TRUE) |> round(2))
sEffCandf <- data.frame(source = "Imagery", mean30mEffCan = unlist(sMean30mEffCan), OBJECTID = nfi$OBJECTID)
lMean30mEffCan <- map(range, function(x) mean(values(lEffCan30M[[x]]), na.rm = TRUE) |> round(2))
lEffCandf <- data.frame(source = "LiDAR", mean30mEffCan = unlist(lMean30mEffCan), OBJECTID = nfi$OBJECTID)
meanEffCanDF <- rbind(sEffCandf, lEffCandf)


# Combine metrics ---- !#
comparisonMetrics <- left_join(gap_metrics, meanEffCanDF, by = c("OBJECTID" = "OBJECTID",
                                                                 "source" = "source"))
write.csv(comparisonMetrics, paste0(dataPath, "comparison_metrics.csv"))
