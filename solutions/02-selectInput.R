# 2. Add selectInput code to the sidebar

# Use Cmd + / to toggle comments (Ctrl + / on Windows)

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

# # Querychat components
# library(querychat)
# qc <- QueryChat$new(georgia_mortality, greeting = "How can I help you explore cancer mortality in Georgia?")
# qc$sidebar()
# qc_vals <- qc$server()
# qc_vals$df()

library(shiny)
library(bslib)
library(tidyverse)

georgia_mortality <- read.csv("data/georgia_mortality.csv")
georgia_population <- read.csv("data/georgia_population.csv")

ui <- page_sidebar(
  sidebar = sidebar(selectInput("site", "Cancer type:", sort(unique(georgia_mortality$Site))))
)

server <- function(input, output) {
}

shinyApp(ui, server)