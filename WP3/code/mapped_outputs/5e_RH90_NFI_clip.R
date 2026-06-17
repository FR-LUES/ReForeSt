source("WP3/code/mapped_outputs/0_setup.R")
source("WP3/code/mapped_outputs/1_functions.R")

# Load in RH90 data
rh90 <- rast(path_rh90)


# Read in NFI and filter
nfi <- vect(path_NFI, layer = "NFI2020") %>%
  filter(!IFT_IOA %in% c("Cloud \\ shadow", "Uncertain"))


# Mask
rh90_nfi <- terra::crop(rh90, nfi, mask = TRUE)


# Write
writeRaster(rh90_nfi,
            path_rh90_NFI,
            overwrite = TRUE)
