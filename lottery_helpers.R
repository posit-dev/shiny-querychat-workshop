# Georgia Lottery Sales Choropleth Map Function
# This function creates an interactive map showing how much 
# # on average each wage earning adult in a county spends on 
# lottery tickets annually

library(tidyverse)
library(leaflet)
library(sf)
library(tigris)

options(tigris_use_cache = TRUE)


create_lottery_map <- function( data, 
                                per_capita = FALSE,
                                state_fips = "13",
                                palette = "YlOrRd") {
  
  county_totals <- 
    if (per_capita) {
      data |>
        group_by(county) |>
        summarise(dollars = sum(sales, na.rm = TRUE) / sum(n, na.rm = TRUE), .groups = "drop")
    } else {
      data |>
        group_by(county) |>
        summarise(dollars = sum(sales, na.rm = TRUE), .groups = "drop")
    } 
  
  counties_geo <- counties(state = state_fips, cb = TRUE, year = 2021, progress_bar = FALSE) |>
    st_transform(4326) |>  # Transform to WGS84 (EPSG:4326) to avoid datum warning
    mutate(county = NAME)
  
  map_data <- counties_geo |>
    left_join(county_totals, by = "county") |>
    mutate(dollars = replace_na(dollars, 0))
  
  pal <- colorNumeric(
    palette = palette,
    domain = map_data$Rate,
    na.color = "#808080"
  )

  leaflet(map_data) |>
    addTiles() |>
    addPolygons(
      fillColor = ~pal(dollars),
      fillOpacity = 0.7,
      color = "#FFFFFF",
      weight = 1,
      smoothFactor = 0.5,
      highlightOptions = highlightOptions(
        weight = 2,
        color = "#666",
        fillOpacity = 0.9,
        bringToFront = TRUE
      ),
      label = ~paste0(county, ": $", format(round(dollars, 2), nsmall = 2, big.mark = ",")),
      labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),
        textsize = "15px",
        direction = "auto"
      )
    ) |>
    addLegend(
      pal = pal,
      values = ~dollars,
      opacity = 0.7,
      title = "Dollars",
      position = "bottomright"
    )
}

# Helper function to create bar charts of per-capita lottery 
# spending by demographic variable
plot_per_capita_spend <- function(var, color = "#8DA0CB") {
  label <- rlang::as_label(rlang::enquo(var))

  peachtree_lottery |>
    group_by({{ var }}) |>
    summarise(spend = sum(sales) / sum(n)) |>
    ggplot(aes(x = {{ var }}, y = spend)) +
    geom_col(fill = color) +
    labs(
      title = tools::toTitleCase(label),
      x = "",
      y = ""
    ) +
    scale_y_continuous(limits = c(0, 550)) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))
}