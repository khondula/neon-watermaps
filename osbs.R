library(sf)
library(glue)
library(dplyr)
library(ggplot2)

my_aq_site <- 'BARC'
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

## SUGG

sugg_site_shps <- glue('data/spatial/SUGG') %>% 
  fs::dir_ls(glob = '*.shp')

sugg_shore2017 <- st_read(sugg_site_shps[2])
sugg_shore2018 <- st_read(sugg_site_shps[4])
sugg_hab2017 <- st_read(sugg_site_shps[5])
sugg_hab2018 <- st_read(sugg_site_shps[6])

sugg_hab2017 %>% 
  ggplot() +
  geom_sf(aes(fill = Habitat)) +
  theme_void() +
  ggtitle(glue('SUGG 2017'))

sugg_hab2018 %>% 
  ggplot() +
  geom_sf(aes(fill = Habitat)) +
  theme_void() +
  ggtitle(glue('SUGG 2018'))

## BARC

barc_site_shps <- glue('data/spatial/{my_aq_site}') %>% 
  fs::dir_ls(glob = '*.shp')

barc_contour2016 <- st_read(barc_site_shps[1]) 
barc_shore2016 <- st_read(barc_site_shps[2]) 
barc_contour2018 <- st_read(barc_site_shps[3]) 
barc_shore2018 <- st_read(barc_site_shps[4]) 
barc_hab2016 <- st_read(barc_site_shps[5]) 
barc_hab2018 <- st_read(barc_site_shps[6])


barc_shore2016 %>% 
  ggplot() +
  geom_sf() +
  theme_void() +
  ggtitle(glue('{my_aq_site} 2016'))

barc_shore2018 %>% 
  ggplot() +
  geom_sf() +
  theme_void() +
  ggtitle(glue('{my_aq_site} 2018'))

contour2016 %>% 
  ggplot() +
  geom_sf(aes(color = CONTOUR)) +
  theme_void() +
  ggtitle(glue('{my_aq_site} 2016'))

contour2018 %>% 
  ggplot() +
  geom_sf(aes(color = Contour)) +
  theme_void() +
  ggtitle(glue('{my_aq_site} 2018'))

hab2016 %>% 
  ggplot() +
  geom_sf(aes(fill = Habitat)) +
  theme_void() +
  ggtitle(glue('{my_aq_site} 2016'))

hab2018 %>% 
  ggplot() +
  geom_sf(aes(fill = Habitat)) +
  theme_void() +
  ggtitle(glue('{my_aq_site} 2018'))

my_fbox %>%
  ggplot() +
  geom_sf() +
  # geom_sf(data = my_aq_sf) +
  geom_stars(data = my_jrc_stars) +
  scale_fill_manual(values = attr(my_jrc_stars[[1]], 'colors')) +
  geom_sf(data = barc_shore2018, fill = NA, col = "green") +
  geom_sf(data = sugg_shore2018, fill = NA, col = "green") +
  theme_void() +
  theme(legend.position = "none") +
  ggtitle(glue('BARC and SUGG 2018 {my_aq_sf$domanID}'))

ggsave('figs/OSBS.png')
ggsave('figs/OSBS-2.png')

aop_path <- glue('/Volumes/hondula/DATA/AOP/BARC_2018.shp')
aop_path <- glue('/Volumes/hondula/DATA/AOP/SUGG_2018.shp')

# buffer 20 m
barc_shore2018_buff <- barc_shore2018 %>% st_buffer(20)
sugg_shore2018_buff <- sugg_shore2018 %>% st_buffer(20)
sugg_shore2018_buff %>% st_write(aop_path)
# barc_shore2018 %>% 
#   ggplot() +
#   geom_sf() +
#   geom_sf(data = barc_shore2018_buff, fill = NA) +
#   theme_void() +
#   ggtitle(glue('{my_aq_site} 2018'))

barc_shore2018_buff %>% st_write(aop_path)
