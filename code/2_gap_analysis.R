### preamble

source("code/0_setup.R")
source("code/1_Functions.R")

### data import

shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
lid <- readLAScatalog(path_test_data_las)
lid <- clip_roi(lid, shapes)

# check

if(nrow(shapes) != length(lid)){
  break()
}

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

calculate_gap_metrics = function(gap_raster) {
  
  df =
    calculate_lsm(landscape = gaps_r,
                  level = c("patch", "landscape"),
                  what = c(p_metrics, l_metrics)) %>% 
    
    # pivot wider to give one row per gap/site
    pivot_wider(names_from = metric,
                values_from = value) %>%
    
    # add site ID
    mutate("site_id" = site_ID,
           .before = id) %>%
    
    # tidy
    select(-c(layer, class, id))
  
  return(df)
}

### loop over sites

datalist_metrics = list()

for (n in 1:nrow(shapes)) {
  
  site_boundary = shapes[n, ]
  site_lidar = lid[[n]]
  site_ID = site_boundary$ID
  
  # extract gaps
  gaps = gapsToDF(site_lidar, site_boundary)
  
  # rasterize
  gaps$presence = 1
  
  template_r = rast(ext(gaps),
                    resolution = 0.1,
                    crs = terra::crs(vect(gaps)))
  
  gaps_r = rasterize(vect(gaps),
                     template_r,
                     field = 'presence')
  
  # calculate metrics
  df_metrics = calculate_gap_metrics(gaps_r)
  
  # add to datalist
  datalist_metrics[[n]] = df_metrics
  print(n)
  
  # tidy
  rm(site_boundary, site_lidar, site_ID, gaps, gaps_r, template_r, df_metrics)
} 

### compile and produce gap and site specific dfs

df_metrics_all = dplyr::bind_rows(datalist_metrics)
rm(datalist_metrics)

df_p_metrics_all =
  df_metrics_all %>% 
  filter(level == "patch") %>% 
  discard(~all(is.na(.)))
  
df_l_metrics_all =
  df_metrics_all %>% 
  filter(level == "landscape") %>% 
  discard(~all(is.na(.)))

### write out 
# gap height and area constants included in filename. Inclusion of fullstop not ideal.

path_out_p = paste0(path_outputs_gap, "gap_metrics_gaps_height_", gapHeight, "_area_", gapSize, ".csv")
path_out_l = paste0(path_outputs_gap, "gap_metrics_sites_height_", gapHeight, "_area_", gapSize, ".csv")

write.csv(df_p_metrics_all, file = path_out_p)
write.csv(df_l_metrics_all, file = path_out_l)


# we could also join metrics to sf objects (of gaps / site boundary) and write shapefiles
