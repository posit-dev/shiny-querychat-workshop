# 3. Add a leaflet plot to the app

# Use Cmd + / to toggle comments (Ctrl + / on Windows)

# # A filtered table of the data
# library(DT)
# DTOutput("_____")
# output$table <- _______DT({
#   datatable(filter(georgia_mortality, Site == "Thyroid"))
# })

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

source("create_mortality_map.R")
georgia_mortality <- read.csv("data/georgia_mortality.csv")
georgia_population <- read.csv("data/georgia_population.csv")

ui <- page_sidebar(
  sidebar = sidebar(selectInput("site", "Cancer type:", sort(unique(georgia_mortality$Site)))),
  leafletOutput("map", height = "500px")
)

server <- function(input, output) {

  output$map <- renderLeaflet({
    create_mortality_map(filter(georgia_mortality, Site == input$site), georgia_population)
  })

}

shinyApp(ui, server)
