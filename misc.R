# Our goal is to build an app around these pieces of code

library(tidyverse)
library(leaflet)
library(sf)
library(tigris)
library(DT)

georgia_cases <- readRDS("georgia_cases.RDS")

source("helpers.R")

create_incidence_map(georgia_cases)
plot_incidence_by_demographic(georgia_cases, RE)
datatable(georgia_cases)