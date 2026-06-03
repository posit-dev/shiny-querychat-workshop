# 4. Add a datatable to the app

# Use Cmd + / to toggle comments (Ctrl + / on Windows)

# # Querychat components
# library(querychat)
# qc <- QueryChat$new(georgia_mortality, greeting = "How can I help you explore cancer mortality in Georgia?")
# qc$sidebar()
# qc_vals <- qc$server()
# qc_vals$df()

library(shiny)
library(bslib)
library(tidyverse)
library(leaflet)
library(DT)

source("create_mortality_map.R")
georgia_mortality <- read.csv("data/georgia_mortality.csv")
georgia_population <- read.csv("data/georgia_population.csv")

ui <- page_sidebar(
  sidebar = sidebar(selectInput("site", "Cancer type:", sort(unique(georgia_mortality$Site)))),
  leafletOutput("map", height = "500px"),
  DTOutput("table")
)

server <- function(input, output) {

  output$map <- renderLeaflet({
    create_mortality_map(filter(georgia_mortality, Site == input$site), georgia_population)
  })

  output$table <- renderDT({
    datatable(filter(georgia_mortality, Site == input$site))
  })

}

shinyApp(ui, server)
