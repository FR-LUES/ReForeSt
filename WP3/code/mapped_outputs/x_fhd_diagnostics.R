library(sf)
library(tidyverse)
library(terra)
source("WP3/code/mapped_outputs/0_setupMosaic.R")
# In this script I identify areas of the NLP that the FHD maps missed


# First I read in the full FHD map
fhd <- rast(paste0(fhdOutPath, "/FHD_full_30m.tif"))
# Read in the nlp catalog
tiles <- st_read("Z:/Projects/FRD_Programme/FRD_20 ReForeSt/fhd_map/check_gaps_2017_to_2022_NP1m_Survey/check_gaps_2017_to_2022_NP1m_Survey/Lidar_used_in_merging_process_2022_FZ_DSM_1m_Composiyte.shp")



# Find the names of the tiles not completely covered by the FHD ---- !#
# Convert tiles to terra for faster spatial ops
tiles_v <- vect(tiles)

# Extract the portion of each tile that intersects FHD
int <- extract(fhd, tiles_v, fun = "m")

# Calculate areas
tiles_area <- expanse(tiles_v, unit = "m")
int_area   <- expanse(int,     unit = "m")

# Combine into a data frame
df <- data.frame(
  tile_id   = tiles$YourTileIDColumn,   # <-- replace with the column that identifies tile name
  full_area = tiles_area,
  covered   = int_area
)

# Tiles not fully covered (covered < full_area)
gaps <- df %>% 
  filter(covered < full_area)

gaps
