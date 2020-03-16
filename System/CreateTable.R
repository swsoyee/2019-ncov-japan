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

total <- colSums(byDate[, 2:ncol(byDate)])
today <- colSums(byDate[nrow(byDate), 2:ncol(byDate)])
untilToday <- colSums(byDate[1:nrow(byDate) - 1, 2:ncol(byDate)])
total <- data.table(region = names(total), 
                    count = total, 
                    today = today, 
                    untilToday = untilToday)
total <- total[!(region %in% lang[[langCode]][35:36])]

diffSparkline <- sapply(c(2:48, 50), function(i) {
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
sparklineTable <- data.table(
  region = names(byDate)[c(2:48, 50)],
  diff = diffSparkline
)
mergeDt <- merge(x = total, y = sparklineTable, by = 'region', all = T)
deathByRegion <- stack(colSums(death[, c(2:48, 50)]))

mergeDt <- merge(x = mergeDt, y = deathByRegion, by.x = 'region', by.y = 'ind', all = T)
mergeDt <- merge(x = mergeDt, y = zeroContinuousDay, by.x = 'region', by.y = 'ind', all = T)
setorder(mergeDt, -count)
# 読み取り時のエラーを回避するため
mergeDt[, diff := gsub('\\n', '', diff)]
fwrite(x = mergeDt, file = paste0(DATA_PATH, 'resultSummaryTable.csv'), sep = "@", quote = F)

