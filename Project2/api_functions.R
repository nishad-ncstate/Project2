#### Example `api_functions.R`

library(httr)
library(jsonlite)
library(dplyr)

# Function to query the SWAPI
query_swapi <- function(endpoint, id = NULL, params = list()) {
  base_url <- "https://swapi.dev/api/"
  url <- paste0(base_url, endpoint)
  if (!is.null(id)) {
    url <- paste0(url, "/", id)
  }
  if (length(params) > 0) {
    query <- paste0("?", paste0(names(params), "=", params, collapse = "&"))
    url <- paste0(url, query)
  }
  response <- GET(url)
  content <- content(response, as = "text")
  data <- fromJSON(content, flatten = TRUE)
  return(data)
}

# Example usage
get_people <- function(page = 1) {
  data <- query_swapi("people", params = list(page = page))
  return(data$results)
}

# Get starships
get_starships <- function(page = 1) {
  data <- query_swapi("starships", params = list(page = page))
  return(data$results)
}

# Get films
get_films <- function() {
  data <- query_swapi("films")
  return(data$results)
}