library(shiny)
library(httr)
library(jsonlite)
library(ggplot2)
library(dplyr)

# Define the UI
ui <- fluidPage(
  titlePanel("Pokémon Data Explorer"),
  tabsetPanel(
    tabPanel("About", includeMarkdown("about.md")),
    tabPanel("Data Download",
             sidebarLayout(
               sidebarPanel(
                 textInput("pokemon_name", "Pokémon Name:", value = "pikachu"),
                 actionButton("query", "Query API")
               ),
               mainPanel(
                 tableOutput("api_data")
               )
             )
    ),
    tabPanel("Data Exploration",
             sidebarLayout(
               sidebarPanel(
                 selectInput("x_var", "X-axis Variable:", choices = NULL),
                 selectInput("y_var", "Y-axis Variable:", choices = NULL),
                 selectInput("plot_type", "Plot Type:", choices = c("Scatter Plot", "Bar Plot")),
                 actionButton("plot", "Generate Plot")
               ),
               mainPanel(
                 plotOutput("data_plot")
               )
             )
    )
  )
)

# Define the server logic
server <- function(input, output, session) {
  observeEvent(input$query, {
    # Construct the API endpoint URL using the input Pokémon name
    endpoint <- paste0("https://pokeapi.co/api/v2/pokemon/", tolower(input$pokemon_name))
    
    # Make the GET request to the API
    response <- GET(endpoint)
    
    # Check for errors in the API request
    if (status_code(response) != 200) {
      showModal(modalDialog(
        title = "API Error",
        paste("Failed to retrieve data from the API. Status code:", status_code(response)),
        easyClose = TRUE,
        footer = NULL
      ))
      return(NULL)
    }
    
    # Parse the JSON response into a list
    data <- fromJSON(content(response, "text"), flatten = TRUE)
    
    # Convert the relevant parts of the list to a data frame
    df <- data.frame(
      name = data$name,
      base_experience = data$base_experience,
      height = data$height,
      weight = data$weight,
      stringsAsFactors = FALSE
    )
    
    # Add stats to the data frame
    stats <- data.frame(
      stat_name = sapply(data$stats, function(x) x$stat$name),
      base_stat = sapply(data$stats, function(x) x$base_stat),
      effort = sapply(data$stats, function(x) x$effort),
      stringsAsFactors = FALSE
    )
    
    # Combine the main data frame and stats data frame
    df <- cbind(df, stats)
    
    # Display the data frame in the table output
    output$api_data <- renderTable({ df })
    
    # Update the select inputs for plotting based on the column names of the data frame
    updateSelectInput(session, "x_var", choices = names(df))
    updateSelectInput(session, "y_var", choices = names(df))
  })
  
  observeEvent(input$plot, {
    req(input$x_var, input$y_var, input$plot_type)
    plot <- ggplot(df, aes_string(x = input$x_var, y = input$y_var))
    if (input$plot_type == "Scatter Plot") {
      plot <- plot + geom_point()
    } else if (input$plot_type == "Bar Plot") {
      plot <- plot + geom_bar(stat = "identity")
    }
    output$data_plot <- renderPlot({ plot })
  })
}

# Run the application
shinyApp(ui, server)
