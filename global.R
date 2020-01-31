library(shiny)
library(NipponMap)
library(shinydashboard)
library(data.table)
library(plotly)
library(DT)

db <- fread('./summary.csv', header = T)
db[is.na(db)] <- 0

lang <- fread('./lang.csv')
langCode <- 'ja'

news <- fread('./mhlw_houdou.csv')

UPDATE_TIME <- Sys.time()
