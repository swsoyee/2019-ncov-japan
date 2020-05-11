library(shiny)
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
library(sparkline)
library(shinyBS)
library(shiny.i18n)

source(file = "01_Settings/Path.R", local = T, encoding = "UTF-8")
source(file = "02_Utils/Functions.R", local = T, encoding = "UTF-8")
source(file = "02_Utils/mapNameMap.R", local = T, encoding = "UTF-8")
source(file = "02_Utils/ConfirmedPyramidData.R", local = T, encoding = "UTF-8")
source(file = paste0(COMPONENT_PATH, "Notification.R"), local = T, encoding = "UTF-8")
source(file = paste0(PAGE_PATH, "Main/Utils/ValueBox.R"), local = T, encoding = "UTF-8")
source(file = paste0(COMPONENT_PATH, "/Main/NewsList.ui.R"), local = T, encoding = "UTF-8")
source(file = paste0(COMPONENT_PATH, "/Main/clusterTabButton.ui.R"), local = T, encoding = "UTF-8")
source(file = paste0(COMPONENT_PATH, "/Main/SymptomsProgression.ui.R"), local = T, encoding = "UTF-8")
source(file = paste0(COMPONENT_PATH, "/Main/ComfirmedPyramid.ui.R"), local = T, encoding = "UTF-8")
source(file = paste0(COMPONENT_PATH, "/Main/Tendency.ui.R"), local = T, encoding = "UTF-8")

# ====
# データの読み込み
# ====
i18n <- suppressWarnings(Translator$new(translation_json_path = "www/lang/translation.json"))
i18n$set_translation_language("ja")

languageSetting <- ifelse(length(i18n$translation_language) == 0, "ja", i18n$translation_language)

# マップのソースの読み込み
japanMap <- jsonlite::read_json(paste0(DATA_PATH, "Echarts/japan.json"))
# TODO ここで変換せず、ローカルで変換すべき
japanMap$features <- japanMap$features %>% 
  purrr::map(function(x){
    x$properties$name <- convertRegionName(x$properties$nam_ja, languageSetting)
    return(x)
  })

byDate <- fread(paste0(DATA_PATH, "byDate.csv"), header = T)
byDate[is.na(byDate)] <- 0
byDate$date <- lapply(byDate[, 1], function(x) {
  as.Date(as.character(x), format = "%Y%m%d")
})
# マップ用データ読み込み
mapData <- fread(paste0(DATA_PATH, "result.map.csv"), header = T)

# 死亡データ
death <- fread(paste0(DATA_PATH, "death.csv"))
death[is.na(death)] <- 0

# 行動歴データ
activity <- rjson::fromJSON(file = paste0(DATA_PATH, "caseMap.json"), unexpected.escape = "error")
# 経度緯度データ
position <- fread(paste0(DATA_PATH, "position.csv"))

# 厚労省の都道府県まとめデータ
detailByRegion <- fread(paste0(DATA_PATH, "detailByRegion.csv"))
detailByRegion[, 都道府県名 := gsub("県|府", "", 都道府県名)]
detailByRegion[, 都道府県名 := gsub("東京都", "東京", 都道府県名)]
detailByRegion[, 日付 := as.Date(as.character(日付), "%Y%m%d")]

# アプリ情報
# statics <- fromJSON(file = 'https://stg.covid-2019.live/ncov-static/stats.json',
#                     unexpected.escape = 'error')

# 国内の日報
domesticDailyReport <- fread(paste0(DATA_PATH, "domesticDailyReport.csv"))
domesticDailyReport$date <- as.Date(as.character(domesticDailyReport$date), "%Y%m%d")
setnafill(domesticDailyReport, type = "locf")
# チャーター便の日報
flightDailyReport <- fread(paste0(DATA_PATH, "flightDailyReport.csv"))
flightDailyReport$date <- as.Date(as.character(flightDailyReport$date), "%Y%m%d")
setnafill(flightDailyReport, type = "locf")
# 空港検疫の日報
airportDailyReport <- fread(paste0(DATA_PATH, "airportDailyReport.csv"))
airportDailyReport$date <- as.Date(as.character(airportDailyReport$date), "%Y%m%d")
setnafill(airportDailyReport, type = "locf")
# クルーズ船の日報
shipDailyReport <- fread(paste0(DATA_PATH, "shipDailyReport.csv"))
shipDailyReport$date <- as.Date(as.character(shipDailyReport$date), "%Y%m%d")
setnafill(shipDailyReport, type = "locf")
# 2020-04-22時点から、退院者数と死亡者数が速報値と確定値に分かれているので、それの対応
confirmingData <- fread(paste0(DATA_PATH, "confirmingData.csv"))
confirmingData$date <- as.Date(as.character(confirmingData$date), "%Y%m%d")
# 日報まとめ
dailyReport <- fread(paste0(DATA_PATH, "resultDailyReport.csv"))
dailyReport$date <- as.Date(dailyReport$date, "%Y-%m-%d")
setnafill(dailyReport, type = "locf")
# コールセンター
callCenterDailyReport <- fread(paste0(DATA_PATH, "MHLW/callCenter.csv"))
callCenterDailyReport$date <- as.Date(as.character(callCenterDailyReport$date), "%Y%m%d")

pcrByRegion <- fread(file = paste0(DATA_PATH, "MHLW/pcrByRegion.csv"))
pcrByRegion[, 日付 := as.Date(as.character(日付), "%Y%m%d")]

# 文言データ
lang <- fread(paste0(DATA_PATH, "lang.csv"))
langCode <- "ja"
# TODO 言語切り替え機能
# languageSet <- c('ja', 'cn')
# names(languageSet) <- c(lang[[langCode]][25], lang[[langCode]][26])

mhlwSummaryPath <- paste0(DATA_PATH, "/MHLW/summary.csv")
mhlwSummary <- fread(file = mhlwSummaryPath)
mhlwSummary$日付 <- as.Date(as.character(mhlwSummary$日付), "%Y%m%d")
mhlwSummary <- mhlwSummary[order(都道府県名, 日付)]
setnafill(mhlwSummary, type = "locf", cols = c("陽性者", "退院者", "検査人数"))

# ====総数基礎集計====
# PCR
PCR_WITHIN <- getFinalAndDiff(domesticDailyReport$pcr)
PCR_SHIP <- getFinalAndDiff(shipDailyReport$pcr)
PCR_FLIGHT <- getFinalAndDiff(flightDailyReport$pcr)
PCR_AIRPORT <- getFinalAndDiff(airportDailyReport$pcr)


# 確認
TOTAL_DOMESITC <- sum(byDate[, c(2:48)]) # 日本国内事例のPCR陽性数（クルーズ船関連者除く）
TOTAL_OFFICER <- sum(byDate$検疫職員) # クルーズ船関連の職員のPCR陽性数
TOTAL_FLIGHT <- sum(byDate$チャーター便) # チャーター便のPCR陽性数
TOTAL_WITHIN <- TOTAL_DOMESITC + TOTAL_OFFICER + TOTAL_FLIGHT # 日本国内事例のPCR陽性数
TOTAL_SHIP <- sum(byDate$クルーズ船) # クルーズ船のPCR陽性数
TOTAL_JAPAN <- TOTAL_WITHIN + TOTAL_SHIP + sum(byDate$伊客船) # 日本領土内のPCR陽性数
CONFIRMED_PIE_DATA <- data.table(
  category = c(
    lang[[langCode]][4], # 国内事例
    lang[[langCode]][35], # クルーズ船
    lang[[langCode]][36] # チャーター便
  ),
  value = c(TOTAL_DOMESITC + TOTAL_OFFICER, TOTAL_SHIP, TOTAL_FLIGHT)
)
# 退院

DISCHARGE_WITHIN <- getFinalAndDiff(domesticDailyReport$discharge)
DISCHARGE_FLIGHT <- getFinalAndDiff(flightDailyReport$discharge)
DISCHARGE_SHIP <- getFinalAndDiff(shipDailyReport$discharge)
DISCHARGE_AIRPORT <- getFinalAndDiff(airportDailyReport$discharge)

CURED_PIE_DATA <- data.table(
  category = c(
    lang[[langCode]][4], # 国内事例
    lang[[langCode]][36], # チャーター便 （無症状）
    lang[[langCode]][35], # クルーズ船
    "空港検疫"
  ),
  value = c(
    DISCHARGE_WITHIN$final,
    DISCHARGE_FLIGHT$final,
    DISCHARGE_SHIP$final,
    DISCHARGE_AIRPORT$final
  ),
  diff = c(
    DISCHARGE_WITHIN$diff,
    DISCHARGE_FLIGHT$diff,
    DISCHARGE_SHIP$diff,
    DISCHARGE_AIRPORT$diff
  )
)

DISCHARGE_TOTAL <- sum(CURED_PIE_DATA$value)
DISCHARGE_TOTAL_NO_SHIP <- DISCHARGE_TOTAL - DISCHARGE_SHIP$final
DISCHARGE_DIFF <- sum(CURED_PIE_DATA$diff)
DISCHARGE_DIFF_NO_SHIP <- DISCHARGE_DIFF - DISCHARGE_SHIP$diff

# 死亡
DEATH_DOMESITC <- sum(death[, c(2:48)]) # 日本国内事例の死亡数（クルーズ船関連者除く）
DEATH_OFFICER <- sum(death[]$検疫職員) # クルーズ船関連の職員の死亡数
DEATH_FLIGHT <- sum(death$チャーター便) # チャーター便の死亡数
DEATH_WITHIN <- DEATH_DOMESITC + DEATH_OFFICER + DEATH_FLIGHT # 日本国内事例の死亡数
DEATH_SHIP <- sum(death$クルーズ船) # クルーズ船の死亡数
DEATH_JAPAN <- DEATH_WITHIN + DEATH_SHIP # 日本領土内の死亡数
DEATH_PIE_DATA <- data.table(
  category = c(
    lang[[langCode]][4], # 国内事例
    lang[[langCode]][35], # クルーズ船
    lang[[langCode]][36] # チャーター便
  ),
  value = c(DEATH_DOMESITC + DEATH_OFFICER, DEATH_SHIP, DEATH_FLIGHT)
)

# ====本日のデータ====
# 確認
byDateToday <- byDate[nrow(byDate),] # 本日の差分データセット
todayConfirmed <- unlist(as.list(byDateToday[, 2:ncol(byDateToday)]))
HAS_TODAY_CONFIRMED <- todayConfirmed[todayConfirmed > 0] # 本日変化がある都道府県分類

deathToday <- death[nrow(byDate),] # 本日の差分データセット
todayDeath <- unlist(as.list(deathToday[, 2:ncol(deathToday)]))
HAS_TODAY_DEATH <- todayDeath[todayDeath > 0] # 本日変化がある都道府県分類

# ====前日比べの基礎集計(差分)====
# 確認
TOTAL_DOMESITC_DIFF <- sum(byDateToday[, c(2:48)]) # 日本国内事例のPCR陽性数（クルーズ船関連者除く）
TOTAL_OFFICER_DIFF <- sum(byDateToday[]$検疫職員) # クルーズ船関連の職員のPCR陽性数
TOTAL_FLIGHT_DIFF <- sum(byDateToday$チャーター便) # チャーター便のPCR陽性数
TOTAL_WITHIN_DIFF <- TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF + TOTAL_FLIGHT_DIFF # 日本国内事例のPCR陽性数
TOTAL_SHIP_DIFF <- sum(byDateToday$クルーズ船) # クルーズ船のPCR陽性数
TOTAL_JAPAN_DIFF <- TOTAL_WITHIN_DIFF + TOTAL_SHIP_DIFF + sum(byDateToday[, 52]) # 日本領土内のPCR陽性数

# 死亡
DEATH_DOMESITC_DIFF <- sum(deathToday[, c(2:48)]) # 日本国内事例のPCR陽性数（クルーズ船関連者除く）
DEATH_OFFICER_DIFF <- sum(deathToday[]$検疫職員) # クルーズ船関連の職員のPCR陽性数
DEATH_FLIGHT_DIFF <- sum(deathToday$チャーター便) # チャーター便のPCR陽性数
DEATH_WITHIN_DIFF <- DEATH_DOMESITC_DIFF + DEATH_OFFICER_DIFF + DEATH_FLIGHT_DIFF # 日本国内事例のPCR陽性数
DEATH_SHIP_DIFF <- sum(deathToday$クルーズ船) # クルーズ船のPCR陽性数
DEATH_JAPAN_DIFF <- DEATH_WITHIN_DIFF + DEATH_SHIP_DIFF # 日本領土内のPCR陽性数


# 地域選択に表示する項目名
regionName <- colSums(byDate[, 2:ncol(byDate)])
regionNamePref <- regionName[1:47]
# 感染者確認されていない地域
regionZero <- names(regionNamePref[regionNamePref == 0])
regionNamePref <- sort(regionNamePref[regionNamePref > 0], decreasing = T)
regionNamePrefName <- paste0(sapply(names(regionNamePref), i18n$t), " (", regionNamePref, ")")
regionNameOther <- regionName[48:length(regionName)]
regionNameOtherName <- paste0(convertRegionName(names(regionNameOther), languageSetting), " (", regionNameOther, ")")
regionName <- c("都道府県", names(regionNameOther), names(regionNamePref))
defaultSelectedRegionName <- regionName[1:3]

names(regionName) <- c(
  paste0(i18n$t("都道府県合計"), " (", TOTAL_DOMESITC, ")"),
  regionNameOtherName,
  regionNamePrefName
)
regionName <- as.list(regionName)


news <- fread(paste0(DATA_PATH, "mhlw_houdou.csv"))

provinceCode <- fread(paste0(DATA_PATH, "prefectures.csv"))
provinceSelector <- provinceCode$id
provinceSelector <- as.list(provinceSelector)
names(provinceSelector) <- sapply(provinceCode$`name-ja`, i18n$t)

# 詳細データけんもねずみ
positiveDetail <- fread(paste0(DATA_PATH, "positiveDetail.csv"))

# 市レベルの感染者数
confirmedCityTreemapData <- fread(paste0(DATA_PATH, "Kenmo/confirmedNumberByCity.", languageSetting, ".csv"))

# 詳細データ
detail <- fread(paste0(DATA_PATH, "detail.csv"),
  colClasses = list(
    numeric = c(1, 2),
    factor = c(5, 6, 9:11)
  )
)
detailColName <- colnames(detail)
detail[, comfirmedDay := as.Date(as.character(detail$comfirmedDay), format = "%Y%m%d")]
detail[, link := as.integer(detail$link)]
detailMerged <- merge(detail, news, by.x = "link", by.y = "id")
detailMerged[, link := paste0("<a href='", detailMerged$link.y, "'>", detailMerged$title, "</a>")]
detail <- detailMerged[, detailColName, with = F][order(id)]

# 詳細データのサマリー
detailSummary <- detail[, .(count = .N), by = .(gender, age)]

# 症状の進行テーブルを読み込む
processData <- fread(input = paste0(DATA_PATH, "resultProcessData.csv"))

# ====
# 定数設定
# ====

# Real-time感染数の更新時間
UPDATE_DATETIME <- file.info(paste0(DATA_PATH, "byDate.csv"))$mtime
latestUpdateDuration <- difftime(Sys.time(), UPDATE_DATETIME)
LATEST_UPDATE <- paste0(
  round(latestUpdateDuration[[1]], 0),
  convertUnit2Ja(latestUpdateDuration)
)

RECOVERED_FILE_UPDATE_DATETIME <- file.info(paste0(DATA_PATH, "recovered.csv"))$mtime
DEATH_FILE_UPDATE_DATETIME <- file.info(paste0(DATA_PATH, "death.csv"))$mtime
UPDATE_DATE <- as.Date(UPDATE_DATETIME)
DEATH_UPDATE_DATE <- as.Date(DEATH_FILE_UPDATE_DATETIME)

# TODO Vectorのネーミングなぜかうまくいかないのでとりあえずここに置く
showOption <- c("showShip", "showFlight")
names(showOption) <- c(lang[[langCode]][35], lang[[langCode]][36])

twitterUrl <- paste0(
  "https://twitter.com/intent/tweet?text=新型コロナウイルス感染速報：国内の感染確認",
  TOTAL_JAPAN,
  "人（クルーズ船含む）、",
  byDate$date[nrow(byDate)],
  "の現時点で新たに",
  TOTAL_JAPAN_DIFF,
  "人が確認されました。&hashtags=",
  "新型コロナウイルス,新型コロナウイルス速報",
  "&url=https://covid-2019.live/"
)

lightRed <- "#F56954"
middleRed <- "#DD4B39"
darkRed <- "#B03C2D"
lightYellow <- "#F8BF76"
middleYellow <- "#F39C11"
darkYellow <- "#DB8B0A"
lightGreen <- "#00A65A"
middleGreen <- "#01A65A"
darkGreen <- "#088448"
superDarkGreen <- "#046938"
lightNavy <- "#5A6E82"
middelNavy <- "#001F3F"
darkNavy <- "#001934"
lightGrey <- "#F5F5F5"
lightBlue <- "#7BD6F5"
middleBlue <- "#00C0EF"
darkBlue <- "#00A7D0"

options(spinner.color = middleRed)

GLOBAL_VALUE <- reactiveValues(
  signateDetail = NULL,
  signateDetail.ageGenderData = fread(file = paste0(DATA_PATH, "Generated/genderAgeData.csv")),
  signateLink = NULL,
  signatePlace = fread(file = paste0(DATA_PATH, "resultSignatePlace.csv")),
  Academic = list(
    onset_to_confirmed_map = NULL
  ),
  hokkaidoData = NULL,
  hokkaidoDataUpdateTime = NULL,
  hokkaidoPatients = NULL,
  Aomori = list(
    summary = NULL,
    patient = NULL,
    callCenter = NULL,
    contact = NULL,
    updateTime = NULL
  ),
  Kanagawa = list(
    summary = NULL,
    updateTime = NULL
  ),
  Google = list(
    mobility = NULL,
    table = NULL
  )
)
