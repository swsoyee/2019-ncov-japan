library(rjson)
library(jsonlite)
library(data.table)

DATA_PATH <- 'Data/'
signateDetail<- fread(paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 罹患者.csv'), header = T)
signateLink<- fread(paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 罹患者関係.csv'), header = T)
signatePlace<- fread(paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 接触場所マスタ.csv'), header = T)

saveFileFromApi <- function(jsonResult, patientsFileName, prefCode, pref, NoCol = 'No') {
  data <- list()
  for (i in 1:nrow(jsonResult)) {
    data[[i]] <- read.csv(file(jsonResult[i, ]$download_url, encoding = 'shift-jis'))
    print(jsonResult[i, ]$filename)
    if (grepl(patientsFileName, jsonResult[i, ]$filename)) {
      patient <- data.table(data[[i]])
      print('マージデータ...')
      mergeWithSignate <- merge(patient, signateDetail[都道府県コード == prefCode], by.x = NoCol, by.y = '都道府県別罹患者No')
      fwrite(x = mergeWithSignate, file = paste0('Data/Pref/', pref, '/', jsonResult[i, ]$filename))
    } else {
      fwrite(x = data[[i]], file = paste0('Data/Pref/', pref, '/', jsonResult[i, ]$filename))
    }
  }
}

# ==== 北海道 === 
apiUrl <- 'https://www.harp.lg.jp/opendata/api/package_show?id=752c577e-0cbe-46e0-bebd-eb47b71b38bf'
jsonFile <- fromJSON(apiUrl)
jsonResult <- jsonFile$result$resources
saveFileFromApi(jsonResult, 'patients.csv', 1, 'Hokkaido') 

# ==== 青森 ====
apiUrl <- 'https://opendata.pref.aomori.lg.jp/api/package_show?id=5e4612ce-1636-41d9-82a3-c5130a79ffe0'
jsonFile <- fromJSON(apiUrl)
jsonResult <- jsonFile$result$resources
saveFileFromApi(jsonResult, '陽性患者関係.csv', 2, 'Aomori', 'ＮＯ')


# ====岩手====
# dataUrl <- 'https://raw.githubusercontent.com/MeditationDuck/covid19/development/data/data.json'
# jsonFile <- fromJSON(dataUrl)
# pcr <- data.table(date = as.Date(jsonFile$inspections_summary$labels, '%m/%d'), 
#                   dailyCheck = jsonFile$inspections_summary$data$県内)

# ====秋田====
# dataUrl <- 'https://raw.githubusercontent.com/asaba-zauberer/covid19-akita/development/data/data.json'
# jsonFile <- fromJSON(dataUrl)
# pcr <- data.table(date = as.Date(jsonFile$inspections_summary$labels, '%m/%d'),
#                   dailyCheck = jsonFile$inspections_summary$data$県内)

# ====神奈川====
contact <- data.table(read.csv('http://www.pref.kanagawa.jp/osirase/1369/data/csv/contacts.csv', fileEncoding = 'cp932'))
contact[, 専用ダイヤル累計 := cumsum(合計)]
  
querent <- data.table(read.csv('http://www.pref.kanagawa.jp/osirase/1369/data/csv/querent.csv', fileEncoding = 'cp932'))
querent[, 相談対応件数累計 := cumsum(相談対応件数)]

patient <- data.table(read.csv('http://www.pref.kanagawa.jp/osirase/1369/data/csv/patient.csv', fileEncoding = 'cp932'))
patient$性別 <- as.character(patient$性別)
# patient[性別 == '', 性別 := '調査中']
patient[性別 == '−', 性別 := '非公表']
patientSummary <- data.table(as.data.frame.matrix(table(patient$発表日, patient$性別)), keep.rownames = T)

dt <- merge(x = contact, y = querent, by.x = '日付', by.y = '日付', all.x = T, no.dups = T)
dt <- merge(x = dt, y = patientSummary, by.x = '日付', by.y = 'rn', no.dups = T, all = T)
dt[is.na(dt)] <- 0
dt[, 陽性数 := rowSums(.SD), .SDcols = c('男性', '女性', '非公表')]
dt[, 累積陽性数 := cumsum(.SD), .SDcols = c('陽性数')]

fwrite(x = dt, file = paste0('Data/Pref/Kanagawa/summary.csv'))


