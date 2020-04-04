library(rjson)
library(jsonlite)
library(data.table)

# ==== 北海道 === 
apiUrl <- 'https://www.harp.lg.jp/opendata/api/package_show?id=752c577e-0cbe-46e0-bebd-eb47b71b38bf'
jsonFile <- fromJSON(apiUrl)
result <- jsonFile$result$resources
data <- list()

# urlText <- result[3, ]$download_url # TEST
# testData <- read.csv(file(urlText, encoding = 'shift-jis')) # TEST

for (i in 1:nrow(result)) {
  data[[i]] <- read.csv(file(result[i, ]$download_url, encoding = 'shift-jis'))
  fwrite(x = data[[i]], file = paste0('Data/Pref/Hokkaido/', result[i, ]$filename))
}
