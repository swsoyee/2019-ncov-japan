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
mergeDt <- data.table(region = names(total), 
                      count = total, 
                      today = today, 
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

