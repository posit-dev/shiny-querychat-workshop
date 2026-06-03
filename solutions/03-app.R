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

# Load data and helpers
peachtree_lottery <- readRDS("peachtree_lottery.RDS")
source("lottery_helpers.R")
age_levels <- levels(peachtree_lottery$age)

ui <- page_sidebar(
  title = "2025 Per Capita Peachtree Lottery Sales",
  sidebar = sidebar(
    selectInput(
      "age",
      "Filter by Age",
      choices  = age_levels,
      selected = age_levels[1]
    )
  ),
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

  filtered_data <- reactive({
    req(input$age)
    peachtree_lottery |>
      filter(age %in% input$age)
  })

  output$map <- renderLeaflet({
    create_lottery_map(filtered_data(), per_capita = TRUE)
  })

  output$income_plot <- renderPlot({
    plot_per_capita_spend(filtered_data(), income)
  })

  output$data_table <- renderDT({
    datatable(filtered_data())
  })
}

shinyApp(ui, server)