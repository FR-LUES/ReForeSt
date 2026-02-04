### Read in data
# NFI and filter
nfi <- vect(path_NFI_DASH, layer = "NFI2020_Interim_v1_WoodlandMap") %>%
  filter(!IFT_IOA %in% c("Cloud \\ shadow", "Uncertain"))
  
# gap map
gap_map <- rast(path_gap_map_DASH)
gap_ext <- rast(ext(gap_map),
                resolution = res(gap_map),
                crs = crs(gap_map))

# FHD map to use same 30m grid for gap fraction
fhd_map <- rast(path_fhd_map_DASH)
fhd_ext <- rast(ext(fhd_map),
                resolution = res(fhd_map),
                crs = crs(fhd_map)) 
rm(fhd_map)

#  England boundary
england <- vect(path_eng_DASH) %>% terra::aggregate() 


### Tiles
# Create 9km tiles (30m x 300) for loop - aggregated from fhd ext to ensure raster alignment
tiles <- aggregate(fhd_ext, 300) %>% as.polygons()

# Crop tiles to England
tiles_eng <- terra::crop(tiles, england)


### Produce gap fraction by tile and write

for (i in 1:length(tiles_eng)) {
  tile <- tiles_eng[i,]

  gap_map_tile <- terra::crop(gap_map, tile)
  gap_ext_tile <- terra::crop(gap_ext, tile)
  nfi_tile <- terra::crop(nfi, tile)
  fhd_ext_tile <- terra::crop(fhd_ext, tile)

  # skip if no NFI units in tile
  if(is.empty(nfi_tile)) {next}

  # gap map NAs to 0
  gap_map_tile[is.na(gap_map_tile)] <- 0

  # aggregate/dissolve nfi
  nfi_tile_agg <- terra::aggregate(nfi_tile)

  # rasterise nfi to gap map 1m extent
  # -0.5m buffer to reduce cells that intersect, as this was causing ege effects with gap map
  nfi_rast_1m_tile <- terra::rasterize(buffer(nfi_tile_agg, -0.5), gap_ext_tile)

  # disaggregate nfi and gap map to 30m - using project() as allows use of SpatExtent
  nfi_rast_30m_tile <- terra::project(nfi_rast_1m_tile, fhd_ext_tile, method = "sum") # sum provides raster value as area
  gap_map_30m_tile <- terra::project(gap_map_tile, fhd_ext_tile, method = "sum")

  # calculate gap fraction
  gap_frac_tile <- gap_map_30m_tile / nfi_rast_30m_tile

  # mask by NFI
  gap_frac_tile_mask <- terra::crop(gap_frac_tile, nfi_tile, mask = TRUE)

  # Export gap fraction raster
  j <- sprintf("%04d", i)
  filename <- paste0("gap_fraction_", j, ".tif")
  folder <- path_gap_frac_tiles_DASH
  path_export <- paste0(folder, filename) # DASH path

  # Use a local path for writing
  path_local <- paste0("/tmp/", filename)
  writeRaster(gap_frac_tile_mask, path_local, overwrite = TRUE)
  
  # Copy to DBFS
  file.copy(path_local, path_export)
  file.remove(path_local)
    
  print(i)

  gc()
}