library(shiny)
library(NipponMap)
library(shinydashboard)
library(data.table)
library(plotly)
library(DT)
library(ggplot2)

db <- fread('Data/summary.csv', header = T)
db[is.na(db)] <- 0

lang <- fread('Data/lang.csv')
langCode <- 'ja'

news <- fread('Data/mhlw_houdou.csv')

province <- fread('Data/provinceCode.csv', na.strings = NULL)
# Scale設定
province[, Scale := c(3, rep(1, 46))]
# 区域名変更
province[, Prefecture := gsub("県", "", province$Prefecture)]
province[, Prefecture := gsub("府", "", province$Prefecture)]
province[, Prefecture := gsub("東京都", "東京", province$Prefecture)]
# データ追加
province[, Data := rowSums(db[, 2:ncol(db)])]

UPDATE_TIME <- Sys.time()
