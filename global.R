library(shiny)
library(NipponMap)
library(shinydashboard)
library(data.table)
library(plotly)
library(DT)
library(ggplot2)
library(shinycssloaders)
library(shinydashboardPlus)

# ====
# ファイルのパス設定
# ====
DATA_PATH <- 'Data/'
COMPONENT_PATH <- 'Components/'
PAGE_PATH <- 'Pages/'

# ====
# データの読み込み
# ====
db <- fread(paste0(DATA_PATH, 'summary.csv'), header = T)
db[is.na(db)] <- 0

lang <- fread(paste0(DATA_PATH, 'lang.csv'))
langCode <- 'ja'
# TODO 言語切り替え機能
# languageSet <- c('ja', 'cn')
# names(languageSet) <- c(lang[[langCode]][25], lang[[langCode]][26])

news <- fread(paste0(DATA_PATH, 'mhlw_houdou.csv'))

province <-
  fread(paste0(DATA_PATH, 'provinceCode.csv'), na.strings = NULL)
# Scale設定
province[, Scale := c(3, rep(1, 46))]
# 区域名変更
province[, Prefecture := gsub("県", "", province$Prefecture)]
province[, Prefecture := gsub("府", "", province$Prefecture)]
province[, Prefecture := gsub("東京都", "東京", province$Prefecture)]
# データ追加
province[, Data := rowSums(db[, 2:ncol(db)])]

# world <- fread(paste0(DATA_PATH, '2019_nCoV_data.csv'))

# china <- fread('https://raw.githubusercontent.com/BlankerL/DXY-2019-nCoV-Data/master/DXYArea.csv')

# ====
# 定数設定
# ====
UPDATE_TIME <- '2020-2-4'
GLOABLE_MAIN_COLOR <- '#605ca8'
GLOABLE_MAIN_COLOR_RGBVALUE <-
  paste(as.vector(col2rgb(GLOABLE_MAIN_COLOR)), collapse = ",")
GLOABLE_MAIN_COLOR_RGBA <-
  paste0('rgba(', GLOABLE_MAIN_COLOR_RGBVALUE, ',0.5)')
options(spinner.color = GLOABLE_MAIN_COLOR)
