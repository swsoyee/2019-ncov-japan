library(rjson)
library(jsonlite)
library(data.table)
library(sparkline)
# library(gsheet)

source(file = "01_Settings/Path.R", local = T, encoding = "UTF-8")
source(file = "00_System/Generate.ProcessData.R", local = T, encoding = "UTF-8")

# ====けんもデータ====
# positiveDetail <- gsheet2tbl("docs.google.com/spreadsheets/d/1Cy4W9hYhGmABq1GuhLOkM92iYss0qy03Y1GeTv4bCyg/edit#gid=1196047345")
# fwrite(x = positiveDetail, file = paste0(DATA_PATH, "positiveDetail.csv"))
#
# provincePCR <- gsheet2tbl("docs.google.com/spreadsheets/d/1Cy4W9hYhGmABq1GuhLOkM92iYss0qy03Y1GeTv4bCyg/edit#gid=845297461")
# fwrite(x = provincePCR, file = paste0(DATA_PATH, "provincePCR.csv"))

# 市レベル
# provinceAttr <- fread(paste0(DATA_PATH, "Signate/prefMaster.csv"))
#
# provinceAttr[都道府県コード %in% 1:7, regionName := "北海道・東北地方"]
# provinceAttr[都道府県コード %in% 8:14, regionName := "関東地方"]
# provinceAttr[都道府県コード %in% 15:23, regionName := "中部地方"]
# provinceAttr[都道府県コード %in% 24:30, regionName := "近畿地方"]
# provinceAttr[都道府県コード %in% 31:35, regionName := "中国地方"]
# provinceAttr[都道府県コード %in% 36:39, regionName := "四国地方"]
# provinceAttr[都道府県コード %in% 40:47, regionName := "九州地方・沖縄"]
#
# provinceAttr <- provinceAttr[, .(都道府県, regionName)]

# kenmoAreaDataset <- gsheet2tbl("https://docs.google.com/spreadsheets/d/1Cy4W9hYhGmABq1GuhLOkM92iYss0qy03Y1GeTv4bCyg/edit#gid=491635333")
# fwrite(x = kenmoAreaDataset, file = paste0(DATA_PATH, "Kenmo/confirmedNumberByCity.ja.csv"))
# # Translate
# translateSubData <- fread(paste0(DATA_PATH, "Collection/cityMaster.csv"))

translateColumn <- function(data, column, language, language_data) {
  data <- data.table(data)
  data[[column]] <- language_data[match(data[[column]], language_data[["ja"]])][[language]]
  return(data)
}
# kenmoAreaDataset.cn <- translateColumn(data = kenmoAreaDataset, column = "県名", language = "cn", language_data = translateSubData)
# kenmoAreaDataset.cn <- translateColumn(data = kenmoAreaDataset.cn, column = "市名", language = "cn", language_data = translateSubData)
# fwrite(x = kenmoAreaDataset.cn, file = paste0(DATA_PATH, "Kenmo/confirmedNumberByCity.cn.csv"))
# kenmoAreaDataset.en <- translateColumn(data = kenmoAreaDataset, column = "県名", language = "en", language_data = translateSubData)
# kenmoAreaDataset.en <- translateColumn(data = kenmoAreaDataset.en, column = "市名", language = "en", language_data = translateSubData)
# fwrite(x = kenmoAreaDataset.en, file = paste0(DATA_PATH, "Kenmo/confirmedNumberByCity.en.csv"))

# ====SIGNATEデータ====
# signatePlace <- gsheet2tbl('docs.google.com/spreadsheets/d/1CnQOf6eN18Kw5Q6ScE_9tFoyddk4FBwFZqZpt_tMOm4/edit#gid=103322372')
# fwrite(x = signatePlace, file = paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 接触場所マスタ.csv'))

Update.Signate.Detail <- function(update = F) {
  if (update) {
    signateDetail <- gsheet2tbl("https://docs.google.com/spreadsheets/d/10MFfRQTblbOpuvOs_yjIYgntpMGBg592dL8veXoPpp4/edit#gid=960903158")
    signateDetail <- data.table(signateDetail)
    fwrite(x = signateDetail, file = paste0(DATA_PATH, "SIGNATE COVID-2019 Dataset - 罹患者.csv"))

    signateRelation <- gsheet2tbl("https://docs.google.com/spreadsheets/d/1NQ3xrnRi6ta82QtitpJFmIYGvO0wZBmBU5H9EfUGtts/edit#gid=1227116169")
    signateRelation <- data.table(signateRelation)
    fwrite(x = signateRelation, file = paste0(DATA_PATH, "Signate/relation.csv"))

    # 都道府県、公表日、性別、年齢====
    source(file = "02_Utils/ConfirmedPyramidData.R")
    fwrite(x = Signate.ConfirmedPyramidData(signateDetail), file = paste0(DATA_PATH, "Generated/genderAgeData.csv"))
    # 発症から診断までの日数マップ
    source(file = paste0(DATA_PATH, "Academic/onset2ConfirmedMap.R"))
  }
}
# Update.Signate.Detail(update = T)

#
# signateLink <- gsheet2tbl('https://docs.google.com/spreadsheets/d/1CnQOf6eN18Kw5Q6ScE_9tFoyddk4FBwFZqZpt_tMOm4/edit#gid=57719256')
# fwrite(x = signateLink, file = paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 罹患者関係.csv'))

# signatePref <- gsheet2tbl('https://docs.google.com/spreadsheets/d/1NQjppYx0QZQmt6706gCOw9DcIDxgnaEy9QTzfeqeMrQ/edit#gid=1940307536')
# fwrite(x = signatePref, file = paste0(DATA_PATH, 'Signate/', 'prefMaster.csv'))

# signateDetail<- fread(paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 罹患者.csv'), header = T)
# signateLink<- fread(paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 罹患者関係.csv'), header = T)
# signatePlace<- fread(paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 接触場所マスタ.csv'), header = T)

saveFileFromApi <- function(jsonResult, patientsFileName, prefCode, pref, NoCol = "No") {
  data <- list()
  for (i in 1:nrow(jsonResult)) {
    data[[i]] <- read.csv(file(jsonResult[i, ]$download_url, encoding = "shift-jis"))
    print(jsonResult[i, ]$filename)
    if (grepl(patientsFileName, jsonResult[i, ]$filename)) {
      patient <- data.table(data[[i]])
      print("マージデータ...")
      # mergeWithSignate <- merge(patient, signateDetail[都道府県コード == prefCode], by.x = NoCol, by.y = '都道府県別罹患者No')
      fwrite(x = patient, file = paste0(DATA_PATH, "/Pref/", pref, "/", jsonResult[i, ]$filename))
    } else {
      fwrite(x = data[[i]], file = paste0(DATA_PATH, "Pref/", pref, "/", jsonResult[i, ]$filename))
    }
  }
}

# ==== 北海道 ===
apiUrl <- "https://www.harp.lg.jp/opendata/api/package_show?id=752c577e-0cbe-46e0-bebd-eb47b71b38bf"
jsonFile <- jsonlite::fromJSON(apiUrl)
jsonResult <- jsonFile$result$resources
saveFileFromApi(jsonResult, "patients.csv", 1, "Hokkaido")

# ==== 青森 ====
apiUrl <- "https://opendata.pref.aomori.lg.jp/api/package_show?id=5e4612ce-1636-41d9-82a3-c5130a79ffe0"
jsonFile <- jsonlite::fromJSON(apiUrl)
jsonResult <- jsonFile$result$resources
sapply(paste0(DATA_PATH, "Pref/Aomori/", list.files(path = paste0(DATA_PATH, "Pref/Aomori"))), file.remove)
saveFileFromApi(jsonResult, "陽性患者関係.csv", 2, "Aomori", "ＮＯ")


# ====岩手====
dataUrl <- "https://raw.githubusercontent.com/MeditationDuck/covid19/development/data/data.json"
jsonFile <- jsonlite::fromJSON(dataUrl)
pcr <- data.table(
  date = as.Date(jsonFile$inspections_summary$labels, "%m/%d"),
  検査数 = jsonFile$inspections_summary$data$県内
)
contactUrl <- "https://raw.githubusercontent.com/MeditationDuck/covid19/development/data/data.contacts.json"
contactJsonFile <- jsonlite::fromJSON(contactUrl)
contact <- data.table(
  date = as.Date(contactJsonFile$contacts$data$日付),
  相談件数 = contactJsonFile$contacts$data$小計
)
querentUrl <- "https://raw.githubusercontent.com/MeditationDuck/covid19/development/data/data.querents.json"
querentJsonFile <- jsonlite::fromJSON(querentUrl)
querent <- data.table(
  date = as.Date(querentJsonFile$querents$data$日付),
  一般相談 = querentJsonFile$querents$data$小計
)
positive <- data.table(
  date = as.Date(jsonFile$patients_summary$data$日付),
  陽性数 = jsonFile$patients_summary$data$小計
)
iwateData <- merge(x = pcr, y = contact, by = "date", no.dups = T, all = T)
iwateData <- merge(x = iwateData, y = querent, by = "date", no.dups = T, all = T)
iwateData <- merge(x = iwateData, y = positive, by = "date", no.dups = T, all = T)
iwateData[is.na(iwateData)] <- 0
iwateData[, 検査数累計 := cumsum(検査数)]
iwateData[, 相談件数累計 := cumsum(相談件数)]
iwateData[, 一般相談累計 := cumsum(一般相談)]
iwateData[, 陽性数累計 := cumsum(陽性数)]
fwrite(x = iwateData, file = paste0(DATA_PATH, "Pref/", "Iwate", "/", "summary.csv"))

# ====宮城====
dataUrl <- "https://raw.githubusercontent.com/code4shiogama/covid19-miyagi/development/data/data.json"
jsonFile <- jsonlite::fromJSON(dataUrl)
pcr <- data.table(
  date = as.Date(jsonFile$inspection_persons$labels),
  検査数 = jsonFile$inspection_persons$datasets$data[[1]]
)
contact <- data.table(
  date = as.Date(jsonFile$contacts$data$日付),
  相談件数 = jsonFile$contacts$data$小計
)
positive <- data.table(
  date = as.Date(jsonFile$patients_summary$data$日付),
  陽性数 = jsonFile$patients_summary$data$小計
)
miyagiData <- merge(x = pcr, y = contact, by = "date", no.dups = T, all = T)
miyagiData <- merge(x = miyagiData, y = positive, by = "date", no.dups = T, all = T)
miyagiData[is.na(miyagiData)] <- 0
miyagiData[, 検査数累計 := cumsum(検査数)]
miyagiData[, 相談件数累計 := cumsum(相談件数)]
miyagiData[, 陽性数累計 := cumsum(陽性数)]
fwrite(x = miyagiData, file = paste0(DATA_PATH, "Pref/", "Miyagi", "/", "summary.csv"))

# ====茨城====
dataUrl <- "https://raw.githubusercontent.com/a01sa01to/covid19-ibaraki/development/data/data.json"
jsonFile <- jsonlite::fromJSON(dataUrl)

pcr <- data.table(
  date = as.Date(jsonFile$inspection_persons$labels),
  検査数 = jsonFile$inspection_persons$datasets$data[[1]]
)
contact <- data.table(
  date = as.Date(jsonFile$contacts$data$date),
  相談件数 = jsonFile$contacts$data$total
)
positive <- data.table(
  date = as.Date(jsonFile$patients_summary$data$date),
  陽性数 = jsonFile$patients_summary$data$total
)
dt <- merge(x = pcr, y = contact, by = "date", no.dups = T, all = T)
dt <- merge(x = dt, y = positive, by = "date", no.dups = T, all = T)
dt[is.na(dt)] <- 0
dt[, paste0(colnames(dt)[2:ncol(dt)], "累計") := lapply(.SD, cumsum), .SDcols = c(2:ncol(dt))]

fwrite(x = dt, file = paste0(DATA_PATH, "Pref/", "Ibaraki", "/", "summary.csv"))

# ====秋田====
# dataUrl <- 'https://raw.githubusercontent.com/asaba-zauberer/covid19-akita/development/data/data.json'
# jsonFile <- fromJSON(dataUrl)
# pcr <- data.table(date = as.Date(jsonFile$inspections_summary$labels, '%m/%d'),
#                   dailyCheck = jsonFile$inspections_summary$data$県内)

# ====神奈川====
# contact <- data.table(read.csv("http://www.pref.kanagawa.jp/osirase/1369/data/csv/contacts.csv", fileEncoding = "cp932"))
# contact[, 専用ダイヤル累計 := cumsum(合計)]
# 
# querent <- data.table(read.csv("http://www.pref.kanagawa.jp/osirase/1369/data/csv/querent.csv", fileEncoding = "cp932"))
# querent[, 相談対応件数累計 := cumsum(相談対応件数)]
# 
# patient <- data.table(read.csv("http://www.pref.kanagawa.jp/osirase/1369/data/csv/patient.csv", fileEncoding = "cp932"))
# patient$性別 <- as.character(patient$性別)
# patient[年代 %in% c('−', ''), 年代 := '非公表']
# patient[性別 %in% c("−", ''), 性別 := "非公表"]
# patientSummary <- data.table(as.data.frame.matrix(table(patient$発表日, patient$性別)), keep.rownames = T)
# 
# dt <- merge(x = contact, y = querent, by.x = "日付", by.y = "日付", all.x = T, no.dups = T)
# dt <- merge(x = dt, y = patientSummary, by.x = "日付", by.y = "rn", no.dups = T, all = T)
# dt[is.na(dt)] <- 0
# dt[, 陽性数 := rowSums(.SD), .SDcols = unique(patient$性別)]
# dt[, 累積陽性数 := cumsum(.SD), .SDcols = c("陽性数")]
# 
# fwrite(x = dt, file = paste0(DATA_PATH, "Pref/Kanagawa/summary.csv"))

# ====福岡====
patientUrl <- "https://ckan.open-governmentdata.org/dataset/8a9688c2-7b9f-4347-ad6e-de3b339ef740/resource/c27769a2-8634-47aa-9714-7e21c4038dd4/download/400009_pref_fukuoka_covid19_patients.csv"
patient <- read.csv(file(patientUrl))
fwrite(x = data.table(patient), file = paste0(DATA_PATH, "Pref/Fukuoka/patients.csv"))
testUrl <- "https://ckan.open-governmentdata.org/dataset/ef64c68a-d89e-4b1b-a53f-d2535ebfa3a1/resource/aab43191-40d0-4a6a-9724-a9030a596009/download/400009_pref_fukuoka_covid19_exam.csv"
test <- read.csv(file(testUrl))
fwrite(x = data.table(test), file = paste0(DATA_PATH, "Pref/Fukuoka/test.csv"))
contactUrl <- "https://ckan.open-governmentdata.org/dataset/f08d93ce-119a-4e0f-bd23-2a5f00d1d944/resource/b99a3d57-64e0-4cfa-b701-53713cca7df2/download/400009_pref_fukuoka_covid19_kikokusyasessyokusya.csv"
contact <- read.csv(file(contactUrl))
fwrite(x = data.table(contact), file = paste0(DATA_PATH, "Pref/Fukuoka/call.csv"))
# ====大分====

# ====沖縄====
# jsonUrl <- 'https://raw.githubusercontent.com/Code-for-OKINAWA/covid19/development/data/data.json'
# jsonFile <- fromJSON(jsonUrl)
# jsonFile$patients
# test <- signateDetail[都道府県コード == 47]

# # ====Get world data from FIND====
# coronavirus <- data.table(read.csv("https://raw.githubusercontent.com/dsbbfinddx/FINDCov19TrackerData/master/processed/coronavirus_cases.csv"))
# population <- data.table(read.csv("https://raw.githubusercontent.com/dsbb-finddx/FIND_Cov_19_Tracker/update_data/input_data/countries_codes_and_coordinates.csv"))
# 
# coronavirus[population, population := i.population, on = c(jhu_ID = "jhu_ID")]
# 
# country_name_converter <- list(
#   "United States" = "USA",
#   "China" = "Mainland China",
#   "Korea" = "Republic of Korea",
#   "Dem. Rep. Congo" = "Democratic Republic of the Congo",
#   "S. Sudan" = "South Sudan",
#   "Central African Rep." = "Central African Republic",
#   "Tanzania" = "United Republic of Tanzania",
#   "Iran" = "Iran (Islamic Republic of)",
#   "W. Sahara" = "Western Sahara",
#   "United Kingdom" = "UK",
#   "Dominican Rep." = "Dominican Republic",
#   "Lao PDR" = "Lao People's Democratic Republic",
#   "Guinea-Bissau" = "Guinea Bissau",
#   "Côte d'Ivoire" = "Cote d'Ivoire",
#   "Congo" = "Republic of the Congo",
#   "Syria" = "Syrian Arab Republic",
#   "Palestine" = "Occupied Palestinian Territory",
#   "Moldova" = "Republic of Moldova",
#   "Bosnia and Herz." = "Bosnia and Herzegovina",
#   "Macedonia" = "North Macedonia",
#   "Czech Rep." = "Czech Republic",
#   "Eq. Guinea" = "Equatorial Guinea",
#   "Bahamas" = "The Bahamas"
# )
# 
# coronavirus[, country_name_id := country]
# coronavirus[
#   country %in% country_name_converter,
#   country_name_id := names(country_name_converter[match(country, country_name_converter)])
# ]
# 
# coronavirus[, casesPer100k := round(cases / population * 10^5, 2)]
# setnafill(coronavirus, type = "const", fill = 0, cols = c("casesPer100k"))
# 
# coronavirusTest <- read.csv("https://raw.githubusercontent.com/dsbbfinddx/FINDCov19TrackerData/master/processed/coronavirus_tests.csv")
# coronavirusTest <- data.table(coronavirusTest)
# coronavirusTest[, country_name_id := country]
# 
# # popId <- unique(population$jhu_ID)
# # testId <- unique(coronavirusTest$jhu_ID)
# convertJhuIdInTest <- list(
#   "SouthSudan" = "South Sudan",
#   "Tanzania" = "UnitedRepublicofTanzania",
#   "Laos" = "LaoPeople'sDemocraticRepublic"
#   # Scotland?
# )
# coronavirusTest[
#   jhu_ID %in% convertJhuIdInTest,
#   jhu_ID := names(convertJhuIdInTest[match(jhu_ID, convertJhuIdInTest)])
# ]
# coronavirusTest[population, population := i.population, on = c(jhu_ID = "jhu_ID")]
# 
# coronavirusTest[
#   country %in% country_name_converter,
#   country_name_id := names(country_name_converter[match(country, country_name_converter)])
# ]
# 
# coronavirusTest[, testsPer100k := round(tests_cumulative / population * 10^5, 2)]
# coronavirusTest[, `:=`(ind = NULL, X = NULL)]
# 
# coronavirus <- coronavirus[coronavirusTest, `:=`(
#   new_tests = i.new_tests,
#   tests_cumulative = i.tests_cumulative
# ),
# on = c(date = "date", country_name_id = "country_name_id")
# ][order(country_name_id, date)]
# coronavirus[, tests_cumulative := tests_cumulative[1], by = .(country_name_id, cumsum(!is.na(tests_cumulative)))]
# coronavirus[, `:=`(
#   testsPer100k = round(tests_cumulative / population * 10^5, 2),
#   positiveRate = round(cases / tests_cumulative * 100, 2)
# )]
# 
# fwrite(coronavirus, paste0(DATA_PATH, "FIND/worldSummary.csv"))
# 
# coronavirus[, date := as.Date(as.character(date))]
# 
# dateSpan <- 21
# 
# createSparkLine <- function(bar, line, lightColor, darkColor) {
#   sparkline <- sapply(unique(as.character(coronavirus$country_name_id)), function(index) {
#     # 新規値
#     value <- tail(coronavirus[country_name_id == index][[bar]], n = dateSpan)
#     # 累計値
#     cumsumValue <- tail(coronavirus[country_name_id == index][[line]], n = dateSpan)
#     # 日付
#     date <- tail(coronavirus[country_name_id == index, date], n = dateSpan)
#     colorMapSetting <- rep(lightColor, length(value))
#     colorMapSetting[length(value)] <- darkColor
#     namesSetting <- as.list(date)
#     names(namesSetting) <- 0:(length(value) - 1)
#     # 新規
#     diff <- sparkline(
#       values = value,
#       type = "bar",
#       chartRangeMin = 0,
#       width = 80,
#       tooltipFormat = "{{offset:names}}<br><span style='color: {{color}}'>&#9679;</span> New {{value}}",
#       tooltipValueLookups = list(
#         names = namesSetting
#       ),
#       colorMap = colorMapSetting
#     )
#     # 累計
#     cumsumSpk <- sparkline(
#       values = cumsumValue,
#       type = "line",
#       width = 80,
#       fillColor = F,
#       lineColor = darkColor,
#       tooltipFormat = "<span style='color: {{color}}'>&#9679;</span> Total {{y}}"
#     )
#     return(as.character(htmltools::as.tags(spk_composite(diff, cumsumSpk))))
#   })
#   return(sparkline)
# }
# 
# testsSparkline <- createSparkLine(bar = "new_tests", line = "tests_cumulative", middleYellow, darkYellow)
# casesSparkline <- createSparkLine(bar = "new_cases", line = "cases", middleRed, darkRed)
# deathsSparkline <- createSparkLine(bar = "new_deaths", line = "deaths", middelNavy, darkNavy)
# positiveRatioSparkline <- sapply(unique(as.character(coronavirus$country_name_id)), function(index) {
#   value <- tail(coronavirus[country_name_id == index, .(round(new_cases/new_tests * 100, 2))], n = dateSpan)[[1]]
#   # 日付
#   date <- tail(coronavirus[country_name_id == index, date], n = dateSpan)
#   namesSetting <- as.list(date)
#   names(namesSetting) <- 0:(length(date) - 1)
#   
#   if (length(value) > 0) {
#     diff <- spk_chr(
#       values = value,
#       type = "line",
#       width = 80,
#       lineColor = darkRed,
#       fillColor = "#f2b3aa",
#       tooltipFormat = "{{offset:names}}<br><span style='color: {{color}}'>&#9679;</span> Rate：{{y}}%",
#       tooltipValueLookups = list(
#         names = namesSetting
#       )
#     )
#   } else {
#     diff <- NA
#   }
#   return(diff)
# })
# 
# coronavirusSummary <-
#   coronavirus[
#     date == max(date),
#     .(
#       Country = country,
#       Tests = tests_cumulative,
#       `Tests/100K pop` = testsPer100k,
#       Cases = cases,
#       `New Cases` = new_cases,
#       `Cases/100K pop` = casesPer100k,
#       Deaths = deaths,
#       `New Deaths` = new_deaths,
#       `Deaths/100K pop` = round(deaths / population * 10^5, 2),
#       country_name_id
#     )
#   ][order(-Cases)]
# 
# coronavirusSummary[, `Test Trends` := lapply(country_name_id, function(x){
#   testsSparkline[which(x == names(testsSparkline))]
# })]
# coronavirusSummary[, `Cases Trends` := lapply(country_name_id, function(x){
#   casesSparkline[which(x == names(casesSparkline))]
# })]
# coronavirusSummary[, `Deaths Trends` := lapply(country_name_id, function(x){
#   deathsSparkline[which(x == names(deathsSparkline))]
# })]
# coronavirusSummary[, `Cases/Tests` := lapply(country_name_id, function(x){
#   positiveRatioSparkline[which(x == names(positiveRatioSparkline))]
# })]
# 
# coronavirusSummary[, country_name_id := NULL]
# coronavirusSummary[, `Test Trends` := gsub("\\n", "", `Test Trends`)]
# coronavirusSummary[, `Cases Trends` := gsub("\\n", "", `Cases Trends`)]
# coronavirusSummary[, `Deaths Trends` := gsub("\\n", "", `Deaths Trends`)]
# coronavirusSummary[, `Cases/Tests` := gsub("\\n", "", `Cases/Tests`)]
# 
# fwrite(coronavirusSummary, file = paste0(DATA_PATH, "FIND/worldSummaryTable.csv"), sep = "@", quote = F)
# 
# # sketch_summary <- htmltools::withTags(table(
# #   class = "display",
# #   thead(
# #     tr(
# #       th(rowspan = 2, "Rank"),
# #       th(rowspan = 2, "Country"),
# #       th(colspan = 2, tagList(icon("vials"), "Tests")),
# #       th(colspan = 3, "Cases"),
# #       th(colspan = 3, "Deaths")
# #     ),
# #     tr(
# #       lapply(
# #         c(
# #           c("Total", "Per 100K pop"),
# #           rep(c("Total", "New", "Per 100K pop"), 2)
# #           ),
# #         th
# #       )
# #     )
# #   )
# # ))
# #
# # datatable(
# #   coronavirusSummary,
# #   container = sketch_summary,
# #   escape = F,
# #   options = list(
# #     paging = F,
# #     scrollY = "540px"
# #   )
# # ) %>%
# #   formatRound(
# #     columns = c("Tests", "Cases", "New Cases", "Deaths", "New Deaths"),
# #     digits = 0
# #   ) %>%
# #   formatRound(
# #     columns = c("Tests/100K pop", "Cases/100K pop", "Deaths/100K pop"),
# #     digits = 0
# #   ) %>%
# #   formatStyle(
# #     columns = "Tests",
# #     color = do.call(
# #       styleInterval,
# #       generateColorStyle(data = coronavirusSummary$Tests, colors = c(lightYellow, darkYellow), by = 10^6),
# #     ),
# #     background = styleColorBar(c(0, max(coronavirusSummary$Tests, na.rm = T)), middleYellow, angle = -90),
# #     backgroundSize = "98% 18%",
# #     backgroundRepeat = "no-repeat",
# #     backgroundPosition = "bottom",
# #     fontWeight = "bold"
# #   ) %>%
# #   formatStyle(
# #     columns = "Cases",
# #     background = styleColorBar(c(0, max(coronavirusSummary$Cases, na.rm = T)), middleRed, angle = -90),
# #     color = do.call(
# #       styleInterval,
# #       generateColorStyle(data = coronavirusSummary$Cases, colors = c(lightRed, darkRed), by = 10^6),
# #     ),
# #     backgroundSize = "98% 18%",
# #     backgroundRepeat = "no-repeat",
# #     backgroundPosition = "bottom",
# #     fontWeight = "bold"
# #   ) %>%
# #   formatStyle(
# #     columns = "New Cases",
# #     color = do.call(
# #       styleInterval,
# #       generateColorStyle(data = coronavirusSummary$`New Cases`, colors = c(lightRed, darkRed), by = 100),
# #     ),
# #     fontWeight = "bold"
# #   ) %>%
# #   formatStyle(
# #     columns = "Deaths",
# #     background = styleColorBar(c(0, max(coronavirusSummary$Deaths, na.rm = T)), darkNavy, angle = -90),
# #     backgroundSize = "98% 18%",
# #     backgroundRepeat = "no-repeat",
# #     backgroundPosition = "bottom"
# #   ) %>%
# #   formatStyle(
# #     columns = c("Tests/100K pop"),
# #     backgroundColor = do.call(
# #       styleInterval,
# #       generateColorStyle(data = coronavirusSummary$`Tests/100K pop`, colors = c("#FFFFFF", darkYellow), by = 10^4)
# #     ),
# #     fontWeight = "bold"
# #   ) %>%
# #   formatStyle(
# #     columns = c("Cases/100K pop"),
# #     backgroundColor = do.call(
# #       styleInterval,
# #       generateColorStyle(data = coronavirusSummary$`Cases/100K pop`, colors = c("#FFFFFF", darkRed), by = 100)
# #     ),
# #     fontWeight = "bold"
# #   ) %>%
# #   formatStyle(
# #     columns = c("Deaths/100K pop"),
# #     backgroundColor = do.call(
# #       styleInterval,
# #       generateColorStyle(data = coronavirusSummary$`Deaths/100K pop`, colors = c("#FFFFFF", darkNavy), by = 1)
# #     ),
# #     fontWeight = "bold"
# #   )
