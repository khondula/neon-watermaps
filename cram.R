library(sf)
library(glue)
library(dplyr)
library(ggplot2)

my_aq_site <- 'CRAM'
my_loc_type <- 'buoy.c0'
shp_dir <- '/Volumes/hondula/DATA/spatial'

fs::dir_ls(shp_dir)

fboxes <- st_read(glue('{shp_dir}/aop_boxes/AOP_Flightboxes_2020/AOP_flightboxesAllSites.shp'))
head(fboxes)

# read in point for AQ site
my_aq_sf <- glue('{shp_dir}/swchem_sites/swchem_sites.shp') %>%
  st_read() %>% 
  dplyr::filter(siteID == my_aq_site) %>%
  mutate(location_type = substr(nmdLctn, 10, nchar(nmdLctn))) %>% 
  dplyr::filter(location_type %in% my_loc_type)

my_fbox <- dplyr::filter(fboxes, siteID == my_aq_site)

my_fbox %>%
  ggplot() +
  geom_sf() +
  geom_sf(data = my_aq_sf) +
  ggtitle(glue('{my_aq_site} {my_aq_sf$domanID}'))

# Bathymetric and morphological maps

## CRAM

cram_site_shps <- glue('data/spatial/CRAM') %>% 
  fs::dir_ls(glob = '*.shp')
cram_site_shps

cram_contour2015 <- st_read(cram_site_shps[1]) 
cram_shore2015 <- st_read(cram_site_shps[3])
cram_hab2015 <- st_read(cram_site_shps[4])

cram_shore2015 %>%
  ggplot() +
  geom_sf()

cram_hab2015 %>% 
  ggplot() +
  geom_sf(aes(fill = Habitat)) +
  theme_void() +
  ggtitle(glue('{my_aq_site} 2015'))

cram_contour2015 %>% 
  ggplot() +
  geom_sf(aes(color = CONTOUR)) +
  theme_void() +
  ggtitle(glue('{my_aq_site} 2015'))

# JRC
# get my_jrc_stars from jrc-water.R
my_fbox %>%
  ggplot() +
  geom_sf() +
  geom_stars(data = my_jrc_stars) +
  scale_fill_manual(values = attr(my_jrc_stars[[1]], 'colors')) +
  geom_sf(data = cram_shore2015, fill = NA, col = "green") +
  theme_void() +
  theme(legend.position = "none") +
  ggtitle(glue('CRAM {my_aq_sf$domanID}'))

ggsave('figs/CRAM.png')


# buffer 20 m
aop_path <- glue('/Volumes/hondula/DATA/AOP/site-polygons/CRAM_2015.shp')
cram_shore2015_buff <- cram_shore2015 %>% st_zm() %>% st_buffer(20)
cram_shore2015_buff %>% st_write(aop_path)

