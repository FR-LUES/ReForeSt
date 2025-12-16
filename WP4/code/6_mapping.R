source("WP4/Scripts/0_setup.R")
source("WP4/Scripts/0_functions.R")



# Read in Data ---- !#
sCHMs <-  map(dir(sCHMclipPath), function(x)
  rast(paste0(sCHMclipPath, x))) # read in sCHMs
# Aggregating sCHMs to save memory, remove when on better pc.
#sCHMs <- map(sCHMs, .f = function(x) aggregate(x, fact = 4, fun = "mean")) 
lCHMs <- map(dir(lCHMclipPath), function(x)
  rast(paste0(lCHMclipPath, x))) # read lCHM

# JB added line below as lCHMs in wrong CRS
lCHMs <- lapply(lCHMs, function(r) project(r, "EPSG:27700"))

nfi <- st_read(NFIsamplePath)# read in NFI
nfi <- chmMatch(sCHMclipPath, nfi) # Order shapefiles to match chms
#set range for map function
range <- 1:length(sCHMs)








# Create maps for the effective number of top canopy heights ---- !#
sEffCan30M <- map(range, .f = function(x) zonal_effCanopyLayer(sCHMs[[x]],
                                                               nfi[x,],
                                                               res = 30,
                                                               strata = strata))

lEffCan30M <- map(range, .f = function(x) zonal_effCanopyLayer(lCHMs[[x]],
                                                               nfi[x,],
                                                               res = 30,
                                                               strata = strata)) # LiDAR version for plotting later

map(range, .f = function(x) 
  writeRaster(sEffCan30M[[x]], paste0(effCanPath, names(sCHMs[[x]]),".tif")))



# Create maps for gaps ---- !#
sGaps <- map(range, .f = function(x)
  gapsToRast(sCHMs[[x]], nfi[x,]))# synthetic gaps
lGaps <- map(range, .f = function(x)
  gapsToRast(lCHMs[[x]], nfi[x,])) # lidar gaps for plotting later

map(range, .f = function(x) 
  writeRaster(sGaps[[x]], paste0(gapPath, names(sCHMs[[x]]),".tif")))

num <- 18
plot(sCHMs[[num]], axes = FALSE)
plot(lCHMs[[num]], axes = FALSE)

plot(sCHMs[[num]],  axes = FALSE)
plot(sGaps[[num]]$gap_id, col = "pink", add = TRUE, axes = FALSE)

plot(lCHMs[[num]],  axes = FALSE)
plot(lGaps[[num]]$gap_id, col = "pink", add = TRUE, axes = FALSE)


plot(sEffCan30M[[num]], axes = FALSE)


plot(lEffCan30M[[num]], axes = FALSE)
