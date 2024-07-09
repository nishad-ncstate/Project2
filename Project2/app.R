library(shiny)
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Bandsintown API Data Explorer"),
  tabsetPanel(
    tabPanel("About", includeMarkdown("about.md")),
    tabPanel("Data Download", 
             sidebarLayout(
               sidebarPanel(
                 textInput("artist_name", "Artist Name:", value = "Coldplay"),
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

server <- function(input, output, session) {
  observeEvent(input$query, {
    # Construct the API endpoint URL using the input artist name
    endpoint <- paste0("https://rest.bandsintown.com/artists/", input$artist_name, "/events?app_id=test")
    
    # Make the GET request to the API
    response <- GET(endpoint)
    
    # Parse the JSON response into a list
    data <- fromJSON(content(response, "text"), flatten = TRUE)
    
    # Convert the list to a data frame
    df <- as.data.frame(data)
    
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

shinyApp(ui, server)
