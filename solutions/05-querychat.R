# 6. Enable querychat

library(shiny)
library(bslib)
library(tidyverse)
library(leaflet)
library(DT)
library(querychat)

source("create_mortality_map.R")
georgia_mortality <- read.csv("data/georgia_mortality.csv")
georgia_population <- read.csv("data/georgia_population.csv")

qc <- QueryChat$new(georgia_mortality, greeting = "How can I help you explore cancer mortality in Georgia?")

ui <- page_sidebar(
  sidebar = qc$sidebar(),
  leafletOutput("map", height = "500px"),
  DTOutput("table")
)

server <- function(input, output) {
  qc_vals <- qc$server()

  output$map <- renderLeaflet({
    create_mortality_map(qc_vals$df(), georgia_population)
  })

  output$table <- renderDT({
    datatable(qc_vals$df())
  })

}

shinyApp(ui, server)
