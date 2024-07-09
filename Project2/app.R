library(shiny)
library(DT)
library(ggplot2)
library(dplyr)
library(tidyr)
source("api_functions.R")

ui <- navbarPage(
  "Star Wars Data Explorer",
  
  tabPanel("About",
           fluidPage(
             h1("Star Wars Data Explorer"),
             p("This app uses the Star Wars API (SWAPI) to allow users to explore data from the Star Wars universe."),
             p("Use the Data Download tab to query the API and download data. Use the Data Exploration tab to create visualizations and summaries of the data."),
             img(src = "https://starwarsblog.starwars.com/wp-content/uploads/2018/02/SW_Helmet_DarthVader_Press-1-1536x864-748923093287.jpeg", height = "400px")
           )),
  
  tabPanel("Data Download",
           fluidPage(
             sidebarLayout(
               sidebarPanel(
                 selectInput("data_type", "Choose Data Type", choices = c("People", "Starships", "Films")),
                 actionButton("query_data", "Query Data")
               ),
               mainPanel(
                 DTOutput("data_table"),
                 downloadButton("download_data", "Download Data")
               )
             )
           )),
  
  tabPanel("Data Exploration",
           fluidPage(
             sidebarLayout(
               sidebarPanel(
                 selectInput("x_var", "Choose X Variable", choices = NULL),
                 selectInput("y_var", "Choose Y Variable", choices = NULL),
                 actionButton("plot_data", "Plot Data"),
                 hr(),
                 selectInput("summary_var", "Choose Variable to Summarize", choices = NULL),
                 actionButton("summarize_data", "Summarize Data")
               ),
               mainPanel(
                 plotOutput("plot"),
                 tableOutput("summary_table")
               )
             )
           ))
)

server <- function(input, output, session) {
  
  data <- reactiveVal()
  
  observeEvent(input$query_data, {
    req(input$data_type)
    if (input$data_type == "People") {
      data(get_people())
    } else if (input$data_type == "Starships") {
      data(get_starships())
    } else if (input$data_type == "Films") {
      data(get_films())
    }
    updateSelectInput(session, "x_var", choices = names(data()))
    updateSelectInput(session, "y_var", choices = names(data()))
    updateSelectInput(session, "summary_var", choices = names(data()))
  })
  
  output$data_table <- renderDT({
    datatable(data())
  })
  
  output$download_data <- downloadHandler(
    filename = function() {
      paste(input$data_type, "data.csv", sep = "_")
    },
    content = function(file) {
      write.csv(data(), file, row.names = FALSE)
    }
  )
  
  observeEvent(input$plot_data, {
    req(input$x_var, input$y_var)
    output$plot <- renderPlot({
      ggplot(data(), aes_string(x = input$x_var, y = input$y_var)) +
        geom_point() +
        labs(title = paste("Plot of", input$y_var, "vs", input$x_var),
             x = input$x_var, y = input$y_var)
    })
  })
  
  observeEvent(input$summarize_data, {
    req(input$summary_var)
    output$summary_table <- renderTable({
      data() %>% 
        group_by(!!sym(input$summary_var)) %>% 
        summarise(Count = n(), .groups = 'drop')
    })
  })
}

shinyApp(ui, server)
