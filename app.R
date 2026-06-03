# Use Cmd + / to toggle comments (Ctrl + / on Windows)

# Loads datasets and tools
library(tidyverse)
georgia_mortality <- read.csv("data/georgia_mortality.csv")
georgia_population <- read.csv("data/georgia_population.csv")

# # A map of the data
# library(leaflet)
# source("create_mortality_map.R") # defines create_mortality_map() function
# leafletOutput("map", height = "500px")
# output$map <- renderLeaflet({
#   create_mortality_map(filter(georgia_mortality, Site == "Thyroid"), georgia_population)
# })

# # A filtered table of the data
# library(DT)
# DTOutput("_____")
# output$table <- _______DT({
#   datatable(filter(georgia_mortality, Site == "Thyroid"))
# })

# # A drop down menu that displays each type of cancer in georgia_mortality
# selectInput("site", "Cancer type:", sort(unique(georgia_mortality$Site)))

# # Querychat components
# library(querychat)
# qc <- QueryChat$new(georgia_mortality, greeting = "How can I help you explore cancer mortality in Georgia?")
# qc$sidebar()
# qc_vals <- qc$server()
# qc_vals$df()

# A shiny app
library(shiny)
library(bslib)

ui <- page_sidebar(
  sidebar = sidebar(),
)

server <- function(input, output) {
}

shinyApp(ui, server)