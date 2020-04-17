library(data.table)
# library(gsheet)

DATA_PATH <- "Data/"
signateDetailUrl <- "https://docs.google.com/spreadsheets/d/10MFfRQTblbOpuvOs_yjIYgntpMGBg592dL8veXoPpp4/edit#gid=0"
data <- data.table(gsheet2tbl(signateDetailUrl))

dt <- data[
  !is.na(受診都道府県) & !is.na(発症日) & !is.na(確定日),
  .(受診都道府県, 発症日 = as.Date(発症日), 確定日 = as.Date(確定日))
]

dt[, 発症から診断までの平均日数 := round(as.numeric(mean(確定日 - 発症日)), 2), by = 受診都道府県]

dt <- unique(dt[, .(受診都道府県, 発症から診断までの平均日数)])
dt[, ja := 受診都道府県]
dt[ja != "北海道", ja := substr(ja, 1, nchar(ja) - 1)]

provinceCode <- fread(paste0(DATA_PATH, "prefectures.csv"))

mergeDt <- merge(x = dt, y = provinceCode, by.x = "ja", by.y = "name-ja", all.y = T)
fwrite(x = mergeDt, file = paste0(DATA_PATH, "/Academic/onset2ConfirmedMap.csv"))

# mergeDt %>%
#   e_charts(ja) %>%
#   em_map("Japan") %>%
#   e_map(発症から診断までの平均日数, map = "Japan",
#         name = '感染確認数',
#         nameMap = nameMap,
#         layoutSize = '50%',
#         center = c(137.1374062, 36.8951298),
#         zoom = 1.5,
#         itemStyle = list(
#           borderWidth = 0.2,
#           borderColor = 'white'
#         ),
#         emphasis = list(
#           label = list(
#             fontSize = 8
#           )
#         ),
#         roam = 'move') %>%
#   e_visual_map(
#     発症から診断までの平均日数,
#     top = '20%',
#     left = '0%',
#     inRange = list(color = c('#EEEEEE', lightYellow, darkRed)),
#     type = 'piecewise',
#     splitList = list(
#       list(min = 7),
#       list(min = 6, max = 7),
#       list(min = 5, max = 6),
#       list(min = 0, max = 5),
#       list(value = 0)
#     )
#   ) %>% e_color(background = '#FFFFFF') %>%
#   e_tooltip(formatter = htmlwidgets::JS('
#       function(params) {
#         if(params.value) {
#           return(`${params.name}<br>平均所用日数${Math.round(params.value * 100) / 100}日`)
#         } else {
#           return("");
#         }
#       }
#     ')) %>%
#   e_title(
#     text = '発症から診断までの平均日数マップ',
#     subtext = 'データ：SIGNATE COVID-19 Case Dataset',
#     sublink = 'https://docs.google.com/spreadsheets/d/10MFfRQTblbOpuvOs_yjIYgntpMGBg592dL8veXoPpp4/edit#gid=0'
#   )