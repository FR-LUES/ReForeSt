
copy_NLP_tiles <- function(shapefile, dir) {
  
  # Read in shapefile that notes the tile name for each 5x5km NLP region
  tiles <- read_sf("Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_Data/nlp_catalog_shapefile/nlpCat.shp")

  # Spatial join region of interest and tiles
  polygon_ids <- st_join(shapefile, tiles)
  tile_ids <- unique(polygon_ids$TILENAME)

  # Get a list of tiles in EA shared folder. If there are tiles for multiple years I think this defaults to the most recent one (denoted by the [[1]] index)
  tile_folders <- c()
  for(i in 1:length(tile_ids)){
    
    tile_folders[[i]] <- file.find("Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_Data/EA_Lidar_NP1m_Point_Cloud",
                                   up = 1,
                                   down = 4,
                                   pattern = paste0(tile_ids[[i]], "*"))[[1]]
  }
  
  # Copy Point clouds to dir
  for(j in 1:length(tile_folders)){
    
    file.copy(tile_folders[[j]], dir, recursive = TRUE)
    print(tile_folders[[j]])
    
    }

}