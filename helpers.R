library(tidyverse)
library(leaflet)
library(sf)
library(tigris)

options(tigris_use_cache = TRUE)


#' Create an interactive cancer incidence choropleth map
#'
#' Builds a leaflet choropleth map showing diagnosed cancer cases aggregated
#' by county. Optionally displays the incidence rate per 100,000 population
#' instead of total cases.
#'
#' @param data A data frame containing at least the columns `County`, `Cases`,
#'   and (when `rate = TRUE`) `n`, the population of each subgroup.
#' @param rate Logical. If `TRUE`, display diagnosed cases per 100,000
#'   population per county. If `FALSE` (default), display total cases.
#' @param state_fips Character. The two-digit FIPS code for the state whose
#'   county boundaries are fetched via [tigris::counties()]. Defaults to
#'   `"13"` (Georgia).
#' @param palette Character. A ColorBrewer palette name passed to
#'   [leaflet::colorNumeric()]. Defaults to `"YlOrRd"`.
#'
#' @return A `leaflet` map widget.
create_incidence_map <- function(data,
                                 rate = TRUE,
                                 state_fips = "13",
                                 palette = "YlOrRd") {

  county_totals <- 
    data |>
        group_by(County) |>
        summarise(value = sum(Cases, na.rm = TRUE), .groups = "drop")
  
  if (rate) {
    county_populations <-
      data |>
        filter(Site == data$Site[[1]]) |>
        group_by(County) |>
        summarise(pop = sum(n, na.rm = TRUE), .groups = "drop")

    county_totals <-
      county_totals |>
        left_join(county_populations, by = "County") |>
        mutate(value = if_else(pop > 0, value / pop * 1e5, NA_real_)) |>
        select(-pop)
  }

  counties_geo <- counties(state = state_fips, cb = TRUE, year = 2021, progress_bar = FALSE) |>
    st_transform(4326) |>
    mutate(County = NAME)

  map_data <- counties_geo |>
    left_join(county_totals, by = "County") |>
    mutate(value = replace_na(value, 0))

  pal <- colorNumeric(
    palette = palette,
    domain = map_data$value,
    na.color = "#808080"
  )

  label_text <- if (rate) {
    ~paste0(County, ": ", round(value, 1), " per 100,000")
  } else {
    ~paste0(County, ": ", format(round(value), big.mark = ","), " diagnosed cases")
  }

  legend_title <- if (rate) "Incidence per 100k" else "Diagnosed Cases"

  leaflet(map_data) |>
    addTiles() |>
    addPolygons(
      fillColor = ~pal(value),
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
      label = label_text,
      labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),
        textsize = "15px",
        direction = "auto"
      )
    ) |>
    addLegend(
      pal = pal,
      values = ~value,
      opacity = 0.7,
      title = legend_title,
      position = "bottomright"
    )
}

#' Plot cancer incidence rates by a demographic variable
#'
#' Creates a bar chart showing cancer incidence rates (diagnosed cases per
#' 100,000 population) broken down by a grouping variable. Supports tidy
#' evaluation, so the grouping column can be passed unquoted.
#'
#' @param data A data frame containing at least `Cases`, `n` (population of
#'   each subgroup), and the column referenced by `var`.
#' @param var \<[`data-masking`][rlang::args_data_masking]\> Unquoted name of
#'   the column to group by (e.g., `RE`, `Age`, `Sex`).
#' @param color Character. Fill color for the bars. Defaults to `"steelblue"`.
#'
#' @return A `ggplot` object.
plot_incidence_by_demographic <- function(data, var, color = "steelblue") {
  var <- enquo(var)

  data |>
    group_by(!!var) |>
    summarise(
      rate = sum(Cases, na.rm = TRUE) / sum(n, na.rm = TRUE) * 1e5,
      .groups = "drop"
    ) |>
    ggplot(aes(x = !!var, y = rate)) +
    geom_col(fill = color) +
    labs(
      title = "Cancer Incidence Rate by Demographic Group",
      x = quo_name(var),
      y = "Diagnosed Cases per 100,000"
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
}
