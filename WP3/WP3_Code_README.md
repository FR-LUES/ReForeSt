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

canopyEntropy = A function to extract the effective number of top canopy layers (uses CHMs and does not look at sub-canopy returns). Effective layers are based on user defined strata and the exponential of shannon's diversity of how the canopy is distributed across these strata.

effCanopyLayer = A function which takes the canopyEntropy function and runs it over a CHM. The CHM is cropped by a corresponded woodland polygon to avoid edge effects. One value is returned per CHM

zonal_effCanopyLayer = A function that runs canopyEntropy zonally over a raster at a user defined resolution. A raster is returned where each value is the effective number of top canopy layers.

fhdFunction = Similar to canopyEntropy by is designed to operate on a vector of point heights from a point cloud and returned the effective number of foliage layers across user defined strata. First creates a leaf area density profile at high height bin resolution (1 m bins). Leaf area density is calculated as the number of points returned from a height bin as a proportion of the total number of points to actually reach that height bin. The function then calculates how these densities are distributed across user defined 

### 2_CHMS.R
This script takes NLP point clouds, clips them to a set of polygons, creates digital terrain models, digital surface models and in turn CHMS. It also cleans and normalizes point clouds so that each point reflects height above ground and not elevation. CHMs and Normalized point clouds are saved to file.

### 3_canopyHeightVariation.R

This script calculates the top canopy height diversity of each woodland based on the canopyEntropy function. It returns a total value for each chm as well as a mean value across zonal_effCanopyLayer rasters at 10 m and 30 m resolution. Dataframes are saved to file as well as the zonal rasters.

### 4_gap_analysis.R

This script detects gaps in each chm and calculates a range of metrics relating to them. We are primarily interested in the area of gaps in each woodland and in turn the gap fraction. These metrics are saved to file as a dataframe.

### 5_ FHD.R

This script calculates the effective number of foliages layers including subcanopy-returns and not just top canopy CHM values. We calculate this on point clouds where gaps have been removed - to make it completely independent of gap area metrics - and without gaps removed - just for completion. Like canopyHeightVariation.R we calculate values for the whole site and zonal values for 10 m and 30 m rasters. All metrics are saved to file.

### 6_Tree_detection.R

This script detections tree tops from las files and from chms and saves both detections to file. This is based on local maxima within a moving window. 

### 7_execution.R

This script runs all the scripts in order and then combines their dataframes into a final master metrics csv output.

