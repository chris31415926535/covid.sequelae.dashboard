## code to prepare `phu_shp` dataset goes here
library(tidyverse)
library(httr)
#library(geojson)
library(rmapshaper)
library(sf)

# PHU boundary file from MOH
# https://geohub.lio.gov.on.ca/datasets/ministry-of-health-public-health-unit-boundary/explore?location=49.342384%2C-84.749434%2C5.81
phu_url <- "https://opendata.arcgis.com/api/v3/datasets/c2fa5249b0c2404ea8132c051d934224_0/downloads/data?format=geojson&spatialRefId=4326"

# download data
phu_resp <- httr::GET(phu_url)

# parse it
phu_shp_complex <- phu_resp %>%
  httr::content(type = "text/json", encoding = "UTF-8") %>%
  sf::read_sf()

# simplify it but keep regions adjacent/touching
phu_shp <- phu_shp_complex %>%
  rmapshaper::ms_simplify(keep = 0.005)

## Looks okay if you plot it
#ggplot(phu_shp) + geom_sf()

## Shrinks it to ~ 1.4% the original size
#as.numeric(object.size(phu_shp))/as.numeric(object.size(phu_shp_complex) )


usethis::use_data(phu_shp, overwrite = TRUE)
