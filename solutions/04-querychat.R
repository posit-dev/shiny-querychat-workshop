# Note: Move this file into your main directory before previewing. 
# The filepaths used below will not work if you keep it in the 
# solutions/ directory.

library(shiny)
library(bslib)
library(tidyverse)
library(leaflet)
library(sf)
library(tigris)
library(DT)
library(querychat) # Load querychat

peachtree_lottery <- readRDS("peachtree_lottery.RDS")
source("lottery_helpers.R")

# Setup querychat
qc <- QueryChat$new(peachtree_lottery, greeting = "Hi! How can I help you explore Peachtree Lottery sales?")

ui <- page_sidebar(
  title = "2025 Per Capita Peachtree Lottery Sales",
  sidebar = qc$sidebar(), # Add querychat sidebar elements
  layout_columns(
    col_widths = c(6, 6),
    card(
      full_screen = TRUE,
      card_header("Map"),
      leafletOutput("map", height = "100%")
    ),
    layout_columns(
      col_widths = c(12, 12),
      card(
        card_header("Income"),
        plotOutput("income_plot", height="150px")
      ),
      card(
        card_header("Data"),
        full_screen = TRUE,
        DTOutput("data_table")
      )
    )
  )
)

server <- function(input, output, session) {

  # Add querychat server-side elements
  qc_vals <- qc$server()

  filtered_data <- reactive({
    qc_vals$df()
  })

  output$map <- renderLeaflet({
    create_lottery_map(filtered_data(), per_capita = TRUE)
  })

  output$income_plot <- renderPlot({
    plot_per_capita_spend(filtered_data(), income)
  })

  output$data_table <- DT::renderDT({
    datatable(filtered_data())
  })
}

shinyApp(ui, server)
