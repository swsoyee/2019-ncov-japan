library(data.table)

DATA_PATH <- "Data/"

# =====SIGNATE データ処理=====
provinceCode <- fread(paste0(DATA_PATH, "prefectures.csv"))
# svgIcon <- fread(paste0(DATA_PATH, 'svg.csv'))
# clusterPlace<- fread(paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 接触場所マスタ.csv'), header = T)

signateDetail <- fread(paste0(DATA_PATH, "SIGNATE COVID-2019 Dataset - 罹患者.csv"), header = T)
signateDetail[, 受診都道府県 := gsub("県", "", 受診都道府県)]
signateDetail[, 受診都道府県 := gsub("府", "", 受診都道府県)]
signateDetail[, 受診都道府県 := gsub("東京都", "東京", 受診都道府県)]
signateDetail[, regionId := paste0(都道府県コード, "-", 都道府県別罹患者No)]

# 年代変換
oldYear <- c("0 - 9", "10 - 19", "20 - 29", "30 - 39", "40 - 49", "50 - 59", "60 - 69", "70 - 79", "80 - 89", "-90", "非公表", "", NA)
newYear <- c("10歳未満", "10代", "20代", "30代", "40代", "50代", "60代", "70代", "80代", "90代", "非公表", "調査中", "調査中")
names(oldYear) <- newYear
for (i in oldYear) {
  signateDetail[年代 == i, 年代 := names(oldYear[i == oldYear][1])]
}
# ステータス変換
signateDetail[ステータス == 0, status := "罹患中"]
signateDetail[ステータス == 1, status := "回復"]
signateDetail[ステータス == 2, status := "死亡"]
signateDetail[is.na(ステータス), status := "調査中"]
# アイコンサイズ設定
signateDetail$size <- 18
# 公表日
signateDetail$公表日 <- as.Date(signateDetail$公表日)

# signateDetail[性別 == '男性', symbolIcon := paste0('path://', svgIcon[name == 'male']$svg)]
# signateDetail[性別 == '女性', symbolIcon := paste0('path://', svgIcon[name == 'female']$svg)]
# signateDetail[性別 == '男性' & 年代 %in% c('60代', '70代', '80代', '90代'), symbolIcon := paste0('path://', svgIcon[name == 'grandpa']$svg)]
# signateDetail[性別 == '女性' & 年代 %in% c('60代', '70代', '80代', '90代'), symbolIcon := paste0('path://', svgIcon[name == 'grandma']$svg)]
# signateDetail[医療従事者ﾌﾗｸﾞ== 1 & 性別 == '男性', symbolIcon := paste0('path://', svgIcon[name == 'doctorMale']$svg) ]
# signateDetail[医療従事者ﾌﾗｸﾞ== 1 & 性別 == '女性', symbolIcon := paste0('path://', svgIcon[name == 'nurseFemale']$svg) ]

signateDetail[, `症状・経過` := gsub("\n", "<br>", `症状・経過`)]
signateDetail[, `行動歴` := gsub("\n", "<br>", `行動歴`)]

signateDetail[, label := paste(
  sep = "|",
  paste0(受診都道府県, "-", 都道府県別罹患者No),
  公表日, 年代, 性別, 職業, `症状・経過`, 行動歴, 情報源, status, 居住地, 濃厚接触者状況
)]

signateLink <- fread(paste0(DATA_PATH, "SIGNATE COVID-2019 Dataset - 罹患者関係.csv"), header = T)

for (i in 1:nrow(signateLink)) {
  pref1 <- provinceCode[id == signateLink[i]$`id1-1`]$`name-ja`
  pref2 <- provinceCode[id == signateLink[i]$`id2-1`]$`name-ja`
  # if (signateLink[i]$場所 %in% clusterPlace$接触場所) { # クラスター対応予定
  #   signateLink[i, source := paste0(pref1, 場所)]
  # } else {
  signateLink[i, source := paste0(pref1, `id1-2`)]
  signateLink[i, sourceLabel := paste(
    sep = "|",
    paste0(pref1, "-", `id1-2`),
    paste(
      unlist(
        signateDetail[
          罹患者id == signateLink[i]$罹患者id1,
          .(公表日, 年代, 性別, 職業, `症状・経過`, 行動歴, 情報源, status, 居住地, 濃厚接触者状況)
        ]
      ),
      collapse = "|"
    )
  )]
  # }
  signateLink[i, target := paste0(pref2, `id2-2`)]
  signateLink[i, targetLabel := paste(
    sep = "|",
    paste0(pref2, "-", `id2-2`),
    paste(
      unlist(
        signateDetail[
          罹患者id == signateLink[i]$罹患者id2,
          .(公表日, 年代, 性別, 職業, `症状・経過`, 行動歴, 情報源, status, 居住地, 濃厚接触者状況)
        ]
      ),
      collapse = "|"
    )
  )]
}

signatePlace <- fread(paste0(DATA_PATH, "SIGNATE COVID-2019 Dataset - 接触場所マスタ.csv"), header = T)
signatePlace[, mapPopup := paste0('<a href="', signatePlace$情報源, '">', signatePlace$接触場所, "</a>")]

# テーブル出力
fwrite(x = signateDetail, file = paste0(DATA_PATH, "resultSignateDetail.csv"))
fwrite(x = signateLink, file = paste0(DATA_PATH, "resultSignateLink.csv"))
fwrite(x = signatePlace, file = paste0(DATA_PATH, "resultSignatePlace.csv"))

# フィルター
# prefCode <- 12
# linkFilter <- signateLink[`id1-1` %in% prefCode | `id2-1` %in% prefCode]
# idFilter <-  unique(c(linkFilter$罹患者id1, linkFilter$罹患者id2))
# edge <- linkFilter
# node <- signateDetail[罹患者id %in% idFilter | 都道府県コード %in% prefCode]
#
# edge <- signateLink # TEST
# node <- signateDetail # TEST
#
# e_charts() %>%
#   e_graph(
#     # layout = 'force',
#     roam = T,
#     draggable = T,
#     symbolKeepAspect = T,
#     focusNodeAdjacency = T) %>%
#   e_graph_nodes(
#     node,
#     names = regionId, size = size, category = 性別,
#     value = label #,
#     # symbol = symbolIcon
#   ) %>%
#   e_graph_edges(edge, target = 罹患者id2, source = 罹患者id1) %>%
#   e_labels(formatter = htmlwidgets::JS(paste0('
#     function(params) {
#       if (params.value) {
#         const text = params.value.split("|")
#         const id = text[0].split("-")
#         const status = text[8] == "死亡" ? "{death|†}" : ""
#         const minDate = Date.parse("2020-03-25")
#         const maxDate = Date.parse("2020-04-05")
#         const thisDate = Date.parse(text[1])
#         const labelBox = (thisDate >= minDate && thisDate <= maxDate)
#                          ? "inDateRange" : "outDateRange"
#         return(`${status}{${labelBox}|${id[0].substring(0,1)}${id[1]}}`)
#       }
#     }
#   ')), rich = list(
#     inDateRange = list(borderColor = 'auto', borderWidth = 2, borderRadius = 2, padding = 3, fontSize = 8),
#     outDateRange = list(borderColor = 'transparent', borderWidth = 2, borderRadius = 2, padding = 3, fontSize = 8),
#     death = list(borderColor = 'auto', borderWidth = 2, borderRadius = 10, padding = 3)
#   ),) %>%
#   e_tooltip(formatter = htmlwidgets::JS('
#     function(params) {
#       if (params.value) {
#         const text = params.value.split("|")
#         return(`
#           番号：${text[0]}<br>
#           公表日：${text[1]}<br>
#           年代：${text[2]}<br>
#           性別：${text[3]}
#         `)
#       }
#     }
#   ')) %>%
#   # e_modularity() %>%
#   e_title(
#     text = paste0('合計：', nrow(node), '人'),
#     subtext = paste0('公表日：', min(as.Date(node$公表日), na.rm = T), ' ~ ', max(as.Date(node$公表日), na.rm = T))
#   )