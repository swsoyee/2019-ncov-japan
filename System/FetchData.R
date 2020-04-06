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
