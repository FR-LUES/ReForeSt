source("WP4/Scripts/0_setup.R")
source("WP4/Scripts/0_functions.R")


# Read in Data ---- !#
sCHMs <-  map(dir(sCHMclipPath), function(x)
  rast(paste0(sCHMclipPath, x))) # read in sCHMs
# Aggregating sCHMs to save memory, remove when on better pc.
sCHMs <- map(sCHMs, .f = function(x) aggregate(x, fact = 4, fun = "mean")) 
lCHMs <- map(dir(lCHMclipPath), function(x)
  rast(paste0(lCHMclipPath, x))) # read lCHM

# JB added line below as lCHMs in wrong CRS
lCHMs <- lapply(lCHMs, function(r) project(r, "EPSG:27700"))

nfi <- st_read(NFIsamplePath)# read in NFI
nfi <- chmMatch(sCHMclipPath, nfi) # Order shapefiles to match chms
#set range for map function
range <- 1:length(sCHMs)
nfi[nfi$OBJECTID == 78117,] |> st_area()

plot(sCHMs[names(sCHMs) == "78117"])


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


# count tree tops
sttops_list <- map(range, function(x) count_ttops(sCHMs[[x]], nfi[x,]))
lttops_list <- map(range, function(x) count_ttops(lCHMs[[x]], nfi[x,]))

df_ttops <- rbind(
  data.frame(OBJECTID = nfi$OBJECTID,
             ttops = unlist(sttops_list),
             source = "Imagery"),
  data.frame(OBJECTID = nfi$OBJECTID,
             ttops = unlist(lttops_list),
             source = "LiDAR")
  )

# Combine metrics ---- !#
comparisonMetrics <-
  gap_metrics %>% 
  left_join(meanEffCanDF, by = c("OBJECTID" = "OBJECTID", "source" = "source")) %>% 
  left_join(df_ttops, by = c("OBJECTID" = "OBJECTID", "source" = "source"))

comparisonMetrics$area <- rep(st_area(nfi), 2) |> round(0)
write.csv(comparisonMetrics, paste0(dataPath, "comparison_metrics.csv"))
