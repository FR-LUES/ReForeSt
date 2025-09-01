# WP3 code description
## Metric extraction
The metric extraction code area  extracts metrics from the national LiDAR programme (nlp). Finally these data are stored in a master dataframe to take forward into the analysis code area.

### 0_setup.R
The set up script needs to be run first and is responsible for loading libraries, defining file paths, and defining constants.

gapHeight = the maximum height foliage can be before it is not considered a gap (meters).
gapSize = the minimum contiguous area that can be defined as a gap if all foliage is below the gapHeight threshold (meters).

p_metrics, l_metrics = A range of higher order gap metrics to extract once gaps have been detected. However, we only use lsm_l_ta (total gap area) as a proportion of the forest area in our analysis.

strata = the height bins used for defining the effective number of top canopy layers and effective number of all canopy layers (including sub-cnaopy) (meters).

### 1_functions.R
The function script defines all the bespoke functions used to extract LiDAR metrics.

chmMatch = A function that reorders shapefiles read in as sf objects so that they math the order of rasters (namely canopy height models (chms)) stored on file. The function is provide with a directory where chms are stored and the sf object. This is not generalizable as it relies on the sf polygons having an "ID" attribute that matches chm file names. This could be adapted to be more generalizable.

gapsToRast = A function to identify gaps within a CHM and returns a raster where non-gaps are NA and gaps are denoted by unique gap IDs. The function takes a CHM alongside a matching sf polygon so that the resulting gap rasters can be masked to the polygon boarders. If you do not mask by a polygon then the surrounding area of the CHM that constitutes a rectangle will be returned as a gap which will confound gap area and gap fraction calculations. When the gap raster is masked some gaps will no longer be above 5 m^2 as the surrounding non-forest area is no longer counted, these areas are removed. raster gap_max_height and min_gap_surface arguments are defined in the setup as gapHeight and gapSize.

gap_clip = A function that uses gapsToRast to remove areas defined as gaps from sf polygons.



