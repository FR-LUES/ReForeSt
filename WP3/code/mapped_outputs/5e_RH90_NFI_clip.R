source("WP3/code/mapped_outputs/0_setup_gaps.R")
source("WP3/code/mapped_outputs/1_functions.R")

# Load in RH90 data
rh90 <- rast(paste0(path_Z_rh90, "rh90_england_2020_30m.tif"))


# Read in NFI and filter
nfi <- vect(path_NFI, layer = "NFI2020") %>%
  filter(!IFT_IOA %in% c("Cloud \\ shadow", "Uncertain"))

# Mask
rh90_nfi <- terra::crop(rh90, nfi, mask = TRUE)

# Write
writeRaster(rh90_nfi,
            paste0(path_Z_rh90, "rh90_england_NFI_2020_30m.tif"),
            overwrite = TRUE)

