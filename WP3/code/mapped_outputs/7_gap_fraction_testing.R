.libPaths("C:/R-Packages/")
source("WP3/code/mapped_outputs/0_setup_gaps.R")
source("WP3/code/mapped_outputs/1_functions.R")

# paths
path_gap_map <- "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/gap_map/england/england_VOM_gaps_clip.tif"
path_fhd_map <- "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/fhd_map/FHD_full_30m.tif"
path_vom <- "Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_VOM/EA_VOM/"


# Read in gap map
gap_map <- rast(path_gap_map)
gap_ext <- rast(ext(gap_map),
                resolution = res(gap_map),
                crs = crs(gap_map))

# Read in NFI and filter
nfi <- vect(path_NFI, layer = "NFI2020_Interim_v1_WoodlandMap") %>%
  filter(!IFT_IOA %in% c("Cloud \\ shadow", "Uncertain"))

# Read in FHD map to use same 30m grid
fhd_map <- rast(path_fhd_map)
fhd_ext <- rast(ext(fhd_map),
                resolution = res(fhd_map),
                crs = crs(fhd_map)) 


### test area
test <- ext(387000, 390000, 207700, 210700) # 3 km2 area to test
#test <- ext(400000, 403000, 300000, 303000) # 3 km2 area to test


gap_map_test <- terra::crop(gap_map, test)
gap_ext_test <- terra::crop(gap_ext, test)
nfi_test <- terra::crop(nfi, test)
fhd_map_test <- terra::crop(fhd_map, test)
fhd_ext_test <- terra::crop(fhd_ext, test)

# gap map NAs to 0
gap_map_test[is.na(gap_map_test)] <- 0

# aggregate/dissolve nfi
nfi_test_agg <- terra::aggregate(nfi_test)

# rasterise nfi to gap map 1m extent
# -0.5m buffer to reduce cells that intersect, as this was causing ege effects with gap map
nfi_rast_1m_test <- terra::rasterize(buffer(nfi_test_agg, -0.5), gap_ext_test)

# disaggregate nfi and gap map to 30m - using project() as allows use of SpatExtent
nfi_rast_30m_test <- terra::project(nfi_rast_1m_test, fhd_ext_test, method = "sum") # sum provides raster value as area
gap_map_30m_test <- terra::project(gap_map_test, fhd_ext_test, method = "sum")

# calculate gap fraction
gap_fraction_30m <- gap_map_30m_test / nfi_rast_30m_test

plot(gap_fraction_30m)


##### by NFI unit
# gap fraction
nfi_gap_mean <- 
  terra::extract(x = gap_fraction_30m,
                 y = nfi_test,
                 fun = mean,
                 exact = TRUE,
                 na.rm = TRUE,
                 bind = TRUE)

plot(nfi_gap_mean, "england_VOM_gaps", breaks = 8)

nfi_gap_sd <- 
  terra::extract(x = gap_fraction_30m,
                 y = nfi_test,
                 fun = sd,
                 exact = FALSE,
                 na.rm = TRUE,
                 bind = TRUE)

plot(nfi_gap_sd, "england_VOM_gaps", breaks = 8)


# fhd
nfi_fhd_mean <- 
  terra::extract(x = fhd_map_test,
                 y = nfi_test,
                 fun = mean,
                 exact = TRUE,
                 na.rm = TRUE,
                 bind = TRUE)

plot(nfi_fhd_mean, "FHD_30m", breaks = 8)

nfi_fhd_sd <- 
  terra::extract(x = fhd_map_test,
                 y = nfi_test,
                 fun = sd,
                 exact = FALSE,
                 na.rm = TRUE,
                 bind = TRUE)

plot(nfi_fhd_sd, "FHD_30m", breaks = 8)

#####



# grainchanger





# write gap fraction 

terra::writeVector(nfi_test,
                   filename = "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/gap_fraction/nfi_test.gpkg",
                   overwrite = T)

terra::writeRaster(gap_fraction_30m,
                   filename = "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/gap_fraction/gap_fraction_test.tif",
                   overwrite = T)

terra::writeRaster(nfi_rast_1m_test,
                   filename = "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/gap_fraction/nfi_1m_test.tif",
                   overwrite = T)

terra::writeRaster(nfi_rast_30m_test,
                   filename = "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/gap_fraction/nfi_30m_test.tif",
                   overwrite = T)

terra::writeRaster(gap_map_test,
                   filename = "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/gap_fraction/gap_map_test.tif",
                   overwrite = T)

terra::writeRaster(gap_map_30m_test,
                   filename = "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/gap_fraction/gap_map_30m_test.tif",
                   overwrite = T)

terra::writeRaster(fhd_map_test,
                   filename = "Z:/Projects/FRD_Programme/FRD_20 ReForeSt/gap_fraction/fhd_map_test.tif",
                   overwrite = T)

