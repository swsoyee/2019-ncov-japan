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
domesticDailyReport$discharge <- domesticDailyReport$symptomDischarge + domesticDailyReport$symptomlessDischarge
setnafill(domesticDailyReport, type = 'locf')
# チャーター便の日報
flightDailyReport <- fread(paste0(DATA_PATH, 'flightDailyReport.csv'))
flightDailyReport$date <- as.Date(as.character(flightDailyReport$date), '%Y%m%d')
flightDailyReport$discharge <- flightDailyReport$symptomDischarge + flightDailyReport$symptomlessDischarge
setnafill(flightDailyReport, type = 'locf')
# クルーズ船の日報
shipDailyReport <- fread(paste0(DATA_PATH, 'shipDailyReport.csv'))
shipDailyReport$date <- as.Date(as.character(shipDailyReport$date), '%Y%m%d')
setnafill(shipDailyReport, type = 'locf')
# コールセンター
callCenterDailyReport <- fread(paste0(DATA_PATH, 'callCenter.csv'))
callCenterDailyReport$date <- as.Date(as.character(callCenterDailyReport$date), '%Y%m%d')
# 文言データを取得
lang <- fread(paste0(DATA_PATH, 'lang.csv'))
langCode <- 'ja'
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
    barColor = darkRed,
    chartRangeMin = 0,
    chartRangeMax = max(byDate[, c(2:48, 50)])
  )
  return(diff)
})
# 死亡カラム作成
deathByRegion <- stack(colSums(death[, 2:ncol(byDate)]))
# テーブル作成

totalToday <- paste0(total, '<r ', today, '<r >')

mergeDt <- data.table(region = names(total), 
                      count = total, 
                      today = today, 
                      totalToday = totalToday,
                      untilToday = untilToday,
                      diff = diffSparkline,
                      death = deathByRegion$values,
                      zeroContinuousDay = zeroContinuousDay$values
                      )
# オーダー
setorder(mergeDt, -count)
# 読み取り時のエラーを回避するため
mergeDt[, diff := gsub('\\n', '', diff)]
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
  data <- data.table('source' = character(0), 'target' = character(0), 'value' = numeric(0))
  label.pcr <- paste0('PCR検査陽性者\n100.00%')
  label.symptomless <- paste0('無症状者\n', round(latestRecord$symptomless / latestRecord$positive * 100, 2), '%')
  label.symptom <- paste0('有症状者\n', round(latestRecord$symptom / latestRecord$positive * 100, 2), '%')
  label.hospitalized <- paste0('入院治療を要する者\n', 
                               round(
                                 (latestRecord$symptomlesshospitalized + latestRecord$symptomHospitalized) / 
                                   (latestRecord$positive) * 100, 2), '%')
  label.discharge <- paste0('退院した者\n', 
                            round(
                              (latestRecord$symptomlessDischarge + latestRecord$symptomDischarge) / 
                                (latestRecord$positive) * 100, 2), '%')
  label.hospitalizedNow <- paste0('無症状入院中の者\n', 
                                  round(
                                    latestRecord$symptomlesshospitalizedNow / 
                                      latestRecord$positive * 100, 2), '%')
  label.waiting <- paste0('入院待機中の者\n',
                          round(
                            (latestRecord$symptomlesshospitalizedWaiting + latestRecord$waiting) / 
                              (latestRecord$positive) * 100, 2), '%')
  label.mild <- paste0('軽〜中等症の者\n',
                       round(
                         (latestRecord$mild) / 
                           (latestRecord$positive) * 100, 2), '%')
  label.severe <- paste0('人工呼吸又は\nICUに入院している者\n',
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
                                      (latestRecord$symtomConfirming) / 
                                        (latestRecord$positive) * 100, 2), '%')
  
  data <- rbind(data, list(label.pcr, label.symptomless, latestRecord$symptomless))
  data <- rbind(data, list(label.symptomless, label.discharge, latestRecord$symptomlessDischarge))
  data <- rbind(data, list(label.symptomless, label.hospitalized, latestRecord$symptomlesshospitalized))
  data <- rbind(data, list(label.hospitalized, label.hospitalizedNow, latestRecord$symptomlesshospitalizedNow))
  data <- rbind(data, list(label.hospitalized, label.waiting, latestRecord$symptomlesshospitalizedWaiting))
  data <- rbind(data, list(label.pcr, label.symptom, latestRecord$symptom))
  data <- rbind(data, list(label.symptom, label.discharge, latestRecord$symptomDischarge))
  data <- rbind(data, list(label.symptom, label.hospitalized, latestRecord$symptomHospitalized))
  data <- rbind(data, list(label.hospitalized, label.mild, latestRecord$mild))
  data <- rbind(data, list(label.hospitalized, label.severe, latestRecord$severe))
  data <- rbind(data, list(label.hospitalized, label.confirming, latestRecord$confirming))
  data <- rbind(data, list(label.hospitalized, label.waiting, latestRecord$waiting))
  data <- rbind(data, list(label.symptom, label.death, latestRecord$death))
  data <- rbind(data, list(label.pcr, label.symptomConfirming, latestRecord$symtomConfirming))
  data <- cbind(date = latestRecord$date, data)
  
  processData <- rbind(processData, data)
}
# テーブル出力
fwrite(x = processData, file = paste0(DATA_PATH, 'resultProcessData.csv'))
