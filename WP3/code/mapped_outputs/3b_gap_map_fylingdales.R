# Read in NFI and filter
nfi <- vect(path_NFI, layer = "NFI2020") %>%
  filter(!IFT_IOA %in% c("Cloud \\ shadow", "Uncertain"))

fyl_VOM <- rast("Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_VOM/EA_VOM/V2_VOM_P_130241.tif")


# Mask fyl VOM by NFI (woodland only)
nfiTile <- crop(nfi, ext(fyl_VOM))
vomForest <- mask(fyl_VOM, nfiTile)

# Generate 1km tiles for the fyl VOM 
tiles <-
  rast(extent = ext(fyl_VOM),
       resolution = 1000,
       crs = crs(fyl_VOM)) %>%
  as.polygons() 

gap_list <- list()

for(k in 1:nrow(tiles)) {
  
  # Identify gaps in 1km tiles
  gaps_k <- process_tile(
    rast_full = vomForest,
    tile_sf   = tiles[k,],
    gapMask = nfiTile,
    bufferVal = 20)  
  
  gap_list[[k]] <- gaps_k
}

# Mosaic 1km tiles
gaps_fyl <- do.call(mosaic, gap_list)

# Export gap raster for mosaic tile
exportFilename <- "fylingdales_VOM_gaps.tif"
exportPath <- paste0(path_Z, "gap_map/fylingdales_tile/", exportFilename)

writeRaster(gaps_fyl, exportPath, overwrite = T)


gc()
