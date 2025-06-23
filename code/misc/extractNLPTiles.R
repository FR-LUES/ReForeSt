library(sf)
library(common)
library(fs)
library(tidyverse)

# Read in regions of interests, these can be any geometry 
roi <- read_sf("~/nlpWorkFlow/data/ReForeSt_shapes.gpkg")
roi <- st_zm(roi)
roi <- st_transform(roi, crs = st_crs(27700))
#roi <- st_set_crs(roi, st_crs(tiles))
#Read in shapefile that notes the tile name for each 5x5km NLP region
tiles <- read_sf("~/nlpWorkFlow/data/nlpCat.shp")

# Spatial join region of interest and titles
polygon_ids <- st_join(roi, tiles)
View(polygon_ids)

# Needed tile Names
tileIDS <- unique(polygon_ids$TILENAME)



ggplot(data = polygon_ids)+
geom_sf()+
geom_sf(data = tiles[tiles$PNT_FN %in% tileIDS,], alpha = 0.1)
# Get a list of tiles in EA shared folder. If there are tiles for multiple years I think this defaults to the most recent one (denoted by the [[1]] index)
tileFolders <- c()
for(i in seq(along = tileIDS)){
tileFolders[[i]] <- file.find("Z:/CESB/Land Use and Ecosystem Service/GIS_Data/EA_Data/EA_Lidar_NP1m_Point_Cloud", up = 1, down = 4, pattern = paste0(tileIDS[[i]], "*"))[[1]]
print(tileFolders[[i]])
}

# Copy Point clouds to new folder, need to add own file path
for(i in seq(along = 1:length(tileFolders))){

    file.copy(tileFolders[[i]], "C:/Users/sam.hughes/OneDrive - Forest Research/Documents/ReForeSt/nlp/", recursive = TRUE)
    print(i)
}
tileFolders

