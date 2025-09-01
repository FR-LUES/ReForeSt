# ReForeSt - remote sensing of forest management and structural diversity

![lidar_spin_final](https://github.com/user-attachments/assets/a30a580e-f2da-48ed-94dd-f7f1f4d2e771)

## Introduction          
The aim of this project is to link LiDAR derived structural metrics to forest biodiversity and in turn use LiDAR to explore how management interventions can enhance forest structure. The project comprises three seperate work packages (WPs): the first explores how LiDAR derived forest structure metrics can supplement/enhance/replace field derived metrics when explaining patterns of biodiversity, these metrics are then scaled to the national level; the second looks at LiDAR derived structural metrics through time as forests undergo different management interventions; and the third pilots the use of synthetic canopy height models (sCHMs), derived from aerial imagery, for measuring forest structural attributes. These three work packages are labelled WP3-WP5 as this is part of a wider project, not all of which is included in this repo. Below we described each work package in detail and we also link to more in depth descriptions of the code. General information about our code structure is provided in Box 1.

> **_BOX 1: Code structure_**
Each work package has its own set of scripts and these can all be found in the code folder. However, inputs and outputs for these scripts are stored together as they may overlap between work packages. We use a standard scripting pipeline for each work package where scripts 0 and 1 are setup and function scripts respectively. The setup script defines things like constants and file paths where the function script defines...functions. These two scripts MUST be run first for any of the following worker scripts to work. The worker scripts are also numbered and generally should be run sequentially, however you may be able to get away with running scripts in isolation as long as the setup and function scripts have been run. 

## WP3:
### Linking LiDAR to biodiversity
Here, we collate biodiversity surveys from past Forest Research projects into a larger database and extract 
