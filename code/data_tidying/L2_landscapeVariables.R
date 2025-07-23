# The purpose of this script is to extract landscape metrics for each woodlands. 
# These metrics are based on the surrounding woodland cover, either semi-natural ancient woodland or more general broadleaves

library(sf)
library(tidyverse)
library(nngeo)

### FUNCTIONS
# A function to find density of surrounding woodland
densFunction <- function(targetBuffer, nonTarget) {
  # Intersect surrounding woodland with buffer
  intersection <- st_intersection(nonTarget, targetBuffer)
  # Find area of overlapping woodland
  intArea <- sum(st_area(intersection))
  # Area of buffer
  buffArea <- st_area(targetBuffer)
  return(round(intArea / buffArea, 2))# Density per area
}


# A function to find the nearest distance between woodlands
nearF <- function(targetWoodland, nonTarget, buffer) {
    #targetWoodland <- shapes[,]
    #nonTarget <- st_intersection(buffer, awi) |> st_difference(targetWoodland)
   # buffer <- diff10k_sf[9,]
   # 
  this_shape <- targetWoodland
  print(this_shape)
  
  
  # Filter to nearby nfi, within 500 m
  non_overlappingProx <- st_intersection(nonTarget, buffer)
  # Compute distances and return the minimum
  Distance <- ifelse(nrow(non_overlappingProx) > 0,
                     min(as.numeric(st_distance(this_shape, non_overlappingProx))),
                     NA)
  
  return(round(Distance, 0))
}

 ggplot()+
   geom_sf(data = buffer)+
 geom_sf(data = non_overlappingProx)+
geom_sf(data = this_shape, fill = "blue")

# READ IN DATA
# Read in sites
shapes <- st_read("Shapefiles/ReForeSt_shapes.gpkg")
# Read in NFI
nfi <- st_read("Shapefiles/nfi/National_Forest_Inventory_England_2022.shp") |>
  filter(IFT_IOA %in% c("Broadleaved",
                        "Mixed mainly broadleaved",
                        "Coppice with standards"))  # remove target woodlands
# Read in AWI
awi <- st_read("Shapefiles/nfi/Ancient_Woodland___Natural_England.shp")
  


# Create buffer around each woodland at 500 m for density estimates
shapeBuffer500 <- st_buffer(shapes,
                            500)
# Remove target woodland from buffer area
shapeBuffer10 <- st_buffer(shapes,
                           10)
diff500 <- map(1:nrow(shapeBuffer500),
                      .f = function(x) st_difference(shapeBuffer500[x,],
                                                      shapeBuffer10[x,]))
diff500_sf <- do.call(rbind,
                      diff500)# Bind into sf
rm(diff500)

# Create buffer around each woodland to help find the nearest woodland
shapeBuffer10k <- st_buffer(shapes,
                            1000)

diff10k <- map(1:nrow(shapeBuffer10k),
               .f = function(x) st_difference(shapeBuffer10k[x,],
                                              shapeBuffer10[x,]))
diff10k_sf <- do.call(rbind,
                      diff10k)# Bind into sf
rm(diff10k)



# For each buffer are find the density of bl woodland per m2
shapes$bl500_m <- map_dbl(1:nrow(shapes),
                       .f = function(x) {
                         densFunction(diff500_sf[x,], nfi)
                       }
                       )


# For each buffer find density of aw woodland per m2
shapes$aw500_m <-  map_dbl(1:nrow(shapes),
                           .f = function(x) {
                             densFunction(diff500_sf[x,], awi)
                           }
                           )




# Find distance to nearest BL woodlands to each target
nearest_distances <- map_dbl(1:nrow(shapes),
                             .f = function(x) {
                             nearF(shapes[x,],
                                   nfi,
                                   diff10k_sf[x,])
                               }
                             )


# Find distance to nearest aw 
nearest_distancesAW <- map_dbl(1:nrow(shapes),
                               .f = function(x) {
                                 nearF(shapes[x,],
                                     awi,
                                     diff10k_sf[x,])
                               }
                              )
    
# attach distances
shapes$nearestBL <- nearest_distances
shapes$nearestAW <- nearest_distancesAW

# find area of each shape
shapes$area_ha <- st_area(shapes)/ 10000 |> as.numeric()

#shapes <- shapes |> rename("Source" = "source")
st_write(shapes, "Shapefiles/ReForeSt_shapes.gpkg")
shapes
