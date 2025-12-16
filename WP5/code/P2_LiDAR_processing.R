source("WP5/Scripts/0_setup.R")
source("WP5/Scripts/1_functions.R")







# Read in site shapefile reference catalog
groupBlock_shapes <- st_read(paste0(path_private_shapes, "fellSubset.shp"))
groupBlock_shapesBuffer <- st_buffer(groupBlock_shapes, 500) # buffer to remove edge effects from LiDAR processing.



# List year catalogs
years <- list.dirs(paste0(path_private_lidar), recursive = FALSE, full.names = TRUE)

# Helper function to create folders ---- !#
 #map(years, .f = function(x){
  #chm_path <- paste0(x, "/chms/")
  #dir.create(chm_path)}
   #)
# 

# Read in yearly catalogs ---- !#
ctgs <- map(years, readLAScatalog)
ctgs <- map(ctgs, function(x) {
  st_crs(x) <- 27700
  x
})

# Normalise point clouds ---- !#
# Set output directories for each catalog
for (i in seq_along(ctgs)) {
  opt_output_files(ctgs[[i]]) <- file.path(path_private_lidar, basename(years[[i]]), "Normalised", "{*}")
}

Normalised <- map(ctgs, .f = function(x) normalize_height(x, algorithm = tin()))
Normalised <- map(paste0(years, "/Normalised/"), .f = readLAScatalog)




# Clip point clouds ---- !# 
# Create a folder for each polygon where we can store all temporal LiDAR data
map(groupBlock_shapes$OBJECTID, .f = function(x){
objectID_path <- paste0(path_private_catalogs, x, "/")
dir.create(objectID_path)}
)


# loop over each LAScatalog (each year)
clipped <- map2(Normalised, years, function(cat, yr) {
  yr <- basename(yr)
  
  # set output file pattern so each clip goes into its OBJECT_ID folder
  opt_output_files(cat) <- file.path(path_private_catalogs, "{OBJECTID}", paste0(yr, "_{OBJECTID}"))
  
  # run the clipping
  clip_roi(cat, groupBlock_shapesBuffer)
})

# Read in clipped catalog
clippedDirs <- list.dirs(path_private_catalogs, recursive = FALSE,)
clippedDirs <- clippedDirs[1:36]
dirs_with_files <- clippedDirs[sapply(clippedDirs, function(d) {
   any(file.info(list.files(d, full.names = TRUE))$isdir == FALSE)
 })]

clipped <- map(dirs_with_files, .f = readLAScatalog)
names(clipped) <- basename(dirs_with_files)





# Create chms ---- !#

# I use a bespoke loop instead of catalog map as we do not need buffers and it keeps tiles seperate.
map(clipped, function(x) {
  #x <- clipped[[9]]
  files <- x@data$filename
  for (i in seq_along(files)) {
    
    
    filename <- files[[i]]
    las <- readLAS(filename)
    
    # Clip to forest polygons
    las_list <- clip_roi(las, groupBlock_shapes) |> purrr::compact()
    if (length(las_list) == 0) return(NULL)  # Skip if no overlap
    
    # convert back from  a list to a las
    las_clipped <- las_list[[1]]
    if (npoints(las_clipped) == 0) return(NULL) # Return nothing if there are no points
    
    
    # CHM
    chm <- rasterize_canopy(las_clipped, res = 1, algorithm = dsmtin())
    chm <- mask(chm, groupBlock_shapesBuffer)
    chm <- focal(chm, w = 3, fun = "mean")
    
    # Save
    saveFile <- sub("\\.las$", "", filename)
    writeRaster(chm, paste0(saveFile, ".tif"), overwrite = TRUE)
  }
})
