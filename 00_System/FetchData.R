library(rjson)
library(jsonlite)
library(data.table)
# library(gsheet)

source(file = "01_Settings/Path.R", local = T, encoding = "UTF-8")
source(file = "00_System/Generate.ProcessData.R", local = T, encoding = "UTF-8")

# ====けんもデータ====
positiveDetail <- gsheet2tbl("docs.google.com/spreadsheets/d/1Cy4W9hYhGmABq1GuhLOkM92iYss0qy03Y1GeTv4bCyg/edit#gid=1196047345")
fwrite(x = positiveDetail, file = paste0(DATA_PATH, "positiveDetail.csv"))

provincePCR <- gsheet2tbl("docs.google.com/spreadsheets/d/1Cy4W9hYhGmABq1GuhLOkM92iYss0qy03Y1GeTv4bCyg/edit#gid=845297461")
fwrite(x = provincePCR, file = paste0(DATA_PATH, "provincePCR.csv"))

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

kenmoAreaDataset <- gsheet2tbl("https://docs.google.com/spreadsheets/d/1Cy4W9hYhGmABq1GuhLOkM92iYss0qy03Y1GeTv4bCyg/edit#gid=491635333")
fwrite(x = kenmoAreaDataset, file = paste0(DATA_PATH, "Kenmo/confirmedNumberByCity.ja.csv"))
# Translate
translateSubData <- fread(paste0(DATA_PATH, "Collection/cityMaster.csv"))

translateColumn <- function(data, column, language, language_data) {
  data <- data.table(data)
  data[[column]] <- language_data[match(data[[column]], language_data[["ja"]])][[language]]
  return(data)
}
kenmoAreaDataset.cn <- translateColumn(data = kenmoAreaDataset, column = "県名", language = "cn", language_data = translateSubData)
kenmoAreaDataset.cn <- translateColumn(data = kenmoAreaDataset.cn, column = "市名", language = "cn", language_data = translateSubData)
fwrite(x = kenmoAreaDataset.cn, file = paste0(DATA_PATH, "Kenmo/confirmedNumberByCity.cn.csv"))
kenmoAreaDataset.en <- translateColumn(data = kenmoAreaDataset, column = "県名", language = "en", language_data = translateSubData)
kenmoAreaDataset.en <- translateColumn(data = kenmoAreaDataset.en, column = "市名", language = "en", language_data = translateSubData)
fwrite(x = kenmoAreaDataset.en, file = paste0(DATA_PATH, "Kenmo/confirmedNumberByCity.en.csv"))

# ====SIGNATEデータ====
# signatePlace <- gsheet2tbl('docs.google.com/spreadsheets/d/1CnQOf6eN18Kw5Q6ScE_9tFoyddk4FBwFZqZpt_tMOm4/edit#gid=103322372')
# fwrite(x = signatePlace, file = paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 接触場所マスタ.csv'))

Update.Signate.Detail <- function(update = F) {
  if (update) {
    signateDetail <- gsheet2tbl('https://docs.google.com/spreadsheets/d/10MFfRQTblbOpuvOs_yjIYgntpMGBg592dL8veXoPpp4/edit#gid=2113829779')
    signateDetail <- data.table(signateDetail)
    fwrite(x = signateDetail, file = paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 罹患者.csv'))
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
jsonFile <- fromJSON(apiUrl)
jsonResult <- jsonFile$result$resources
saveFileFromApi(jsonResult, "patients.csv", 1, "Hokkaido")

# ==== 青森 ====
apiUrl <- "https://opendata.pref.aomori.lg.jp/api/package_show?id=5e4612ce-1636-41d9-82a3-c5130a79ffe0"
jsonFile <- fromJSON(apiUrl)
jsonResult <- jsonFile$result$resources
saveFileFromApi(jsonResult, "陽性患者関係.csv", 2, "Aomori", "ＮＯ")


# ====岩手====
dataUrl <- "https://raw.githubusercontent.com/MeditationDuck/covid19/development/data/data.json"
jsonFile <- fromJSON(dataUrl)
pcr <- data.table(
  date = as.Date(jsonFile$inspections_summary$labels, "%m/%d"),
  検査数 = jsonFile$inspections_summary$data$県内
)
contact <- data.table(
  date = as.Date(jsonFile$contacts$data$日付),
  相談件数 = jsonFile$contacts$data$小計
)
querent <- data.table(
  date = as.Date(jsonFile$querents$data$日付),
  一般相談 = jsonFile$querents$data$小計
)
iwateData <- merge(x = pcr, y = contact, by = "date", no.dups = T, all = T)
iwateData <- merge(x = iwateData, y = querent, by = "date", no.dups = T, all = T)
iwateData[is.na(iwateData)] <- 0
iwateData[, 検査数累計 := cumsum(検査数)]
iwateData[, 相談件数累計 := cumsum(相談件数)]
iwateData[, 一般相談累計 := cumsum(一般相談)]
fwrite(x = iwateData, file = paste0(DATA_PATH, "Pref/", "Iwate", "/", "summary.csv"))

# ====宮城====
dataUrl <- "https://raw.githubusercontent.com/code4shiogama/covid19-miyagi/development/data/data.json"
jsonFile <- fromJSON(dataUrl)
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
jsonFile <- fromJSON(dataUrl)

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
contact <- data.table(read.csv("http://www.pref.kanagawa.jp/osirase/1369/data/csv/contacts.csv", fileEncoding = "cp932"))
contact[, 専用ダイヤル累計 := cumsum(合計)]

querent <- data.table(read.csv("http://www.pref.kanagawa.jp/osirase/1369/data/csv/querent.csv", fileEncoding = "cp932"))
querent[, 相談対応件数累計 := cumsum(相談対応件数)]

patient <- data.table(read.csv("http://www.pref.kanagawa.jp/osirase/1369/data/csv/patient.csv", fileEncoding = "cp932"))
patient$性別 <- as.character(patient$性別)
# patient[性別 == '', 性別 := '調査中']
patient[性別 == "−", 性別 := "非公表"]
patientSummary <- data.table(as.data.frame.matrix(table(patient$発表日, patient$性別)), keep.rownames = T)

dt <- merge(x = contact, y = querent, by.x = "日付", by.y = "日付", all.x = T, no.dups = T)
dt <- merge(x = dt, y = patientSummary, by.x = "日付", by.y = "rn", no.dups = T, all = T)
dt[is.na(dt)] <- 0
dt[, 陽性数 := rowSums(.SD), .SDcols = c("男性", "女性", "非公表")]
dt[, 累積陽性数 := cumsum(.SD), .SDcols = c("陽性数")]

fwrite(x = dt, file = paste0(DATA_PATH, "Pref/Kanagawa/summary.csv"))

# ====大分====

# ====沖縄====
# jsonUrl <- 'https://raw.githubusercontent.com/Code-for-OKINAWA/covid19/development/data/data.json'
# jsonFile <- fromJSON(jsonUrl)
# jsonFile$patients
# test <- signateDetail[都道府県コード == 47]
