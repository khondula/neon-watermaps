library(httr)
library(jsonlite)
library(glue)
library(tidyverse)


##### download myglob files from mysite 
##### into local dir my_dir
download_myfiles <- function(mysite, my_dir, data_id){
  base_url <- 'http://data.neonscience.org/api/v0/'
  req_avail <- GET(glue('{base_url}/products/{data_id}'))
  avail_resp <- content(req_avail, as = 'text') %>% 
    fromJSON(simplifyDataFrame = TRUE, flatten = TRUE)
  
  # List of products by site code with month
  data_urls_list <- avail_resp$data$siteCodes$availableDataUrls
  
  # make table of urls with site and months
  avail_df <- data_urls_list %>%
    unlist() %>% as.data.frame() %>%
    dplyr::rename(url = 1) %>%
    mutate(siteid = str_sub(url, nchar(url)-11, nchar(url)-8)) %>%
    mutate(month = str_sub(url, nchar(url)-6, nchar(url))) %>%
    dplyr::select(siteid, month, url) %>%
    dplyr::filter(siteid %in% mysite)
  
  my_site_urls <- avail_df %>% pull(url)
  
  # filter to just the basic files of interest
  
  get_pattern_files <- function(my_url, myglob){
    data_files_req <- GET(my_url)
    data_files <- content(data_files_req, as = "text") %>%
      fromJSON(simplifyDataFrame = TRUE, flatten = TRUE)
    data_files_df <- data_files$data$files %>% 
      filter(str_detect(name, glue('{myglob}.*(basic)')))
    return_list <- NULL
    if(nrow(data_files_df) > 0){
      return_list <- list(files = data_files_df$name, urls = data_files_df$url)}
    return(return_list)
  }
  
  my_files_list <- my_site_urls %>% purrr::map(~get_pattern_files(.x, 'resultsFile'))
  
  download_month <- function(my_files){
    fs::dir_create(glue('{my_dir}/{mysite}'))
    my_files_local <- glue('{my_dir}/{mysite}/{my_files$files}')
    purrr::walk2(.x = my_files$urls, .y = my_files_local, ~download.file(.x, .y))
  }
  
  my_files_list %>% purrr::walk(~download_month(.x))
  
}