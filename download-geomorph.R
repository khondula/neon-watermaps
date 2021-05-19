# Get geomorph links for a site

source('R/neon-download.R')

download_myfiles('BARC', 'data/geomorph', 'DP4.00132.001')
download_myfiles('SUGG', 'data/geomorph', 'DP4.00132.001')
download_myfiles('FLNT', 'data/geomorph', 'DP4.00132.001')
download_myfiles('TOOK', 'data/geomorph', 'DP4.00132.001')
download_myfiles('TOMB', 'data/geomorph', 'DP4.00132.001')
download_myfiles('CRAM', 'data/geomorph', 'DP4.00132.001')
download_myfiles('PRPO', 'data/geomorph', 'DP4.00132.001')
download_myfiles('PRLA', 'data/geomorph', 'DP4.00132.001')
download_myfiles('LIRO', 'data/geomorph', 'DP4.00132.001')
download_myfiles('BLWA', 'data/geomorph', 'DP4.00132.001')

##### download and unzip actual spatial data from urls ####

s3locs <- 'data/geomorph' %>%
  fs::dir_ls(recurse = TRUE, glob = '*.csv') %>%
  purrr::map_dfr(~read_csv(.x)) %>%
  dplyr::select(siteID, dataFilePath)

my_urls <- s3locs$dataFilePath 
my_sites <- s3locs$siteID
site_dirs <- glue('data/spatial/{my_sites}')
fs::dir_create(site_dirs)

my_localpaths <- glue('{site_dirs}/{basename(s3locs$dataFilePath)}')
purrr::walk2(my_urls, my_localpaths, ~download.file(.x, .y))

purrr::walk2(my_localpaths, site_dirs, ~unzip(.x, exdir = .y))
fs::file_delete(my_localpaths)

