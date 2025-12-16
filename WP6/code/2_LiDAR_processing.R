source("WP6/code/0_setup.R")
source("WP6/code/1_functions.R")

# Read in data ----
# Read in the las catalog for forest Lab sites
labCatalog <- readLAScatalog(path_LiDAR)
# Read in shapefiles
labShapes <- st_read(path_labShapefiles) |>
  st_transform(crs = st_crs(27700))
# Read in subcompartment data
labSub <- read_csv(path_subCompartment, name_repair = "universal") |>
  rename("centroid" = "Sub.Compartment.Centroid..Lat..Lng.") |>
  separate(centroid, into = c("X", "Y"), sep = ",", convert = TRUE)
# Read in dtm
dtm <- rast(path_dtm)



# Join subcompartment data to spatial data ---- 
labSub_spatial <- st_as_sf(labSub, coords = c("Y", "X"), crs = st_crs(4326)) |> # make centroids into spatial object
  st_transform(crs = st_crs(27700)) |>
  select(Property.ID, Compartment.Number, Sub.Compartment.Letter) |> # select relevant information for indexing
  distinct() # Remove duplicate entries where different species are labelled...not needed here.
labShapes_complete <- st_join(labShapes, labSub_spatial, left = TRUE) |>
  na.omit() # Remove entries without subcompartment data




# Clip Point cloud data ----
opt_output_files(labCatalog) <- paste0(path_clipped_outputs, "{Property.ID}_{Compartment.Number}_{Sub.Compartment.Letter}")
cloud_clipped <- clip_roi(labCatalog, st_buffer(labShapes_complete, 30))
# cloud_clipped <- readLAScatalog(path_clipped_outputs)



# Normalise point cloud data
opt_output_files(cloud_clipped) <- paste0(path_normalised_outputs, "{*}")
normalised <- normalize_height(cloud_clipped, dtm = dtm, algorithm = tin())



# Create canopy height models
opt_output_files(normalised) <- paste0(path_chm_outputs, "{*}")
chms <- rasterize_canopy(normalised, res = 1, algorithm = dsmtin())
