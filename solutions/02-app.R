# Note: Move this file into your main directory before previewing. 
# The filepaths used below will not work if you keep it in the 
# solutions/ directory.

library(shiny)
library(bslib)
library(leaflet)
library(DT)

source("helpers.R")

georgia_cases <- readRDS("georgia_cases.RDS")
cancer_sites   <- sort(unique(georgia_cases$Site))

ui <- page_sidebar(
  title = "Georgia Cancer Incidence",

  sidebar = sidebar(
    selectInput(
      "site",
      "Cancer Site",
      choices  = cancer_sites,
      selected = cancer_sites[[1]]
    )
  ),

  layout_columns(
    col_widths = c(6, 6),

    # Column 1: incidence map
    card(
      full_screen = TRUE,
      card_header("Incidence Map"),
      leafletOutput("map", height = 500)
    ),

    # Column 2: blank card + data table
    layout_column_wrap(
      width = 1,

      card(
        full_screen = TRUE,
        card_header("Incidence by Race/Ethnicity"),
        plotOutput("re_chart")
      ),

      card(
        full_screen = TRUE,
        card_header("Data"),
        DTOutput("table")
      )
    )
  )
)

server <- function(input, output) {

  filtered <- reactive({
    georgia_cases[georgia_cases$Site == input$site, ]
  })

  output$map <- renderLeaflet({
    create_incidence_map(filtered())
  })

  output$re_chart <- renderPlot({
    plot_incidence_by_demographic(filtered(), RE)
  })

  output$table <- renderDT({
    datatable(
      filtered(),
      options = list(pageLength = 10, bPaginate = TRUE, dom = "ltipr")
    )
  })
}

shinyApp(ui, server)
