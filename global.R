library(shiny)
library(NipponMap)
library(shinydashboard)
library(data.table)
library(plotly)

db <- fread("./summary.csv", header = T)
db[is.na(db)] <- 0

UPDATE_TIME <- Sys.time()
DATA_SOURCE <- 'ソース：厚生労働省'
LABLE_RECOVERTED <- '完治数'
LABEL_DEATH <- '死亡数'
LABEL_SUSPICIOUS <- '観察中'
LABEL_CONFIRMED <- '確認数'
