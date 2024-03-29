library(data.table)
library(sparkline)

source(file = "01_Settings/Path.R", local = T, encoding = "UTF-8")
jMobility <- fread(paste0(DATA_PATH, "Google/Global_Mobility_Report.Japan.csv"))

nameJa <- unique(jMobility$nameJa)

prefResultList <- data.table()
for (pref in nameJa) {
  prefDt <- jMobility[nameJa == pref]
  cols <- names(prefDt)[6:11]
  date <- prefDt$date

  sparklineList <- list()
  averageList <- list()
  for (serie in cols) {
    values <- prefDt[, get(serie)]
    label <- unlist(lapply(values, function(x) {
      if (x < 0) {
        return(as.character(x))
      } else {
        return(paste0("+", x))
      }
    }))
    sparklineList[[serie]] <- spk_chr(
      values = values,
      spotRadius = 3,
      spotColor = F,
      fillColor = F,
      normalRangeMin = 0,
      normalRangeMax = 1,
      lineWidth = 1.2,
      width = 80,
      lineColor = lightNavy,
      normalRangeColor = darkYellow,
      minSpotColor = middleGreen, maxSpotColor = middleRed,
      tooltipFormat = "{{offset:names}}<br>{{offset:labels}}%",
      tooltipValueLookups = list(
        names = date,
        labels = label
      )
    )
    medianValue <- round(mean(values[(length(values) - 7):length(values)], na.rm = T), 0)
    averageList[[serie]] <- ifelse(medianValue < 0, as.character(medianValue),  paste0("+", medianValue))
  }
  prefResultList <- rbind(
    prefResultList,
    data.table(
      "自治体" = pref,
      "娯楽関連施設" = paste0("<b>", averageList[1], "%</b><span style='float:right'>", sparklineList[1], "</span>"),
      "食料品やドラッグストア" = paste0("<b>", averageList[2], "%</b><span style='float:right'>", sparklineList[2], "</span>"),
      "公園" = paste0("<b>", averageList[3], "%</b><span style='float:right'>", sparklineList[3], "</span>"),
      "公共交通機関" = paste0("<b>", averageList[4], "%</b><span style='float:right'>", sparklineList[4], "</span>"),
      "職場" = paste0("<b>", averageList[5], "%</b><span style='float:right'>", sparklineList[5], "</span>"),
      "住宅" = paste0("<b>", averageList[6], "%</b><span style='float:right'>", sparklineList[6], "</span>")
    )
  )
}

# TODO 書き方直す
prefResultList[, 娯楽関連施設 := gsub("\\n", "", 娯楽関連施設)]
prefResultList[, 食料品やドラッグストア := gsub("\\n", "", 食料品やドラッグストア)]
prefResultList[, 公園 := gsub("\\n", "", 公園)]
prefResultList[, 公共交通機関 := gsub("\\n", "", 公共交通機関)]
prefResultList[, 職場 := gsub("\\n", "", 職場)]
prefResultList[, 住宅 := gsub("\\n", "", 住宅)]
fwrite(x = prefResultList, paste0(DATA_PATH, "Google/Global_Mobility_Report.Japan.Table.csv"), sep = "@", quote = F)

# # TEST
# DT::datatable(prefResultList,
#   escape = F,
#   colnames = c("a", "b", "c", "d", "e", "f", as.character(icon("house-user"))),
#   options = list(
#     dom = "t",
#     scrollY = "540px",
#     scrollX = T,
#     paging = F,
#     fnDrawCallback = htmlwidgets::JS("
#       function() {
#         HTMLWidgets.staticRender();
#       }
#     ")
#   )
# ) %>% spk_add_deps()
