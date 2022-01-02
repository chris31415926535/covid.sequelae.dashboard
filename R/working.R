# testing everything
library(tidyverse)


health_units <- httr::GET("https://api.covid19tracker.ca/province/ON/regions") %>%
  httr::content("text", encoding = "UTF-8") %>%
  jsonlite::fromJSON() %>%
  dplyr::as_tibble()

health_units

# get report, lots of parameters
# https://api.covid19tracker.ca/docs/1.0/reports
url <- paste0("https://api.covid19tracker.ca/reports/regions/", health_units$hr_uid[[1]])

result <- httr::GET(url) %>%
  httr::content("text", encoding = "UTF-8") %>%
  jsonlite::fromJSON() %>%
  dplyr::as_tibble()

result


# # public health unit boundary files
# # https://www150.statcan.gc.ca/n1/pub/82-402-x/2018001/hrbf-flrs-eng.htm
# phu_shp_sc <- sf::read_sf("data/shp/HR_035b18a_e.shp")

# PHU boundary fiels from MOH
# https://geohub.lio.gov.on.ca/datasets/ministry-of-health-public-health-unit-boundary/explore?location=49.342384%2C-84.749434%2C5.81
phu_shp <- sf::read_sf("data/shp/Ministry_of_Health_Public_Health_Unit_Boundary.geojson")

phu_shp_simple <- rmapshaper::ms_simplify(phu_shp, keep = 0.005 )
object.size(phu_shp_simple)
ggplot(phu_shp_simple) + geom_sf()
leaflet(phu_shp_simple) %>% addPolygons()

# perth and huron public healths merged Jan 1, 2020
# https://www.hpph.ca/en/news/new-huron-perth-public-health-launches-with-inaugural-board-meeting.aspx#




ggplot(phu_shp) + geom_sf()
phu_shp


phus <- sf::st_set_geometry(phu_shp, NULL)# %>%
  #mutate(HR_UID = as.numeric(HR_UID))

remove_text <- "Public|Health|Unit|City of|The|District of|Regional|Region|Department|Area|Services|County|City|of |[:punct:]"
# make them joinable
test_api <- health_units %>%
  mutate(join_name = stringr::str_remove_all(engname, remove_text) %>% stringr::str_squish()) %>%
  arrange(join_name) %>%
  select(join_name, everything())
#test_api

test_shp <- phus %>%
  mutate(join_name = stringr::str_remove_all(NAME_ENG, remove_text) %>% stringr::str_squish())%>%
  arrange(join_name) %>%
  select(join_name, everything())

test <- left_join(test_api, test_shp, by = "join_name")

phus
result_phus <- result$hr_uid %>% unique()
phus %>%
  filter(!HR_UID %in% health_units$hr_uid)


update_data <- function(){
  # debugging flag
  verbose <- FALSE

  update <- FALSE

  # if we have never updated before, we need to update now
  if (!file.exists("data/last_update.csv")) update <- TRUE

  # if we have updated before, we need to update if it's been more than 4 hours
  if (file.exists("data/last_update.csv")){
    last_update <- read_csv("data/last_update.csv") %>%
      pull(1)

    if (difftime(Sys.time(), last_update, units = "hour") > 4) update <- TRUE
  }


# UPDATE THE DATA


}

