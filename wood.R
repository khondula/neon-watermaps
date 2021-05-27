library(sf)
library(glue)
library(dplyr)
library(ggplot2)

my_aq_site <- 'PRLA'
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

## PRLA

prla_site_shps <- glue('data/spatial/PRLA') %>% 
  fs::dir_ls(glob = '*.shp')

prla_contour2016 <- st_read(prla_site_shps[1]) 
prla_shore2016 <- st_read(prla_site_shps[3])
prla_hab2016 <- st_read(prla_site_shps[4])

prla_shore2016 %>%
  ggplot() +
  geom_sf()

prla_hab2016 %>% 
  ggplot() +
  geom_sf(aes(fill = Habitat)) +
  theme_void() +
  ggtitle(glue('{my_aq_site} 2017'))

prla_contour2016 %>% 
  ggplot() +
  geom_sf(aes(color = CONTOUR)) +
  theme_void() +
  ggtitle(glue('{my_aq_site} 2016'))

## PRPO
my_aq_site <- 'PRPO'
prpo_site_shps <- glue('data/spatial/{my_aq_site}') %>% 
  fs::dir_ls(glob = '*.shp')
prpo_site_shps

prpo_contour2016 <- st_read(prpo_site_shps[1]) 
prpo_shore2016 <- st_read(prpo_site_shps[3])
prpo_hab2016 <- st_read(prpo_site_shps[4])

prpo_shore2016 %>%
  ggplot() +
  geom_sf()

prpo_hab2016 %>% 
  ggplot() +
  geom_sf(aes(fill = Habitat)) +
  theme_void() +
  ggtitle(glue('{my_aq_site} 2016'))

prpo_contour2016 %>% 
  ggplot() +
  geom_sf(aes(color = CONTOUR)) +
  theme_void() +
  ggtitle(glue('{my_aq_site} 2016'))

# both sites

my_fbox %>%
  ggplot() +
  geom_sf() +
  geom_stars(data = my_jrc_stars) +
  scale_fill_manual(values = attr(my_jrc_stars[[1]], 'colors')) +
  geom_sf(data = prpo_shore2016, fill = NA, col = "green") +
  geom_sf(data = prla_shore2016, fill = NA, col = "green") +
  theme_void() +
  theme(legend.position = "none") +
  ggtitle(glue('PRLA and PRPO {my_aq_sf$domanID}'))

ggsave('figs/WOOD-2.png')


# buffer 20 m
aop_path <- glue('/Volumes/hondula/DATA/AOP/site-polygons/PRPO_2016.shp')
prpo_shore2016_buff <- prpo_shore2016 %>% st_zm() %>% st_buffer(20)
prpo_shore2016_buff %>% st_write(aop_path)

prla_shore2016_buff <- prla_shore2016 %>% st_zm() %>% st_buffer(20)
aop_path <- glue('/Volumes/hondula/DATA/AOP/site-polygons/PRLA_2016.shp')
prla_shore2016_buff %>% st_write(aop_path)
