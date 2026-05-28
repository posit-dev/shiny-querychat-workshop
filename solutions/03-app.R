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

# Extract unique filter values
counties  <- sort(unique(peachtree_lottery$county))
ages      <- sort(unique(peachtree_lottery$age))
sexes     <- sort(unique(peachtree_lottery$sex))
races     <- sort(unique(peachtree_lottery$race))
incomes   <- sort(unique(peachtree_lottery$income))

ui <- page_sidebar(
  title = "2025 Per Capita Peachtree Lottery Sales",
  sidebar = sidebar(
    selectInput("county", "County", choices = c("All", counties), selected = "All"),
    selectInput("age", "Age", choices = c("All", ages), selected = "All"),
    selectInput("sex", "Sex", choices = c("All", sexes), selected = "All"),
    selectInput("race", "Race", choices = c("All", races), selected = "All"),
    selectInput("income", "Income", choices = c("All", incomes), selected = "All")
  ),
  layout_columns(
    col_widths = c(6, 6),
    card(
      card_header("Lottery Sales Map"),
      leafletOutput("map", height = "500px")
    ),
    layout_columns(
      col_widths = 12,
      card(
        card_header("Income"), 
        plotOutput("income_plot", height = "200px")
      ),
      card(
        card_header("Data"),
        DTOutput("data_table")
      )
    )
  )
)

server <- function(input, output, session) {

  filtered_data <- reactive({
    d <- peachtree_lottery
    if (input$county != "All") d <- d |> filter(county == input$county)
    if (input$age != "All")    d <- d |> filter(age == input$age)
    if (input$sex != "All")    d <- d |> filter(sex == input$sex)
    if (input$race != "All")   d <- d |> filter(race == input$race)
    if (input$income != "All") d <- d |> filter(income == input$income)
    d
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
