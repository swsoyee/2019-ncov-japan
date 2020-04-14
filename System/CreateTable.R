library(data.table)
library(sparkline)

# ====準備部分====
DATA_PATH <- 'Data/'
# 感染者ソーステーブルを取得
byDate <- fread(paste0(DATA_PATH, 'byDate.csv'), header = T)
byDate[is.na(byDate)] <- 0
byDate$date <- lapply(byDate[, 1], function(x){as.Date(as.character(x), format = '%Y%m%d')})
# 死亡データ
death <- fread(paste0(DATA_PATH, 'death.csv'))
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
provinceAttr[, `都道府県` := gsub('県', '', `都道府県`)]
provinceAttr[, `都道府県` := gsub('府', '', `都道府県`)]
provinceAttr[, `都道府県` := gsub('東京都', '東京', `都道府県`)]
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

print('新規なし継続日数カラム作成')
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
print('感染確認カラム作成')
total <- colSums(byDate[, 2:ncol(byDate)])
print('新規カラム作成')
today <- colSums(byDate[nrow(byDate), 2:ncol(byDate)])
print('昨日までカラム作成')
untilToday <- colSums(byDate[1:nrow(byDate) - 1, 2:ncol(byDate)])
print('新規推移カラム作成')
toolTipDate <- byDate[(nrow(byDate) - 15):nrow(byDate), 1, with = F][[1]]
diffSparkline <- sapply(2:ncol(byDate), function(i) {
  value <- byDate[(nrow(byDate) - 15):nrow(byDate), i, with = F][[1]]
  diff <- spk_chr(
    values = value,
    type = 'bar',
    barColor = middleRed,
    chartRangeMin = 0,
    tooltipFormat = '新規{{value}}名'
    # chartRangeMax = max(byDate[, c(2:48, 50)])
  )
  return(diff)
})

print('新規退院者カラム作成')
detailByRegion <- fread(paste0(DATA_PATH, 'detailByRegion.csv'))
detailByRegion[, `日付` := as.Date(as.character(`日付`), '%Y%m%d')]
detailByRegion[, `都道府県名` := gsub('県', '', `都道府県名`)]
detailByRegion[, `都道府県名` := gsub('府', '', `都道府県名`)]
detailByRegion[, `都道府県名` := gsub('東京都', '東京', `都道府県名`)]
detailByRegion[order(`日付`), dischargedDiff := `退院者` - shift(`退院者`), by = `都道府県名`]
detailByRegion[is.na(detailByRegion)] <- 0

print('退院推移')
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

print('死亡カラム作成')
deathByRegion <- stack(colSums(death[, 2:ncol(byDate)]))

print('感染者内訳')
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


print('テーブル作成')
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
print('テーブル出力')
fwrite(x = mergeDt, file = paste0(DATA_PATH, 'resultSummaryTable.csv'), sep = "@", quote = F)

# ====マップ用のデータ作成====
dt <- data.frame(date = byDate$date)
for(i in 2:ncol(byDate)) {
  dt[, i] = cumsum(byDate[, i, with = F])
}
dt <- reshape2::melt(dt, id.vars = 'date')
dt <- data.table(dt)
mapDt <- dt[!(variable %in% c('クルーズ船', 'チャーター便', '検疫職員'))]
# マップデータ用意
mapDt <- merge(x = mapDt, y = provinceCode, by.x = 'variable', by.y = 'name-ja', all = T)
# 必要なカラムを保存
mapDt <- mapDt[, .(date, variable, `name-en`, value, regions, lat, lng)]
# カラム名変更
colnames(mapDt) <- c('date', 'ja', 'en', 'count', 'regions', 'lat', 'lng')
fwrite(x = mapDt, file = paste0(DATA_PATH, 'result.map.csv'))
