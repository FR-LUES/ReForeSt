source("WP3/code/mapped_outputs/0_setup.R")
source("WP3/code/mapped_outputs/1_functions.R")

# turn off parallelisation
plan(sequential)


# read in data
fhd <- rast(paste0(fhdOutPath, "fhd_incomplete_2020_30m.tif"))
dtm <- rast(paste0(sharePath, "DTM/LIDAR_Composite_10m_DTM_2022.tif"))
nlp_cat <- vect(catalogPath)
england <-
  vect("Z:/CESB/Land Use and Ecosystem Service/LUES_Sware/PersonalFolders/Joe/Data/ONS_Open_Geography/Countries_Dec_2021_GB_BFC_2022_6264036014383714060.gpkg") %>% 
  filter(CTRY21NM == "England")
  
  
# identify areas to reproduce and NLP tiles
aoi_ny <- ext(425000, 430000, 400000, 410000) # area in Yorkshire with no FHD
aoi_wb <- ext(321000, 350000, 325000, 342500) # area of Welsh Borders

nlp_ny <- terra::crop(nlp_cat, aoi_ny)
nlp_wb <- terra::crop(nlp_cat, aoi_wb)

tiles <- append(nlp_ny$PNT_FN, nlp_wb$PNT_FN)


# calculate FHD for tiles
for (i in tiles) {
  las_path <-
    list.files(
      path = nlpPath,
      pattern = i,
      recursive = TRUE,
      full.names = TRUE)
  
  tile <- sub("_.*", "", i)
  
  if(length(las_path) == 0) {
    print(tile)
    next}

  ctg <- readLAScatalog(las_path)
  opt_output_files(ctg) <- paste0(fhdOutPath, "corrections/{XCENTER}_{YCENTER}_FHD_30m")
  
  # check within England
  ctg_vect <- vect(ext(ctg))
  overlap <- terra::intersect(ctg_vect, england)
  
  if(length(overlap) == 0) {
    print(tile)
    next}
  
  normalized_chunk <- lidR::normalize_height(ctg, tin(), dtm = dtm)
  fhdRast <- lidR::pixel_metrics(normalized_chunk, ~fhdFunction(Z, strata), res = 30)
  
  print(tile)
}


# merge into FHD
# identify new tiles
new_tiles <- list.files(paste0(fhdOutPath, "corrections"), pattern = "\\.tif$", full.names = TRUE)
rast_list <- lapply(new_tiles, rast)
ext_list <- lapply(rast_list, ext)

# mask out reproduced areas from FHD
fhd_masked <- fhd

for (e in ext_list) {
  fhd_masked <- mask(fhd_masked, e, inverse = TRUE)
}

# mosaic reproduced areas with masked FHD
rast_list_full <- append(rast_list, fhd_masked)
fhd_updated <- do.call(mosaic, rast_list_full)


# clip to England
fhd_final <- mask(fhd_updated, england)
varnames(fhd_final) <- varnames(fhd)

writeRaster(fhd_final,
            paste0(fhdOutPath, "fhd_england_2020_30m.tif"),
            overwrite = TRUE)
