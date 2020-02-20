library(shiny)
library(NipponMap)
library(shinydashboard)
library(data.table)
library(plotly)
library(DT)
library(ggplot2)
library(shinycssloaders)
library(shinydashboardPlus)
library(shinyWidgets)

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

byDate <- fread(paste0(DATA_PATH, 'byDate.csv'), header = T)
byDate[is.na(byDate)] <- 0

# ====総数基礎集計====
# 確認
TOTAL_DOMESITC <- sum(byDate[, c(2:48)]) # 日本国内事例のPCR陽性数（クルーズ船関連者除く）
TOTAL_OFFICER <- sum(byDate$検疫職員) # クルーズ船関連の職員のPCR陽性数
TOTAL_FLIGHT <- sum(byDate$チャーター便) # チャーター便のPCR陽性数
TOTAL_WITHIN <- TOTAL_DOMESITC + TOTAL_OFFICER + TOTAL_FLIGHT # 日本国内事例のPCR陽性数

TOTAL_SHIP <- sum(byDate$クルーズ船) # クルーズ船のPCR陽性数

TOTAL_JAPAN <- TOTAL_WITHIN + TOTAL_SHIP # 日本領土内のPCR陽性数

# 退院
CURED_DOMESTIC <- sum(recovered[, 2])
CURED_FLIGHT <- sum(recovered[, 3])
CURED_WITHIN <- CURED_DOMESTIC + CURED_FLIGHT

# ====前日比べの基礎集計(差分)====
byDateYesterday <- byDate[nrow(byDate), ] # 差分データセット
TOTAL_DOMESITC_DIFF <- sum(byDateYesterday[, c(2:48)]) # 日本国内事例のPCR陽性数（クルーズ船関連者除く）
TOTAL_OFFICER_DIFF <- sum(byDateYesterday[]$検疫職員) # クルーズ船関連の職員のPCR陽性数
TOTAL_FLIGHT_DIFF <- sum(byDateYesterday$チャーター便) # チャーター便のPCR陽性数
TOTAL_WITHIN_DIFF <- TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF + TOTAL_FLIGHT_DIFF # 日本国内事例のPCR陽性数

TOTAL_SHIP_DIFF <- sum(byDateYesterday$クルーズ船) # クルーズ船のPCR陽性数

TOTAL_JAPAN_DIFF <- TOTAL_WITHIN_DIFF + TOTAL_SHIP_DIFF # 日本領土内のPCR陽性数

# 退院
CURED_DOMESTIC_DIFF <- sum(recovered[nrow(recovered), 2])
CURED_FLIGHT_DIFF <- sum(recovered[nrow(recovered), 3])
CURED_WITHIN_DIFF <- CURED_DOMESTIC_DIFF + CURED_FLIGHT_DIFF


lang <- fread(paste0(DATA_PATH, 'lang.csv'))
langCode <- 'ja'
# TODO 言語切り替え機能
# languageSet <- c('ja', 'cn')
# names(languageSet) <- c(lang[[langCode]][25], lang[[langCode]][26])

news <- fread(paste0(DATA_PATH, 'mhlw_houdou.csv'))

province <-
  fread(paste0(DATA_PATH, 'provinceCode.csv'), na.strings = NULL)
# Scale設定
province[, Scale := c(3, rep(1, 46), rep(0.5, 3))]
# 区域名変更
province[, Prefecture := gsub("県", "", province$Prefecture)]
province[, Prefecture := gsub("府", "", province$Prefecture)]
province[, Prefecture := gsub("東京都", "東京", province$Prefecture)]
# データ追加
province[, Data := rowSums(db[, 2:ncol(db)])]

# 詳細データ
detail <- fread(paste0(DATA_PATH, 'detail.csv'),
                colClasses = list(
                  numeric = c(1, 2),
                  factor = c(5, 6, 9:11)
                  )
                )
detailColName <- colnames(detail)
detail[, comfirmedDay := as.Date(as.character(detail$comfirmedDay), format = "%Y%m%d")]
detail[, link := as.integer(detail$link)]
detailMerged <- merge(detail, news, by.x = 'link', by.y = 'id')
detailMerged[, link := paste0("<a href='", detailMerged$link.y, "'>", detailMerged$title, "</a>")]
detail <- detailMerged[, detailColName, with = F][order(id)]

# 詳細データのサマリー
detailSummary <- detail[, .(count = .N), by = .(gender, age)]

# 退院データ
recovered <- fread(paste0(DATA_PATH, 'recovered.csv'))
recovered[is.na(recovered)] <- 0
recovered[, date := as.Date(as.character(recovered$date), format = "%Y%m%d")]

# world <- fread(paste0(DATA_PATH, '2019_nCoV_data.csv'))

# china <- fread('https://raw.githubusercontent.com/BlankerL/DXY-2019-nCoV-Data/master/DXYArea.csv')

# ====
# 定数設定
# ====
UPDATE_DATETIME <- file.info(paste0(DATA_PATH, 'summary.csv'))$mtime
UPDATE_DATE <- as.Date(UPDATE_DATETIME)
GLOABLE_MAIN_COLOR <- '#605ca8'
GLOABLE_MAIN_COLOR_RGBVALUE <-
  paste(as.vector(col2rgb(GLOABLE_MAIN_COLOR)), collapse = ",")
GLOABLE_MAIN_COLOR_RGBA <-
  paste0('rgba(', GLOABLE_MAIN_COLOR_RGBVALUE, ',0.5)')
options(spinner.color = GLOABLE_MAIN_COLOR)

# TODO Vectorのネーミングなぜかうまくいかないのでとりあえずここに置く
showOption <- c('showShip', 'showFlight')
names(showOption) <- c(lang[[langCode]][35], lang[[langCode]][36])
