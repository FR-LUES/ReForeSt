source("WP3/code/mapped_outputs/0_setup_gaps.R")
source("WP3/code/mapped_outputs/1_functions.R")

# Load in FHD data
fhd <- rast("Z:/Projects/FRD_Programme/FRD_20 ReForeSt/02_data/01_processed_data/fhd_map/fhd_full_30m_corrected.tif")


# Read in NFI and filter
nfi <- vect(path_NFI, layer = "NFI2020") %>%
  filter(!IFT_IOA %in% c("Cloud \\ shadow", "Uncertain"))

# Mask
fhd_nfi <- terra::mask(fhd, nfi)
  
# Write
writeRaster(fhd_nfi,
            paste0(path_Z_proc_data, "fhd_map/fhd_nfi_30m.tif"),
            overwrite = TRUE)
