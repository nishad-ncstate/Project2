# Star Wars Shiny App

This Shiny app queries the Star Wars API (SWAPI) to retrieve and explore data from the Star Wars universe. Users can customize their queries, view and download data, and explore the data through various visualizations.

## Required Packages
- shiny
- httr
- jsonlite
- dplyr
- ggplot2
- tidyr
- DT


## Install Packages and Run the App
```R
install.packages(c("shiny", "httr", "jsonlite", "dplyr", "ggplot2", "tidyr", "DT"))

shiny::runGitHub("nishad-ncstate/project2")