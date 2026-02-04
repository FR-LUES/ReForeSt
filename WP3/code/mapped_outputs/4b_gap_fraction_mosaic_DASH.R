# Mosaic tiles
mosaicFunction_DASH(path_gap_frac_tiles_DASH,
                    path_gap_frac_eng_DASH,
                    "gap_fraction_30m_raw")


# Clamp raster values to 1
gap_fraction_30m <- rast(paste0(path_gap_frac_eng_DASH, "gap_fraction_30m_raw.tif"))
gap_fraction_30m_clamp <- clamp(gap_fraction_30m, upper = 1)


# Use a local path for writing
localPath <- "/tmp/gap_fraction_30m.tif"
writeRaster(gap_fraction_30m_clamp, localPath, overwrite = T)


# Copy to DBFS
file.copy(localPath, paste0(path_gap_frac_eng_DASH, "gap_fraction_30m.tif"))
file.remove(localPath)