source("WP3/code/mapped_outputs/0_setup_gaps.R")
source("WP3/code/mapped_outputs/1_functions.R")

# Load in FHD data
fhd <- rast(paste0(path_fhd, "fhd_england_2020_30m.tif"))


# Read in NFI and filter
nfi <- vect(path_NFI, layer = "NFI2020") %>%
  filter(!IFT_IOA %in% c("Cloud \\ shadow", "Uncertain"))

# Mask
fhd_nfi <- terra::mask(fhd, nfi)
  
# Write
writeRaster(fhd_nfi,
            paste0(path_fhd, "fhd_england_NFI_2020_30m.tif"),
            overwrite = TRUE)
