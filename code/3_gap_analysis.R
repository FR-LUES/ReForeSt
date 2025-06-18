### preamble

source("code/0_setup.R")
source("code/1_Functions.R")

### data import

shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
chms <- map(dir(path_test_data_chm), function(x) rast(paste0(path_test_data_chm, x)))

# Order shapes to match chms
shapes <- chmMatch(path_test_data_chm, shapes)

# check

if(nrow(shapes) != length(chms)){
  break()
}

### loop over sites

datalist_metrics = list()

for (n in 1:nrow(shapes)) {
  
  site_boundary = shapes[n, ]
  site_chm = chms[[n]]
  
  # extract gaps
  gaps = gapsToRast(site_chm, site_boundary)
  
  # calculate metrics
  df_metrics = calculate_gap_metrics(gaps[[1]], site_boundary$ID)
  
  # add to datalist
  datalist_metrics[[n]] = df_metrics
  print(n)
  
  # tidy
  rm(site_boundary, gaps, df_metrics)
} 

### compile and produce gap and site specific dfs

df_metrics_all = dplyr::bind_rows(datalist_metrics)
rm(datalist_metrics)

df_p_metrics_all =
  df_metrics_all %>% 
  filter(level == "patch") %>% 
  select(c("level", "site_id", str_remove(p_metrics, "lsm_p_")))
  
df_l_metrics_all =
  df_metrics_all %>% 
  filter(level == "landscape") %>% 
  select(c("level", "site_id", str_remove(l_metrics, "lsm_l_")))

### write out 
# gap height and area constants included in filename. Inclusion of fullstop not ideal.

path_out_p = paste0(path_outputs_gap, "gap_metrics_gaps_height_", gapHeight, "_area_", gapSize, ".csv")
path_out_l = paste0(path_outputs_gap, "gap_metrics_sites_height_", gapHeight, "_area_", gapSize, ".csv")

write.csv(df_p_metrics_all, file = path_out_p)
write.csv(df_l_metrics_all, file = path_out_l)


# we could also join metrics to sf objects (of gaps / site boundary) and write shapefiles
