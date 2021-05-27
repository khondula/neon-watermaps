# other water data sources
library(raster)
library(stars)

##  JRC Globacl Surface Water
jrc_base_url <- "https://storage.googleapis.com/global-surface-water/downloads2020/occurrence"
# barc_jrc <- "occurrence_90W_30Nv1_3_2020.tif"
my_jrc <- "occurrence_90W_40Nv1_3_2020.tif"

glue('{jrc_base_url}/{my_jrc}') %>%
  download.file(destfile = glue('data/JRC/{my_jrc}'))

my_jrc_path <- glue('data/JRC/{my_jrc}')
my_jrc <- stars::read_stars(my_jrc_path, RAT = 'VALUE')

my_fbox_prj <- st_transform(my_fbox, st_crs(my_jrc))
my_jrc_crop <- st_crop(my_jrc, my_fbox_prj)
my_jrc_stars <- st_as_stars(my_jrc_crop)
my_jrc_raster <- as(my_jrc_stars, 'Raster')

plot(my_jrc_raster)
jrc_rat <- levels(my_jrc_raster)[[1]]

plot(my_jrc_stars)

ggplot() +
  geom_stars(data = my_jrc_stars) +
  scale_fill_manual(values = attr(my_jrc_stars[[1]], 'colors'))
