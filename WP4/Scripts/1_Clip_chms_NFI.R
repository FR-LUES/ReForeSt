# This script clips both the sCHM and CHM rasters to NFI units
source("WP4/Scripts/0_setup.R")
source("WP4/Scripts/0_functions.R")



# Read in data ---- !#
nfi <- st_read(NFIpath) |> 
  filter(IFT_IOA %in% c("Broadleaved", "Conifer", "Mixed mainly broadleaved",
                        "Mixed mainly conifer", "Coppice with standards", "Young trees",
                        "Coppice")) |>
  filter(Area_Ha > 2)# NFI data only woodland
sCHMs <- rastCat(sCHMPath) |> st_transform(crs = st_crs(27700))# create sCHM catalog
CHMs <- rastCat(CHMPath) |> st_transform(crs = st_crs(27700))# create CHM catalog
nfi <- st_intersection(nfi, st_union(sCHMs)) # Clip NFI to CHM area




# Clip and raster data to NFI polygons and save to file ---- !#
sCHM_clip <- clip_aoiRast(nfi, sCHMs)
lCHM_clip <- clip_aoiRast(nfi, CHMs)
lCHM_clip <- map(lCHM_clip, ~focal(.x, w = 3, fun = mean, na.policy = "omit"))



map(1:length(sCHM_clip), .f = function(x) {
  writeRaster(sCHM_clip[[x]], paste0(sCHMclipPath, names(sCHM_clip[[x]]),".tif"))
  writeRaster(lCHM_clip[[x]], paste0(lCHMclipPath, names(sCHM_clip[[x]]),".tif"))})# Names have to be from sCHM for both
st_write(nfi, "WP4/Shapes/NFI/nfi_sample.shp")
