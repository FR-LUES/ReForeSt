### preamble

source("code/0_setup.R")
source("code/1_Functions.R")

### data import

shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
lid <- readLAScatalog(path_test_data_las)
lid <- clip_roi(lid, shapes)

# check

if(nrow(shapes) != length(lid))
  break()


### define metrics (move to 0_ script?)

p_metrics = c("lsm_p_area",
              "lsm_p_perim",
              "lsm_p_para",
              "lsm_p_enn")

l_metrics = c("lsm_l_np",
              "lsm_l_pd",
              "lsm_l_area_mn",
              "lsm_l_area_sd",
              "lsm_l_enn_mn",
              "lsm_l_enn_sd",
              "lsm_l_cohesion")

### functions (move to 1_ script?)

calculate_p_metrics = function(gap_raster) {
  
  df =
    calculate_lsm(landscape = gaps_r,
                  level = c("patch"),
                  what = p_metrics) %>% 
    
    # pivot wider to give one row per gap
    pivot_wider(names_from = metric,
                values_from = value) %>%
    
    # add site ID
    mutate("Site_ID" = site_ID,
           .before = id) %>% 
    
    # tidy
    rename(gap_id = id) %>% 
    convert(int(gap_id)) %>%
    select(-c(layer, level, class))
  
  return(df)
}


calculate_l_metrics = function(gap_raster) {
  df =
    calculate_lsm(landscape = gaps_r,
                  level = c("landscape"),
                  what = l_metrics) %>% 
    
    # pivot wider to give one row per gap
    pivot_wider(names_from = metric,
                values_from = value) %>%
    
    # tidy
    rename(ID = id) %>% 
    convert(int(ID)) %>% 
    select(-c(layer, level, class))
  
  df$ID = site_ID
  
  return(df)
}


### loop

datalist_p_metrics = list()
datalist_l_metrics = list()

for (n in 1:nrow(shapes)) {
  
  site_boundary = shapes[n, ]
  site_lidar = lid[[n]]
  site_ID = site_boundary$ID
  
  # extract gaps
  gaps = gapsToDF(site_lidar, site_boundary)
  
  # rasterize (this could be improved)
  gaps_v = vect(gaps)
  gaps_v$presence <- 1
  
  r_template = rast(ext(gaps_v),
                    resolution = 0.1,
                    crs = terra::crs(gaps_v))
  
  gaps_r = rasterize(gaps_v,
                     r_template,
                     field = 'presence')
  
  # calculate metrics
  df_p_metrics = calculate_p_metrics(gaps_r)
  df_l_metrics = calculate_l_metrics(gaps_r)
  
  # add to datalist
  datalist_p_metrics[[n]] = df_p_metrics
  datalist_l_metrics[[n]] = df_l_metrics
  print(n)
  
  # tidy
  rm(site_boundary, site_lidar, site_ID, gaps, gaps_v, gaps_r, r_template, df_p_metrics, df_l_metrics)
} 

### compile

df_p_metrics_all = dplyr::bind_rows(datalist_p_metrics)
df_l_metrics_all = dplyr::bind_rows(datalist_l_metrics)
rm(datalist_l_metrics, datalist_p_metrics)

### write out 
# gap height and area constants included in filename. Inclusion of fullstop not ideal.

path_out_p = paste0(path_outputs_gap, "gap_metrics_gaps_height_", gapHeight, "_area_", gapSize, ".csv")
path_out_l = paste0(path_outputs_gap, "gap_metrics_sites_height_", gapHeight, "_area_", gapSize, ".csv")

write.csv(df_p_metrics_all, file = path_out_p)
write.csv(df_l_metrics_all, file = path_out_l)


# we could also join metrics to sf objects (of gaps / site boundary) and write shapefiles
