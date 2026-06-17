source("WP3/code/mapped_outputs/0_setup.R")
source("WP3/code/mapped_outputs/1_functions.R")

# Load in FHD data
fhd <- rast(dir_fhd_map)


# Read in NFI and filter
nfi <- vect(path_NFI, layer = "NFI2020") %>%
  filter(!IFT_IOA %in% c("Cloud \\ shadow", "Uncertain"))

# Mask
fhd_nfi <- terra::mask(fhd, nfi)
  
# Write
writeRaster(fhd_nfi,
            dir_fhd_map_NFI,
            overwrite = TRUE)
