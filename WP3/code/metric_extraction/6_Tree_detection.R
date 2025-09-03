# Now run ine execution script ---- !#
# ### preamble
#


### loop over sites
datalist_ttops <- list()

for (n in 1:nrow(shapes)) {
  
  site_boundary <- shapes[n, ]
  site_chm <- chms[[n]]
  site_las <- readLAS(pointsNormalized[n, ])
  
  ttops_chm <-
    locate_trees(las = site_chm, algorithm = lmf(ws = 10)) %>% 
    st_filter(site_boundary)
  
  ttops_las <-
    locate_trees(las = site_las, algorithm = lmf(ws = 10, hmin = 5)) %>% 
    st_filter(site_boundary)
  
  df_ttops <- tribble(
    ~"ID", ~"ttops_chm", ~"ttops_las",
    site_boundary$ID, nrow(ttops_chm), nrow(ttops_las)
  )
  
  # add to datalist
  datalist_ttops[[n]] <- df_ttops
  
  print(n)
  
  # tidy
  rm(site_boundary, site_chm, site_las, ttops_chm, ttops_las, df_ttops)
} 


### compile

df_ttops_all <- dplyr::bind_rows(datalist_ttops)
rm(datalist_ttops)


### write out 

write.csv(df_ttops_all, file = paste0(path_outputs_ttops, "ttops.csv"))
