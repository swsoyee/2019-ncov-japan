library(magrittr)
library(data.table)
library(sparkline)
source("R/fix_prefecture_str.R")

# ====準備部分====
DATA_PATH <- 'Data/'
# 感染者ソーステーブルを取得
byDate <- fread(paste0(DATA_PATH, 'byDate.csv'), header = TRUE) %>% 
  set_prefecture_fullnames()
byDate[is.na(byDate)] <- 0
byDate$date <- lapply(byDate[, 1], function(x){as.Date(as.character(x), format = '%Y%m%d')})
# 死亡データ
death <- fread(paste0(DATA_PATH, 'death.csv')) %>% 
  set_prefecture_fullnames()
death[is.na(death)] <- 0
# 国内の日報
domesticDailyReport <- fread(paste0(DATA_PATH, 'domesticDailyReport.csv'))
domesticDailyReport$date <- as.Date(as.character(domesticDailyReport$date), '%Y%m%d')
setnafill(domesticDailyReport, type = 'locf')
# チャーター便の日報
flightDailyReport <- fread(paste0(DATA_PATH, 'flightDailyReport.csv'))
flightDailyReport$date <- as.Date(as.character(flightDailyReport$date), '%Y%m%d')
setnafill(flightDailyReport, type = 'locf')
# クルーズ船の日報
shipDailyReport <- fread(paste0(DATA_PATH, 'shipDailyReport.csv'))
shipDailyReport$date <- as.Date(as.character(shipDailyReport$date), '%Y%m%d')
setnafill(shipDailyReport, type = 'locf')
# 空港検疫の日報
airportDailyReport <- fread(paste0(DATA_PATH, 'airportDailyReport.csv'))
airportDailyReport$date <- as.Date(as.character(airportDailyReport$date), '%Y%m%d')
setnafill(airportDailyReport, type = 'locf')
# コールセンター
callCenterDailyReport <- fread(paste0(DATA_PATH, 'callCenter.csv'))
callCenterDailyReport$date <- as.Date(as.character(callCenterDailyReport$date), '%Y%m%d')
# 文言データを取得
lang <- fread(paste0(DATA_PATH, 'lang.csv'))
langCode <- 'ja'
# 都道府県人口密度
provinceAttr <- fread(paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 都道府県マスタ.csv'))
provinceAttr$人口 <- as.numeric(gsub(',', '', provinceAttr$人口))
# provinceAttr[, `都道府県` := gsub('県', '', `都道府県`)]
# provinceAttr[, `都道府県` := gsub('府', '', `都道府県`)]
# provinceAttr[, `都道府県` := gsub('東京都', '東京', `都道府県`)]
# 色設定
lightRed <- '#F56954'
middleRed <- '#DD4B39'
darkRed <- '#B03C2D'
lightYellow <- '#F8BF76'
middleYellow <- '#F39C11'
darkYellow <- '#DB8B0A'
lightGreen <- '#00A65A'
middleGreen <- '#01A65A'
darkGreen <- '#088448'
superDarkGreen <- '#046938'
lightNavy <- '#5A6E82'
middelNavy <- '#001F3F'
darkNavy <- '#001934'
lightGrey <- '#F5F5F5'
lightBlue <- '#7BD6F5'
middleBlue <- '#00C0EF'
darkBlue <- '#00A7D0'

# ====日報====
dailyReport <- domesticDailyReport
dailyReport <- merge(x = domesticDailyReport, y = flightDailyReport, by = 'date', all.x = T, suffixes = c('.d', '.f'))
dailyReport <- merge(x = dailyReport, y = airportDailyReport, by = 'date', all.x = T)
dailyReport <- merge(x = dailyReport, y = shipDailyReport, by = 'date', all.x = T)
dailyReport[, pcr := rowSums(.SD, na.rm = T), .SDcols = c('pcr.d', 'pcr.f', 'pcr.x', 'pcr.y')]
dailyReport[, discharge := rowSums(.SD, na.rm = T), .SDcols = c('discharge.d', 'discharge.f', 'discharge.x', 'discharge.y')]
dailyReport[, pcrDiff := pcr - shift(pcr)]
dailyReport[, dischargeDiff := discharge - shift(discharge)]
fwrite(x = dailyReport, file = paste0(DATA_PATH, 'resultDailyReport.csv'))


# ====各都道府県のサマリーテーブル====
# ランキングカラムを作成
# cumDt <- cumsum(byDate[, c(2:48, 50)])
# rankDt <- data.table(t(apply(-cumDt, 1, function(x){rank(x, ties.method = 'min')})))
# rankDt[, colnames(rankDt) := shift(.SD, fill = 0) - .SD, .SDcols = colnames(rankDt)]
# 
# rankDt[rankDt == 0] <- '-'
# rankDt[, colnames(rankDt) := ifelse(.SD > 0, paste0('+', .SD), .SD), .SDcols = colnames(rankDt)]

# 新規なし継続日数カラム作成
zeroContinuousDay <- stack(lapply(byDate[, 2:ncol(byDate)], function(region) {
  continuousDay <- 0
  for (x in region) {
    if(x == 0){
      continuousDay <- continuousDay + 1
    } else {
      continuousDay <- 0
    }
  }
  return(continuousDay - 1)
}))
# 感染確認カラム作成
total <- colSums(byDate[, 2:ncol(byDate)])
# 新規カラム作成
today <- colSums(byDate[nrow(byDate), 2:ncol(byDate)])
# 昨日までカラム作成
untilToday <- colSums(byDate[1:nrow(byDate) - 1, 2:ncol(byDate)])
# 新規推移カラム作成
diffSparkline <- sapply(2:ncol(byDate), function(i) {
  value <- byDate[(nrow(byDate) - 15):nrow(byDate), i, with = F][[1]]
  diff <- spk_chr(
    values = value,
    type = 'bar',
    barColor = middleRed,
    chartRangeMin = 0#,
    # chartRangeMax = max(byDate[, c(2:48, 50)])
  )
  return(diff)
})

# 新規退院者カラム作成
detailByRegion <- fread(paste0(DATA_PATH, 'detailByRegion.csv'))
detailByRegion[, `日付` := as.Date(as.character(`日付`), '%Y%m%d')]
# detailByRegion[, `都道府県名` := gsub('県', '', `都道府県名`)]
# detailByRegion[, `都道府県名` := gsub('府', '', `都道府県名`)]
# detailByRegion[, `都道府県名` := gsub('東京都', '東京', `都道府県名`)]
detailByRegion[order(`日付`), dischargedDiff := `退院者` - shift(`退院者`), by = `都道府県名`]
detailByRegion[is.na(detailByRegion)] <- 0

# 退院推移
dischargedDiffSparkline <- sapply(colnames(byDate)[c(2:48, 50)], function(region) {
  value <- detailByRegion[`都道府県名` == region]$dischargedDiff
  if (length(value) > 0) {
    diff <- spk_chr(
      values = value,
      type = 'bar',
      barColor = middleGreen,
      chartRangeMin = 0 #,
      # chartRangeMax = max(detailByRegion$dischargedDiff, na.rm = T)
    )
  } else {
    diff <- NA
  }
  return(diff)
})

# 死亡カラム作成
deathByRegion <- stack(colSums(death[, 2:ncol(byDate)]))

# 感染者内訳
detailSparkLineDt <- detailByRegion[日付 == max(日付)]
detailSparkLine <- sapply(detailSparkLineDt$都道府県名, function(region) {
  # 2020-03-30 厚労省の発表資料の基準は（無症状を除く、PCR陽性者、累積者）三度も変更が有るため、この部分を破棄します。
  # 厚労省の定義は、死亡後に陽性に確認された人は患者数に含まれていないようで、
  # マイナスのデータを防ぐため修正します。
  # region = '千葉' # TEST
  # fixDiff <- (detailSparkLineDt[都道府県名 == region, 患者数] - 
  #               detailSparkLineDt[都道府県名 == region, 入院中] - 
  #               detailSparkLineDt[都道府県名 == region, 退院者] - 
  #               detailSparkLineDt[都道府県名 == region, 死亡者])
  # fixConfirmed <- ifelse(fixDiff < 0, 
  #                        detailSparkLineDt[都道府県名 == region, 患者数] - fixDiff, 
  #                        detailSparkLineDt[都道府県名 == region, 患者数])
  # 2020-03-30 対応分
  
  confirmed <- ifelse(total[names(total) == region][[1]] > detailSparkLineDt[都道府県名 == region, 患者数],
                      total[names(total) == region][[1]],
                      detailSparkLineDt[都道府県名 == region, 患者数])
  spk_chr(type = 'pie', 
          values = c(
            confirmed - sum(detailSparkLineDt[都道府県名 == region, .(入院中, 退院者, 死亡者)]),
            detailSparkLineDt[都道府県名 == region, 入院中],
            detailSparkLineDt[都道府県名 == region, 退院者],
            detailSparkLineDt[都道府県名 == region, 死亡者]
            ),
          sliceColors = c(middleRed, middleYellow, middleGreen, darkNavy),
          tooltipFormat = '<span style="color: {{color}}">&#9679;</span> {{offset:names}} ({{percent.1}}%)',
          tooltipValueLookups = list(
            names = list(
              '0' = '累積陽性者（情報まちを含む）',
              '1' = '入院者',
              '2' = '退院者',
              '3' = '死亡者'
            )
          )
          )
})

# 感染密度
# for (i in 1:length(total)) {
#   provinceAttr[names(total[i]) == 都道府県, millianConfirmed :=
#     (total[i] / (provinceAttr[都道府県 == names(total[i])]$人口 / 1000000))[[1]]]
# }


# テーブル作成
totalToday <- paste0(total, '<r ', today, '<r >')

mergeDt <- data.table(region = names(total), 
                      count = total, 
                      today = today, 
                      totalToday = totalToday,
                      untilToday = untilToday,
                      diff = diffSparkline,
                      dischargeDiff = '',
                      detailBullet = '',
                      death = deathByRegion$values,
                      zeroContinuousDay = zeroContinuousDay$values
                      )

for (i in mergeDt$region) {
  mergeDt[region == i]$dischargeDiff <- dischargedDiffSparkline[i][[1]]
  mergeDt[region == i]$detailBullet <- detailSparkLine[i][[1]]
}


# オーダー
setorder(mergeDt, -count)
# 読み取り時のエラーを回避するため
mergeDt[, diff := gsub('\\n', '', diff)]
mergeDt[, dischargeDiff := gsub('\\n', '', dischargeDiff)]
mergeDt[, detailBullet := gsub('\\n', '', detailBullet)]
# クルーズ船とチャーター便データ除外
mergeDt <- mergeDt[!(region %in% lang[[langCode]][35:36])]
# テーブル出力
fwrite(x = mergeDt, file = paste0(DATA_PATH, 'resultSummaryTable.csv'), sep = "@", quote = F)

# ====症状進行テーブル====
# 症状進展Sankey
processData <- data.table('date' = as.Date(x = integer(0), origin = "1970-01-01"),
                          'source' = character(0),
                          'target' = character(0),
                          'value' = numeric(0))

for(i in 1:nrow(domesticDailyReport)) {
  latestRecord <- domesticDailyReport[i]  
  # latestRecord <- domesticDailyReport[nrow(domesticDailyReport)] # TEST
  data <- data.table('source' = character(0), 'target' = character(0), 'value' = numeric(0))
  label.pcr <- paste0('PCR検査陽性\n100.00%')
  label.symptomless <- paste0('無症状\n', round(latestRecord$symptomless / latestRecord$positive * 100, 2), '%')
  label.symptom <- paste0('有症状\n', round(latestRecord$symptom / latestRecord$positive * 100, 2), '%')
  label.hospitalized <- paste0('入院治療必要\n', 
                               round(latestRecord$hospitalize / latestRecord$positive * 100, 2), '%')
  label.discharge <- paste0('退院\n', 
                            round(latestRecord$discharge / latestRecord$positive * 100, 2), '%')
  label.waiting <- paste0('入院待機中\n',
                          round(
                            (latestRecord$symptomlesshospitalizedWaiting + latestRecord$waiting) / 
                              (latestRecord$positive) * 100, 2), '%')
  label.mild <- paste0('軽〜中等症の者\n',
                       round(
                         (latestRecord$mild) / 
                           (latestRecord$positive) * 100, 2), '%')
  label.severe <- paste0('人工呼吸又は\nICUに入院\n',
                         round(
                           (latestRecord$severe) / 
                             (latestRecord$positive) * 100, 2), '%')
  label.confirming <- paste0('確認中\n',
                             round(
                               (latestRecord$confirming) / 
                                 (latestRecord$positive) * 100, 2), '%')
  label.death <- paste0('死亡者\n',
                        round(
                          (latestRecord$death) / 
                            (latestRecord$positive) * 100, 2), '%')
  label.symptomConfirming <- paste0('症状有無確認中\n',
                                    round(
                                      (latestRecord$symptomConfirming) / 
                                        (latestRecord$positive) * 100, 2), '%')
  # Step1 陽性、症状有無、確認中
  data <- rbind(data, list(label.pcr, label.symptomless, latestRecord$symptomless))
  data <- rbind(data, list(label.pcr, label.symptom, latestRecord$symptom))
  data <- rbind(data, list(label.pcr, label.symptomConfirming, latestRecord$symptomConfirming))
  # Step2 症状ありのみ入院
  data <- rbind(data, list(label.symptom, label.discharge, latestRecord$discharge))
  data <- rbind(data, list(label.symptom, label.hospitalized, latestRecord$hospitalize))
  data <- rbind(data, list(label.symptom, label.death, latestRecord$death))
  data <- rbind(data, list(label.symptom, label.waiting, latestRecord$waiting))

  # Step3 入院者の状態
  data <- rbind(data, list(label.hospitalized, label.mild, latestRecord$mild))
  data <- rbind(data, list(label.hospitalized, label.severe, latestRecord$severe))
  data <- rbind(data, list(label.hospitalized, label.confirming, latestRecord$confirming))

  data <- cbind(date = latestRecord$date, data)
  
  processData <- rbind(processData, data)
}
# テーブル出力
fwrite(x = processData, file = paste0(DATA_PATH, 'resultProcessData.csv'))


# =====SIGNATE データ処理=====
provinceCode <- fread(paste0(DATA_PATH, 'prefectures.csv'))
provinceCode[, `name-ja` := list(fix_prefecture_str(`name-ja`))]
# svgIcon <- fread(paste0(DATA_PATH, 'svg.csv'))
# clusterPlace<- fread(paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 接触場所マスタ.csv'), header = T)

signateDetail<- fread(paste0(DATA_PATH, '/SIGNATE COVID-2019 Dataset - 罹患者.csv'), header = T)
# signateDetail[, 受診都道府県 := gsub('県', '', 受診都道府県)]
# signateDetail[, 受診都道府県 := gsub('府', '', 受診都道府県)]
# signateDetail[, 受診都道府県 := gsub('東京都', '東京', 受診都道府県)]
signateDetail[, regionId := paste0(都道府県コード, '-', 都道府県別罹患者No)]

# 年代変換
oldYear <- c('0 - 9', '10 - 19', '20 - 29', '30 - 39', '40 - 49', '50 - 59', '60 - 69', '70 - 79', '80 - 89', '-90', '非公表', '', NA)
newYear <- c('10歳未満', '10代', '20代', '30代', '40代', '50代', '60代', '70代', '80代', '90代', '非公表', '調査中', '調査中')
names(oldYear) <- newYear
for (i in oldYear) {
  signateDetail[年代 == i, 年代 := names(oldYear[i == oldYear][1])]
}
# ステータス変換
signateDetail[ステータス == 0, status := '罹患中']
signateDetail[ステータス == 1, status := '回復']
signateDetail[ステータス == 2, status := '死亡']
signateDetail[is.na(ステータス), status := '調査中']
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

signateDetail[, `症状・経過` := gsub('\n', '<br>', `症状・経過`)]
signateDetail[, `行動歴` := gsub('\n', '<br>', `行動歴`)]

signateDetail[, label := paste(
  sep = "|",
  paste0(受診都道府県, '-', 都道府県別罹患者No), 
  公表日, 年代, 性別, 職業, `症状・経過`, 行動歴, 情報源, status, 居住地, 濃厚接触者状況
  )]

signateLink<- fread(paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 罹患者関係.csv'), header = T)

for (i in 1:nrow(signateLink)) {
  pref1 <-  provinceCode[id == signateLink[i]$`id1-1`]$`name-ja`
  pref2 <-  provinceCode[id == signateLink[i]$`id2-1`]$`name-ja`
  # if (signateLink[i]$場所 %in% clusterPlace$接触場所) { # クラスター対応予定
  #   signateLink[i, source := paste0(pref1, 場所)]
  # } else {
    signateLink[i, source := paste0(pref1, `id1-2`)]
    signateLink[i, sourceLabel := paste(sep = '|', 
                                        paste0(pref1, '-',  `id1-2`),
                                        paste(
                                          unlist(
                                            signateDetail[罹患者id == signateLink[i]$罹患者id1, 
                                                             .(公表日, 年代, 性別, 職業, `症状・経過`, 行動歴, 情報源, status, 居住地, 濃厚接触者状況)
                                                             ]), collapse = '|')
                                        )]
  # }
  signateLink[i, target := paste0(pref2, `id2-2`)]
  signateLink[i, targetLabel := paste(sep = '|', 
                                      paste0(pref2, '-', `id2-2`),
                                      paste(
                                        unlist(
                                          signateDetail[罹患者id == signateLink[i]$罹患者id2, 
                                                           .(公表日, 年代, 性別, 職業, `症状・経過`, 行動歴, 情報源, status, 居住地, 濃厚接触者状況)
                                                           ]), collapse = '|')
  )]
}

signatePlace<- fread(paste0(DATA_PATH, 'SIGNATE COVID-2019 Dataset - 接触場所マスタ.csv'), header = T)
signatePlace[, mapPopup := paste0('<a href="', signatePlace$情報源,'">', signatePlace$接触場所, '</a>')]

# テーブル出力
fwrite(x = signateDetail, file = paste0(DATA_PATH, 'resultSignateDetail.csv'))
fwrite(x = signateLink, file = paste0(DATA_PATH, 'resultSignateLink.csv'))
fwrite(x = signatePlace, file = paste0(DATA_PATH, 'resultSignatePlace.csv'))

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
