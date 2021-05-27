library(sf)
library(glue)
library(dplyr)
library(ggplot2)

my_aq_site <- 'FLNT'
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

## FLNT

site_shps <- glue('data/spatial/{my_aq_site}') %>% 
  fs::dir_ls(glob = '*.shp')
site_shps
survey_yr <- 2017
site_contour <- st_read(site_shps[1]) 
site_shore <- st_read(site_shps[2])
site_hab <- st_read(site_shps[3])

site_shore %>%
  ggplot() +
  geom_sf()

site_hab %>% 
  ggplot() +
  geom_sf(aes(fill = Habitat)) +
  theme_void() +
  ggtitle(glue('{my_aq_site} {survey_yr}'))

site_contour %>% 
  ggplot() +
  geom_sf(aes(color = CONTOUR)) +
  theme_void() +
  ggtitle(glue('{my_aq_site} {survey_yr}'))

# JRC
# get my_jrc_stars from jrc-water.R
my_fbox %>%
  ggplot() +
  geom_sf() +
  geom_stars(data = my_jrc_stars) +
  scale_fill_manual(values = attr(my_jrc_stars[[1]], 'colors')) +
  geom_sf(data = site_shore, fill = NA, col = "green") +
  # theme_void() +
  theme(legend.position = "none") +
  coord_sf(ylim = c(31.155, 31.2), 
           xlim = c(-84.48, -84.418)) +
  ggtitle(glue('{my_aq_site} {my_aq_sf$domanID}'))

ggsave(glue('figs/{my_aq_site}.png'))
ggsave(glue('figs/{my_aq_site}-crop.png'))


# buffer 20 m
aop_path <- glue('/Volumes/hondula/DATA/AOP/site-polygons/{my_aq_site}_{survey_yr}.shp')
site_shore_buff <- site_shore %>% st_zm() %>% st_buffer(20)
site_shore_buff %>% st_write(aop_path)

