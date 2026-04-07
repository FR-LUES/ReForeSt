source("WP3/code/mapped_outputs/0_setup_gaps.R")
source("WP3/code/mapped_outputs/1_functions.R")

# read in nfi
nfi <- 
  st_read(paste0(path_Z_raw_data, "NFI/NFI2020.gpkg"),
          layer = "NFI2020") %>%
  filter(Country == "England",
         IFT_IOA %in% c("Broadleaved",
                        "Conifer",
                        "Mixed mainly broadleaved",
                        "Mixed mainly conifer",
                        "Coppice",
                        "Coppice with standards",
                        "Low density"))


# read in districts
districts <- st_read("Z:/CESB/Land Use and Ecosystem Service/LUES_Sware/PersonalFolders/Joe/Data/SCDB_20250331/EoY2425_FE_INV.gdb",
                     layer = "INV_DISTRICT") %>% 
  filter(region == 100) %>% 
  select(district, region, d_code)


# join districts to nfi
nfi_districts <-
  nfi_all %>%
  st_join(., districts, left = TRUE) %>% 
  vect()


# read in gap fraction
gap_frac <- rast(path_Z_gap_frac_eng)


# calculate gap fraction mean for nfi units
# intensive - 24h on 15.4 cluster
nfi_gap_frac_mean <- 
  terra::extract(x = gap_frac,
                 y = nfi_districts,
                 fun = mean,
                 exact = FALSE,
                 na.rm = TRUE,
                 bind = TRUE)


# write out
writeVector(nfi_gap_frac_mean,
            paste0(path_Z_proc_data, "gap_fraction/nfi_2020_analysis/nfi_2020_gap_fraction.gpkg"),
            overwrite = TRUE)
