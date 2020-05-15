library(stringr)
library(data.table)
# library(rvest)

url <- "https://covid19.jsicm.org"
# page <- read_html(url)
# page %>% html_nodes("script")
# list.files(url)
source <- readLines("https://covid19.jsicm.org/_nuxt/7cd6dc3800dca6449b42.js")

jsonData <- str_extract_all(gsub('\"', "", source), "JSON.parse\\(.+?\\)")[[1]]

# 地方区分
dist <- data.table(
  a = str_extract_all(jsonData[1], "a\\d")[[1]],
  dist = c(str_remove_all(str_extract_all(jsonData[1], "a\\d:.+?,")[[1]], "[a|\\d|,|:]"), "九州")
)

# 都道府県
regionNameSource <- gsub("data:\\{", "", gsub("\\}", ",", str_extract_all(jsonData[4], "data.+?\\}")[[1]]))
regionName <- mapply(function(x) do.call(rbind.data.frame, strsplit(strsplit(x, ",")[[1]], ":")), regionNameSource, SIMPLIFY = F)[[1]]
regionName <- data.table(index = as.character(regionName[[1]]), name = as.character(regionName[[2]]))

ExtractData <- function(jsonData) {
  source <- gsub("\\}", ",", str_extract_all(jsonData, "date.+?\\}")[[1]])
  preData <- mapply(function(x) do.call(rbind.data.frame, strsplit(strsplit(x, ",")[[1]], ":")), source, SIMPLIFY = F)
  data <- data.table(t(mapply(function(x) x[, 2], preData, USE.NAMES = F)))
  colnames(data) <- as.character(preData[[1]][, 1])
  colnames(data)[match(c(regionName$index, dist$a), colnames(data))] <- c(regionName$name, dist$dist)
  return(data)
}

# ECMO 装着数
ecmoUsingData <- ExtractData(jsonData[2])
fwrite(x = ecmoUsingData, file = paste0(DATA_PATH, "Collection/ecmoUsing.csv"))
# 人工呼吸器都道府県別
artificialRespiratorsData <- ExtractData(jsonData[5])
fwrite(x = artificialRespiratorsData, file = paste0(DATA_PATH, "Collection/artificialRespirators.csv"))
# 国内のCOVID-19に対するECMO治療の成績累計
ecmoSource <- gsub("\\}", ",", str_extract_all(jsonData[3], "date.+?\\}")[[1]])
ecmoData <- mapply(function(x) do.call(rbind.data.frame, strsplit(strsplit(x, ",")[[1]], ":")), ecmoSource, SIMPLIFY = F)
ecmoData <- data.table(t(mapply(function(x) x[, 2], ecmoData, USE.NAMES = F)))
ecmoData <- ecmoData[, .(日付 = V1, 実施中 = V2, 死亡 = V3, 離脱 = as.numeric(V6) + as.numeric(V7))]
fwrite(x = ecmoData, file = paste0(DATA_PATH, "Collection/ecmo.csv"))
