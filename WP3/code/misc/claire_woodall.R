library(terra)
library(tidyverse)

gf <- rast("Z:/Projects/FRD_Programme/FRD_20 ReForeSt/gap_fraction/gap_fraction_30m.tif")
fhd <- rast("Z:/Projects/FRD_Programme/FRD_20 ReForeSt/fhd_map/FHD_full_30m.tif")
bristol <- vect("Z:/Common/Woodall_claire/Bristol_boundary/Bristol_boundary.shp")



gf_bristol <- terra::crop(gf, bristol)
writeRaster(gf_bristol,
            "Z:/Common/Woodall_claire/ReForeST_gap fraction data/gap_fraction_30m_bristol.tif")


fhd_bristol <- terra::crop(fhd, bristol)
writeRaster(fhd_bristol,
            "Z:/Common/Woodall_claire/ReForeST_gap fraction data/fhd_30m_bristol.tif")