library(shiny)
# library(NipponMap)
library(shinydashboard)
library(data.table)
library(DT)
library(ggplot2)
library(shinycssloaders)
library(shinydashboardPlus)
library(shinyWidgets)
library(leaflet)
library(rjson)
library(htmltools)
library(leaflet.minicharts)
library(echarts4r)
library(echarts4r.maps)

# ====
# ファイルのパス設定
# ====
DATA_PATH <- 'Data/'
COMPONENT_PATH <- 'Components/'
PAGE_PATH <- 'Pages/'

# ====
# データの読み込み
# ====
# db <- fread(paste0(DATA_PATH, 'summary.csv'), header = T)
# db[is.na(db)] <- 0

byDate <- fread(paste0(DATA_PATH, 'byDate.csv'), header = T)
byDate[is.na(byDate)] <- 0
byDate$date <- lapply(byDate[, 1], function(x){as.Date(as.character(x), format = '%Y%m%d')})

# 退院データ
recovered <- fread(paste0(DATA_PATH, 'recovered.csv'))
recovered[is.na(recovered)] <- 0
recovered[, date := as.Date(as.character(recovered$date), format = "%Y%m%d")]

# 死亡データ
death <- fread(paste0(DATA_PATH, 'death.csv'))
death[is.na(death)] <- 0

# 行動歴データ
activity <- fromJSON(file = paste0(DATA_PATH, 'caseMap.json'), unexpected.escape = 'error')
# 経度緯度データ
position <- fread(paste0(DATA_PATH, 'position.csv'))

# アプリ情報
# statics <- fromJSON(file = 'https://stg.covid-2019.live/ncov-static/stats.json', 
#                     unexpected.escape = 'error')

# 文言データ
lang <- fread(paste0(DATA_PATH, 'lang.csv'))
langCode <- 'ja'
# TODO 言語切り替え機能
# languageSet <- c('ja', 'cn')
# names(languageSet) <- c(lang[[langCode]][25], lang[[langCode]][26])

# ====総数基礎集計====
# 確認
TOTAL_DOMESITC <- sum(byDate[, c(2:48)]) # 日本国内事例のPCR陽性数（クルーズ船関連者除く）
TOTAL_OFFICER <- sum(byDate$検疫職員) # クルーズ船関連の職員のPCR陽性数
TOTAL_FLIGHT <- sum(byDate$チャーター便) # チャーター便のPCR陽性数
TOTAL_WITHIN <- TOTAL_DOMESITC + TOTAL_OFFICER + TOTAL_FLIGHT # 日本国内事例のPCR陽性数
TOTAL_SHIP <- sum(byDate$クルーズ船) # クルーズ船のPCR陽性数
TOTAL_JAPAN <- TOTAL_WITHIN + TOTAL_SHIP # 日本領土内のPCR陽性数
CONFIRMED_PIE_DATA <- data.table(category = c(lang[[langCode]][4], # 国内事例
                                              lang[[langCode]][35], # クルーズ船
                                              lang[[langCode]][36] # チャーター便
                                              ),
                                 value = c(TOTAL_DOMESITC + TOTAL_OFFICER, TOTAL_SHIP, TOTAL_FLIGHT))
# 退院
CURED_DOMESTIC <- sum(recovered[, 2])
CURED_FLIGHT <- sum(recovered[, 3])
CURED_WITHIN <- CURED_DOMESTIC + CURED_FLIGHT
CURED_PIE_DATA <- data.table(category = c(lang[[langCode]][4], # 国内事例
                                          lang[[langCode]][36] # チャーター便
                                          ),
                             value = c(CURED_DOMESTIC, CURED_FLIGHT))
# 死亡
DEATH_DOMESITC <- sum(death[, c(2:48)]) # 日本国内事例の死亡数（クルーズ船関連者除く）
DEATH_OFFICER <- sum(death[]$検疫職員) # クルーズ船関連の職員の死亡数
DEATH_FLIGHT <- sum(death$チャーター便) # チャーター便の死亡数
DEATH_WITHIN <- DEATH_DOMESITC + DEATH_OFFICER + DEATH_FLIGHT # 日本国内事例の死亡数
DEATH_SHIP <- sum(death$クルーズ船) # クルーズ船の死亡数
DEATH_JAPAN <- DEATH_WITHIN + DEATH_SHIP # 日本領土内の死亡数
DEATH_PIE_DATA <- data.table(category = c(lang[[langCode]][4], # 国内事例
                                          lang[[langCode]][35], # クルーズ船
                                          lang[[langCode]][36] # チャーター便
                                          ),
                             value = c(DEATH_DOMESITC + DEATH_OFFICER, DEATH_SHIP, DEATH_FLIGHT))

# ====本日のデータ====
# 確認
byDateToday <- byDate[nrow(byDate), ] # 本日の差分データセット
todayConfirmed <- unlist(as.list(byDateToday[, 2:ncol(byDateToday)]))
HAS_TODAY_CONFIRMED <- todayConfirmed[todayConfirmed > 0] # 本日変化がある都道府県分類

deathToday <- death[nrow(byDate), ] # 本日の差分データセット
todayDeath <- unlist(as.list(deathToday[, 2:ncol(deathToday)]))
HAS_TODAY_DEATH <- todayDeath[todayDeath > 0] # 本日変化がある都道府県分類

# ====前日比べの基礎集計(差分)====
# 確認
TOTAL_DOMESITC_DIFF <- sum(byDateToday[, c(2:48)]) # 日本国内事例のPCR陽性数（クルーズ船関連者除く）
TOTAL_OFFICER_DIFF <- sum(byDateToday[]$検疫職員) # クルーズ船関連の職員のPCR陽性数
TOTAL_FLIGHT_DIFF <- sum(byDateToday$チャーター便) # チャーター便のPCR陽性数
TOTAL_WITHIN_DIFF <- TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF + TOTAL_FLIGHT_DIFF # 日本国内事例のPCR陽性数
TOTAL_SHIP_DIFF <- sum(byDateToday$クルーズ船) # クルーズ船のPCR陽性数
TOTAL_JAPAN_DIFF <- TOTAL_WITHIN_DIFF + TOTAL_SHIP_DIFF # 日本領土内のPCR陽性数
# 退院
CURED_DOMESTIC_DIFF <- sum(recovered[nrow(recovered), 2])
CURED_FLIGHT_DIFF <- sum(recovered[nrow(recovered), 3])
CURED_WITHIN_DIFF <- CURED_DOMESTIC_DIFF + CURED_FLIGHT_DIFF
# 死亡
DEATH_DOMESITC_DIFF <- sum(deathToday[, c(2:48)]) # 日本国内事例のPCR陽性数（クルーズ船関連者除く）
DEATH_OFFICER_DIFF <- sum(deathToday[]$検疫職員) # クルーズ船関連の職員のPCR陽性数
DEATH_FLIGHT_DIFF <- sum(deathToday$チャーター便) # チャーター便のPCR陽性数
DEATH_WITHIN_DIFF <- DEATH_DOMESITC_DIFF + DEATH_OFFICER_DIFF + DEATH_FLIGHT_DIFF # 日本国内事例のPCR陽性数
DEATH_SHIP_DIFF <- sum(deathToday$クルーズ船) # クルーズ船のPCR陽性数
DEATH_JAPAN_DIFF <- DEATH_WITHIN_DIFF +DEATH_SHIP_DIFF # 日本領土内のPCR陽性数


# 地域選択に表示する項目名
regionName <- colSums(byDate[, 2:ncol(byDate)])
regionNamePref <- regionName[1:47]
regionNamePref <- sort(regionNamePref[regionNamePref > 0], decreasing = T)
regionNamePrefName <- paste0(names(regionNamePref), ' (', regionNamePref, ')')
regionNameOther <- regionName[48:length(regionName)]
regionNameOtherName <- paste0(names(regionNameOther), ' (', regionNameOther, ')')
regionName <- c('国内', names(regionNameOther), names(regionNamePref))
defaultSelectedRegionName <- regionName[1:3]

names(regionName) <- c(paste0('都道府県合計', ' (', TOTAL_DOMESITC, ')'), 
                       regionNameOtherName, 
                       regionNamePrefName)
regionName <- as.list(regionName)


news <- fread(paste0(DATA_PATH, 'mhlw_houdou.csv'))

# province <-
#   fread(paste0(DATA_PATH, 'provinceCode.csv'), na.strings = NULL)
# # Scale設定
# province[, Scale := c(3, rep(1, 46), rep(0.5, 3))]
# # 区域名変更
# province[, Prefecture := gsub("県", "", province$Prefecture)]
# province[, Prefecture := gsub("府", "", province$Prefecture)]
# province[, Prefecture := gsub("東京都", "東京", province$Prefecture)]
# # データ追加
# province[, Data := rowSums(db[, 2:ncol(db)])]
provinceCode <- fread(paste0(DATA_PATH, 'prefectures.csv'))

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

# world <- fread(paste0(DATA_PATH, '2019_nCoV_data.csv'))

# china <- fread('https://raw.githubusercontent.com/BlankerL/DXY-2019-nCoV-Data/master/DXYArea.csv')

# ====
# 定数設定
# ====
UPDATE_DATETIME <- file.info(paste0(DATA_PATH, 'byDate.csv'))$mtime
RECOVERED_FILE_UPDATE_DATETIME <- file.info(paste0(DATA_PATH, 'recovered.csv'))$mtime
DEATH_FILE_UPDATE_DATETIME <- file.info(paste0(DATA_PATH, 'death.csv'))$mtime
UPDATE_DATE <- as.Date(UPDATE_DATETIME)
DEATH_UPDATE_DATE <- as.Date(DEATH_FILE_UPDATE_DATETIME)
GLOABLE_MAIN_COLOR <- '#605ca8'
GLOABLE_MAIN_COLOR_RGBVALUE <-
  paste(as.vector(col2rgb(GLOABLE_MAIN_COLOR)), collapse = ",")
GLOABLE_MAIN_COLOR_RGBA <-
  paste0('rgba(', GLOABLE_MAIN_COLOR_RGBVALUE, ',0.5)')
options(spinner.color = GLOABLE_MAIN_COLOR)

# TODO Vectorのネーミングなぜかうまくいかないのでとりあえずここに置く
showOption <- c('showShip', 'showFlight')
names(showOption) <- c(lang[[langCode]][35], lang[[langCode]][36])

twitterUrl <- paste0('https://twitter.com/intent/tweet?text=新型コロナウイルス感染速報：国内の感染確認',
                     TOTAL_JAPAN,
                     '人（クルーズ船含む）、',
                     UPDATE_DATE,
                     'の現時点で新たに',
                     TOTAL_JAPAN_DIFF,
                     '人が確認されました。&hashtags=',
                     '新型コロナウイルス,新型コロナウイルス速報',
                     '&url=https://covid-2019.live/')

lightRed <- '#F56954'
middleRed <- '#DD4B38'
darkRed <- '#B03C2D'
lightYellow <- '#F8BF76'
middleYellow <- '#F39C11'
darkYellow <- '#DB8B0A'
lightGreen <- '#00A65A'
middleGreen <- '#01A65A'
darkGreen <- '#088448'
lightNavy <- '#5A6E82'
middelNavy <- '#001F3F'
darkNavy <- '#001934'
lightGrey <- '#F5F5F5'

# ====メゾット====
getChangeIcon <- function(number) {
  if (number > 0) {
    return('fa fa-caret-up')
  } else {
    return('fa fa-lock')
  }
}
