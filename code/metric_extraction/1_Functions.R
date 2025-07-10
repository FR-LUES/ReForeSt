# # This section is only for testing functions ---- !#
# 
# 
# # # Read in constants
# source("code/0_setup.R")
# # 
# # # Read in test data and reorder shapefiles
# shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
# shapes <- chmMatch(path_test_data_chm, shapes)
# chms <- map(dir(path_test_data_chm), function(x) rast(paste0(path_test_data_chm, x)))
# 



# This script is to define functions needed to extract
# structural metrics from the clipped and normalised NLP data.





# Utility functions ---- !#
# Function to match the order of polygons and chms
chmMatch <- function(chmDir, Shapes){
  Files <- dir(chmDir) # Find files in the folder
  #chmIds <- as.numeric(gsub("\\.tif$", "", Files)) # Remove file name extensions and turn numeric
  chmIds <- gsub("\\.tif$", "", Files) # Remove file name extensions
  shapes_reordered <- Shapes[match(chmIds, Shapes$ID),]
  return(shapes_reordered)
}





# Gap fraction ---- !# 
# This function takes a canopy height model and turns it into a raster denoting forest gaps
# The function returns an SpatRaster object

# chm is the canopy height model
# Shape is the corresponding SF object for the chm
gapsToRast <- function(chm, Shape){
  # Gap detection algorithm based on max height within gaps and a minimal surface area
  gapSF <- gap_detection(chm,
                         res = 1,
                         gap_max_height = gapHeight,
                         min_gap_surface = gapSize)
  
  # Areas external to the woodland are considered gaps to fill out raster
  # These areas are removed below
  gapMask <- mask(gapSF, buffer(vect(Shape), -1.5))# remove external area by masking by site
  # Identify where this area protruded to count gaps smaller than our minimum surface
  freqs <- freq(gapMask[[1]])
  freqsSubset <- freqs[freqs$count >= gapSize, ]
  validGaps <- unique(freqsSubset$value)
  
  # Remove small gaps using the earlier freqs subset
  gaps <- tidyterra::filter(gapMask, gap_id %in% validGaps)
  
  return(gaps)
}


# Calculate gap metrics function
# This function takes a gaps raster (produced by gapsToRast function) and calculates metrics defined in 0_setup script
# Uses landscapemetrics package
# The function returns a df

# gap_raster is the gaps object
# site_ID is the ID of the site on which metrics are being calculated
calculate_gap_metrics = function(gap_raster, site_ID) {
  
  df =
    calculate_lsm(landscape = gap_raster,
                  level = c("patch", "landscape"),
                  what = c(p_metrics, l_metrics)) %>% 
    
    # pivot wider to give one row per gap/site
    pivot_wider(names_from = metric,
                values_from = value) %>%
    
    # add IDs
    mutate("gap_id" = id,
           "site_id" = site_ID,
           .before = id) %>%
    
    # tidy
    select(-c(layer, class, id))
  
  return(df)
}






# Top canopy heights----#!
# Entropy function to operate at varying resolutions
canopyEntropy <- function(heights, strata){
  # Tidy some ground heights
  heights[heights < 0] <- 0
  heights <- heights[!is.na(heights)]
  # Bin Heights into stratas
  bins <- cut(heights, strata, labels = FALSE, include.lowest = TRUE)
  # find frequency of values in each bin
  freqs <- table(factor(bins, levels = 1:(length(strata)-1)))
  
  # Calculate effective canopy layers
  total_values <- sum(freqs)
  proportions <- freqs/total_values
  shannon_index <- -1*sum(proportions * log(proportions), na.rm = TRUE)
  effectiveCanopyLayers <- exp(shannon_index) |> round(2)
  return(effectiveCanopyLayers)
}


# This function takes a CHM and masks it by a corresponding shapefile to remove edge effects
# It then calculates Shannon's diversity index using chm values based on user defined canopy height bins
# Strata is user defined height bins
effCanopyLayer <- function(chm, shape, strata){
  
  chmMask <- mask(chm, st_buffer(shape,-5))
  canopyLayers <- canopyEntropy(values(chm), strata = strata)
}


# Zonal eff Canopy layer function ---- !#
# This function is for computing effective canopy layers zonally at varying cell resolutions
zonal_effCanopyLayer <- function(chm, shape, res, strata){
  # Remove edge effects
  chm <- mask(chm, st_buffer(shape, 10))
  effCanopyRaster <- raster_metrics(chm,
                                    fun = function(x)
                                      data.frame(effCanopy = canopyEntropy(x, strata = strata)),
                                    res = res
  )
  return(effCanopyRaster)  
}








# Texture analysis ---- !#
# This function converts a raster to a GLCM texture matrix
# The function returns descriptive metrics relating to its contrast and entropy
# These are returned as a list

chmTexture <- function(chm, shape){
  # Coerce chm values into discrete height bins
  levels <- chm |> values() |> na.omit() |>
    max() |> ceiling()
  rasterDiscrete <- quantize_raster(chm, n_levels = levels, quant_method = "range")
  
  # mask raster by the shape to remove edge effects
  rasterMask <- mask(rasterDiscrete, st_buffer(shape, -10))
  
  # Calculate texture rasters
  glcmRasters <- glcm_textures(rasterMask, quant_method = "none", w = 5, n_levels = levels, shift = c(1, 1))
  
  # entropy values
  glcmEntropy_mean <- glcmRasters$glcm_entropy |> values() |>
    na.omit() |> mean()
  glcmEntropy_sd <- glcmRasters$glcm_entropy |> values() |>
    na.omit() |> sd()
  
  # contrast values
  glcmContrast_mean <- glcmRasters$glcm_contrast |> values() |>
    na.omit() |> mean()
  glcmContrast_sd <- glcmRasters$glcm_contrast |> values() |>
    na.omit() |> sd()
  
  # correlation values
  glcmCorrelation_mean <- glcmRasters$glcm_correlation |> values() |>
    na.omit() |> mean()
  glcmCorrelation_sd <- glcmRasters$glcm_correlation |> values() |>
    na.omit() |> sd()
  
  return(data.frame(glcmCorrelation_mean, glcmCorrelation_sd, glcmContrast_mean,
                    glcmContrast_sd, glcmEntropy_mean, glcmEntropy_sd))
}
  




# Foliage Height Diversity ---- !#
# This function is to calculate the eveness of foliage spread through the vertical canopy
# It can be caculated at the site level or at the cell level
# To correct for occlusion from higher canopy levels we calculate foliage density
# only including points that actually reached each canopy layer
las <- readLAS(paste0(path_test_data_lasNormalised, "1105206.laz"))
cloud <- las@data$Z
FHD <- function(cloud, maxHeight){# Cloud is a vector of heights
  # Calculate the LAD profile of the height vector
  ladDF <- LAD(cloud, dz = 2, z0 = 1, k = 0.3)
  
  # Filter out any NA or zero LAD values to avoid log(0)
  ladDF <- ladDF[ladDF$lad > 0, ]
  
  # Proportional LAD in each layer
  ladDF$prop <- (ladDF$lad / sum(ladDF$lad)) |> round(6)

  # Shannon entropy
  H <- -sum(ladDF$prop * log(ladDF$prop))
  
  # Maximum possible entropy (uniform distribution)
  Hmax <- log(length(seq(2, max(cloud), by = 2)))
  
  # Shannon's eveness
  E <- H / Hmax
  
  return(E)
}
