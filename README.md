# Star Wars Shiny App

This Shiny app queries the Star Wars API (SWAPI) to retrieve and explore data from the Star Wars universe. Users can customize their queries, view and download data, and explore the data through various visualizations.

## Required Packages

-   shiny
-   httr
-   jsonlite
-   dplyr
-   ggplot2
-   tidyr
-   DT

## Install Packages

```{r}
install.packages(c("shiny", "DT", "ggplot2", "dplyr", "tidyr", "httr", "jsonlite"))
```

## Run the App

```{r}
shiny::runGitHub("nishad-ncstate/project2")
```
