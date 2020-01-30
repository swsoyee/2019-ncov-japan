library(shiny)
library(NipponMap)
library(shinydashboard)
library(data.table)
library(plotly)

db <- fread("./summary.csv", header = T)
db[is.na(db)] <- 0
