library(rjson)
library(jsonlite)
library(data.table)

signateDetail<- fread(paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 罹患者.csv'), header = T)
# ==== 北海道 === 
apiUrl <- 'https://www.harp.lg.jp/opendata/api/package_show?id=752c577e-0cbe-46e0-bebd-eb47b71b38bf'
jsonFile <- fromJSON(apiUrl)
result <- jsonFile$result$resources
data <- list()

# urlText <- result[3, ]$download_url # TEST
# testData <- read.csv(file(urlText, encoding = 'shift-jis')) # TEST

for (i in 1:nrow(result)) {
  data[[i]] <- read.csv(file(result[i, ]$download_url, encoding = 'shift-jis'))
  if (result[i, ]$filename == 'patients.csv') {
    patient <- data.table(data[[i]])
    mergeWithSignate <- merge(patient, signateDetail[都道府県コード == 1], by.x = 'No', by.y = '都道府県別罹患者No')
    fwrite(x = mergeWithSignate, file = paste0('Data/Pref/Hokkaido/', result[i, ]$filename))
  } else {
    fwrite(x = data[[i]], file = paste0('Data/Pref/Hokkaido/', result[i, ]$filename))
  }
}
