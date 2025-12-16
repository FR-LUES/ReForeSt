source("WP5/Scripts/0_setup.R")
source("WP5/Scripts/1_functions.R")







# Read in site shapefile reference catalog ---- !~
groupBlock_shapes <- st_read(paste0(path_private_shapes, "fellSubset.shp"))
shapeUnion <- st_combine(groupBlock_shapes)

# List year catalogs
years <- list.dirs(paste0(path_private_lidar), recursive = FALSE, full.names = TRUE)



# Read in CHMs ---- !#
# Create named list of CHM rasters by polygon
shapeFolders <- map(groupBlock_shapes$OBJECTID, .f = function(x) paste0(path_private_catalogs, x, "/"))
chms <- map(shapeFolders, function(path) {
  #path <- shapeFolders[[13]]
  chm_files <- list.files(file.path(path), pattern = "\\.tif$", full.names = TRUE)
  map(chm_files, function(f) {
    r <- rast(f)
    crs(r) <- "epsg:27700"
    names(r) <- basename(f)
    r
  })
})
names(chms) <- file.path(shapeFolders) |> basename()




# Create metric rasters ---- !#

# effective number of top layers
effLayers <- map(names(chms), .f = function(shape){
  #shape <- "55"
  map(chms[[shape]], .f = function(chm) {
    fhd <- zonal_effCanopyLayer(chm, shape = shapeUnion, res = 30, strata)
    names(fhd) <- names(chm)
    fhd
    #fhd = mask(fhd, vect(shapeUnion)) # mask to remove edge effects
    
  })
})

names(effLayers) <- file.path(shapeFolders) |> basename()
# Gap rasters
gaps <- map(names(chms), .f = function(shape){
  #shape <- names(chms)[[13]]
  map(chms[[shape]], .f = function(chm) {
    #chm <- chms[[shape]][[1]]
    gap <-  gapsToRast(chm, Shape = shapeUnion)[[2]]
    names(gap) <- names(chm)
    gap
  })
})
names(gaps) <- file.path(shapeFolders) |> basename()





# Extract metrics to polygon IDs
metricsList <- list()


for (i in seq_len(nrow(groupBlock_shapes))) {
  #i <- 13
  poly <- groupBlock_shapes[i, ]
  #poly <- vect(groupBlock_shapes[groupBlock_shapes$OBJECTID == 11777,])
  obj_id <- as.character(groupBlock_shapes$OBJECTID[i])
  
  # Create sublist for this object if it doesn't exist
  metricsList[[obj_id]] <- list()
  
  path <- paste0(path_private_catalogs, obj_id, "/")
  chmList <- list.files(file.path(path), pattern = "\\.tif$", full.names = TRUE)
  if(length(chmList) < 1){next}
  for (p in seq_along(chmList)) {
    #p <- 5
  
    #year_name <- "2008"
    # Create sublist for this year within object
    metricsList[[obj_id]][[p]] <- list(
      meanHeight = NA,
      meanFHD = NA,
      gapFract = NA
    )
    
      chm <- chms[[obj_id]][[p]]
      eff <- effLayers[[obj_id]][[p]]
      gap <- gaps[[obj_id]][[p]]
      
    
      # Compute metrics
      metricsList[[obj_id]][[p]]$meanHeight <- global(chm, mean, na.rm = TRUE)[1] |> as.numeric()
      metricsList[[obj_id]][[p]]$meanFHD    <- global(eff, mean, na.rm = TRUE)[1] |> as.numeric()
      metricsList[[obj_id]][[p]]$gapFract    <- global(gap, sum, na.rm = TRUE)[1] |> as.numeric()
      metricsList[[obj_id]][[p]]$gapFract <- metricsList[[obj_id]][[p]]$gapFract  / st_area(poly)
    
  }
  names(metricsList[[obj_id]]) <- str_extract(basename(chmList), "^\\d{4}")
    }
  



metrics_df <- map_df(names(metricsList), function(obj_id) {
  map_df(names(metricsList[[obj_id]]), function(yr) {
    tibble(
      OBJECTID = obj_id,
      Year = yr,
      meanHeight = metricsList[[obj_id]][[yr]]$meanHeight,
      meanFHD    = metricsList[[obj_id]][[yr]]$meanFHD,
      gapArea    = metricsList[[obj_id]][[yr]]$gapArea
    )
  })
})
metrics_df <- na.omit(metrics_df)
View(metrics_df)
