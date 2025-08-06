# Now run ine execution script ---- !#
# ### preamble
#
source("code/metric_extraction/0_setup.R")
source("code/metric_extraction/1_Functions.R")

### test data import

shapes <- st_read(paste0(path_test_data_shp, "testShapes.gpkg"))
chms <- map(dir(path_test_data_chm), function(x) rast(paste0(path_test_data_chm, x)))
clipped <- readLAScatalog(path_test_data_lasNormalised)# Read in LiDAR data

# Order shapes to match chms
shapes <- chmMatch(path_test_data_chm, shapes)


### select site

n <- 3


### Using CHM

chm <- chms[[n]]

ttops_chm <- locate_trees(las = chm, algorithm = lmf(ws = 10,
                                                     shape = "circular"))

### Using point cloud

las <- readLAS(clipped[n, ])

ttops_las <- locate_trees(las = las, algorithm = lmf(ws = 10,
                                                     hmin = 5))

plot(chm)
plot(ttops_chm, col = "white", add = TRUE, cex = 0.5)
plot(ttops_las, col = "red", add = TRUE, cex = 0.5)


### Segmentation

las_dal <- segment_trees(las = las, algorithm = dalponte2016(chm = chm,
                                                             treetops = ttops_las))

las_sil <- segment_trees(las = las, algorithm = silva2016(chm = chm,
                                                          treetops = ttops_las))

plot(las_dal, color = "treeID")
plot(las_sil, color = "treeID")

# extract individual trees

tree100 <- filter_poi(las = las_sil, treeID == 100)
plot(tree100, size = 4)

# extract metrics

metrics <- crown_metrics(las = las_sil, func = .stdtreemetrics)

plot(metrics["Z"])
plot(metrics["convhull_area"])

### Comparison

print(
  tribble(
    ~method, ~ttops,
    "CHM", nrow(ttops_chm),
    "LAS", nrow(ttops_las),
    "Segmentation (Dalponte)", length(unique(las_dal$treeID) %>% na.omit()),
    "Segmentation (Silva)", length(unique(las_sil$treeID) %>% na.omit())
  )
)
