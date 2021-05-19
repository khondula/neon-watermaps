library(sf)
library(glue)
library(dplyr)

my_aq_site <- 'BARC'
my_loc_type <- 'buoy.c0'
shp_dir <- 'H:/DATA/spatial'

fs::dir_ls(shp_dir)

fboxes <- st_read(glue('{shp_dir}/aop_boxes/AOP_Flightboxes_2020/AOP_flightboxesAllSites.shp'))

# read in point for AQ site
my_aq_sf <- glue('{shp_dir}/swchem_sites/swchem_sites.shp') %>%
  st_read() %>% 
  dplyr::filter(siteID == my_aq_site) %>%
  mutate(location_type = substr(nmdLctn, 10, nchar(nmdLctn))) %>% 
  dplyr::filter(location_type %in% my_loc_type)

# to get AOP name for AQ site
my_aop_site <- 'results/sites_join_aop_dates.csv' %>%
  readr::read_csv(col_types = 'ccccccccddD') %>%
  dplyr::filter(siteID %in% my_aq_site) %>%
  dplyr::pull(aop_site_id) %>% unique()


my_domain <- my_aq_sf$domanID[1]