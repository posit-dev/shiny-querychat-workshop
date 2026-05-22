# Our goal is to build an app around these pieces of code

library(tidyverse)
library(leaflet)
library(sf)
library(tigris)
library(DT)

peachtree_lottery <- readRDS("peachtree_lottery.RDS")

source("lottery_helpers.R")

create_lottery_map(peachtree_lottery, per_capita = TRUE)

plot_per_capita_spend(age, color = "#66C2A5")
plot_per_capita_spend(sex, color = "#8DA0CB")
plot_per_capita_spend(income, color = "#E78AC3")

datatable(peachtree_lottery)