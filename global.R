library(shiny)
library(NipponMap)
library(shinydashboard)
library(data.table)
library(plotly)

db <- fread('./summary.csv', header = T)
db[is.na(db)] <- 0

lang <- fread('./lang.csv')
langCode <- 'ja'

UPDATE_TIME <- Sys.time()
