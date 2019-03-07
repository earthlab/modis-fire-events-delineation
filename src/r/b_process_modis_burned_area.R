
# Vector of MODIS tiles to download
tiles <- get_tiles(usa)

# Download all HDF files from 2001-2017 for the CONUS
download_tiles(tiles, out_dir = hdf_months)

# Convert the raw HDF to GeoTifs
convert_hdf_tif(tiles, in_dir = hdf_months, out_dir = tif_months, n_cores = parallel::detectCores(), layer_names = "BurnDate")

# Create yearly raster based on the max burned date of each month
aggreate_to_yearly(tiles, n_cores = parallel::detectCores(), year_range = '2001:2017', 
                   in_dir = tif_months = tif_year, out_dir)

# Mosaic the yearly tiles to yearly CONUS rasters
mosaic_tiles(year_range = '2001:2017', n_cores = parallel::detectCores()/2,  in_dir = tif_months, out_dir = yearly_composites, 
             mask = usa, to_project = TRUE, projection = p4string_ea, projected_resolution = '500', projection_method = 'ngb')

system("aws s3 sync data/MCD64A1/C6 s3://earthlab-natem/modis-burned-area/MCD64A1/C6")