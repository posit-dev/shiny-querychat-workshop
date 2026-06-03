# Our goal is to build an app around these three pieces of code

# Loads datasets and tools
library(tidyverse)
georgia_mortality <- read.csv("data/georgia_mortality.csv")
georgia_population <- read.csv("data/georgia_population.csv")

# A map of the data
library(leaflet)
source("create_mortality_map.R") # defines create_mortality_map() function
create_mortality_map(filter(georgia_mortality, Site == "Thyroid"), georgia_population)

# A filtered table of the data
library(DT)
datatable(filter(georgia_mortality, Site == "Thyroid"))