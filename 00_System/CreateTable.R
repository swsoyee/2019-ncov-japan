library(data.table)
library(sparkline)

# ====準備部分====
source(file = "01_Settings/Path.R", local = T, encoding = "UTF-8")
# 感染者ソーステーブルを取得
byDate <- fread(paste0(DATA_PATH, "byDate.csv"), header = T)
byDate[is.na(byDate)] <- 0
byDate$date <- lapply(byDate[, 1], function(x) {
  as.Date(as.character(x), format = "%Y%m%d")
})
# 死亡データ
death <- fread(paste0(DATA_PATH, "death.csv"))
death[is.na(death)] <- 0
# 文言データを取得
lang <- fread(paste0(DATA_PATH, "lang.csv"))
langCode <- "ja"
# 都道府県
provinceCode <- fread(paste0(DATA_PATH, "prefectures.csv"))
provinceSelector <- provinceCode$id
names(provinceSelector) <- provinceCode$`name-ja`

provinceAttr <- fread(paste0(DATA_PATH, "Signate/prefMaster.csv"))
provinceAttr[, 都道府県略称 := 都道府県]
provinceAttr[, 都道府県略称 := gsub("県", "", 都道府県略称)]
provinceAttr[, 都道府県略称 := gsub("府", "", 都道府県略称)]
provinceAttr[, 都道府県略称 := gsub("東京都", "東京", 都道府県略称)]
# 色設定
lightRed <- "#F56954"
middleRed <- "#DD4B39"
darkRed <- "#B03C2D"
lightYellow <- "#F8BF76"
middleYellow <- "#F39C11"
darkYellow <- "#DB8B0A"
lightGreen <- "#00A65A"
middleGreen <- "#01A65A"
darkGreen <- "#088448"
superDarkGreen <- "#046938"
lightNavy <- "#5A6E82"
middelNavy <- "#001F3F"
darkNavy <- "#001934"
lightGrey <- "#F5F5F5"
lightBlue <- "#7BD6F5"
middleBlue <- "#00C0EF"
darkBlue <- "#00A7D0"


# ====各都道府県のサマリーテーブル====

print("新規なし継続日数カラム作成")
zeroContinuousDay <- stack(lapply(byDate[, 2:ncol(byDate)], function(region) {
  continuousDay <- 0
  for (x in region) {
    if (x == 0) {
      continuousDay <- continuousDay + 1
    } else {
      continuousDay <- 0
    }
  }
  return(continuousDay - 1)
}))
print("感染確認カラム作成")
total <- colSums(byDate[, 2:ncol(byDate)])
print("新規カラム作成")
today <- colSums(byDate[nrow(byDate), 2:ncol(byDate)])
print("昨日までカラム作成")
untilToday <- colSums(byDate[1:nrow(byDate) - 1, 2:ncol(byDate)])
print("感染者推移カラム作成")
dateSpan <- 21
diffSparkline <- sapply(2:ncol(byDate), function(i) {
  # 新規値
  value <- byDate[(nrow(byDate) - dateSpan):nrow(byDate), i, with = F][[1]]
  # 累計値
  cumsumValue <- c(cumsum(byDate[, i, with = F])[(nrow(byDate) - dateSpan):nrow(byDate)])[[1]]
  # 日付
  date <- byDate[(nrow(byDate) - dateSpan):nrow(byDate), 1, with = F][[1]]
  colorMapSetting <- rep("#E7ADA6", length(value))
  colorMapSetting[length(value)] <- darkRed
  namesSetting <- as.list(date)
  names(namesSetting) <- 0:(length(value) - 1)
  # 新規
  diff <- sparkline(
    values = value,
    type = "bar", 
    elementId = paste0("newCasesSparkline",i),
    chartRangeMin = 0,
    width = 80,
    tooltipFormat = "{{offset:names}}<br><span style='color: {{color}}'>&#9679;</span> 新規{{value}}名",
    tooltipValueLookups = list(
      names = namesSetting
    ),
    colorMap = colorMapSetting
  )
  # 累計
  cumsumSpk <- sparkline(
    values = cumsumValue,
    type = "line", 
    elementId = paste0("cumulativeCasesSparkline", i),
    width = 80,
    fillColor = F,
    lineColor = darkRed,
    tooltipFormat = "<span style='color: {{color}}'>&#9679;</span> 累計{{y}}名"
  )
  return(as.character(htmltools::as.tags(spk_composite(diff, cumsumSpk))))
})

print("新規回復者カラム作成")
mhlwSummary <- fread(file = "50_Data/MHLW/summary.csv")
mhlwSummary$日付 <- as.Date(as.character(mhlwSummary$日付), "%Y%m%d")
mhlwSummary[order(日付), dischargedDiff := 退院者 - shift(退院者), by = "都道府県名"]

print("回復推移")
dischargedDiffSparkline <- sapply(colnames(byDate)[2:48], function(region) {
  data <- mhlwSummary[`都道府県名` == region]
  # 新規
  span <- nrow(data) - dateSpan
  value <- data$dischargedDiff[ifelse(span < 0, 0, span):nrow(data)]
  # 日付
  date <- data$日付[ifelse(span < 0, 0, span):nrow(data)]
  namesSetting <- as.list(date)
  names(namesSetting) <- 0:(length(date) - 1)

  if (length(value) > 0) {
    diff <- spk_chr(
      values = value,
      type = "bar",
      elementId = paste0("recover", region),
      width = 80,
      barColor = middleGreen,
      tooltipFormat = "{{offset:names}}<br><span style='color: {{color}}'>&#9679;</span> 新規回復{{value}}名",
      tooltipValueLookups = list(
        names = namesSetting
      )
    )
  } else {
    diff <- NA
  }
  return(diff)
})

print("死亡カラム作成")
deathByRegion <- stack(colSums(death[, 2:ncol(byDate)]))

print("感染者内訳")
detailSparkLineDt <- mhlwSummary[日付 == max(日付)]
detailSparkLine <- sapply(detailSparkLineDt$都道府県名, function(region) {
  # 速報値との差分処理
  regionNew <- ifelse(region == "空港検疫", "検疫職員", region)
  confirmed <- ifelse(total[names(total) == regionNew][[1]] > detailSparkLineDt[都道府県名 == region, 陽性者],
    total[names(total) == regionNew][[1]],
    detailSparkLineDt[都道府県名 == region, 陽性者]
  )
  spk_chr(
    type = "pie",
    elementId = paste0("casesDetailPie", region),
    values = c(
      confirmed - sum(detailSparkLineDt[都道府県名 == region, .(入院中, 退院者, 死亡者)], na.rm = T) -
        ifelse(region == "クルーズ船", 40, 0),
      detailSparkLineDt[都道府県名 == region, 入院中],
      detailSparkLineDt[都道府県名 == region, 退院者],
      detailSparkLineDt[都道府県名 == region, 死亡者]
    ),
    sliceColors = c(middleRed, middleYellow, middleGreen, darkNavy),
    tooltipFormat = '<span style="color: {{color}}">&#9679;</span> {{offset:names}}<br>{{value}} 名 ({{percent.1}}%)',
    tooltipValueLookups = list(
      names = list(
        "0" = "情報待ち陽性者",
        "1" = "入院者",
        "2" = "回復者",
        "3" = "死亡者"
      )
    )
  )
})

print("二倍時間集計")
dt <- byDate[, 2:ncol(byDate)]
halfCount <- colSums(dt) / 2
dt <- cumsum(dt)
doubleTimeDay <- lapply(seq(halfCount), function(index) {
  prefDt <- dt[, index, with = F]
  nrow(prefDt[c(prefDt > halfCount[index])])
})
names(doubleTimeDay) <- names(dt)

# 回復者総数
totalDischarged <- mhlwSummary[日付 == max(日付), .(都道府県名, 退院者)]
colnames(totalDischarged) <- c("region", "totalDischarged")

print("都道府県別PCRデータ作成")
mhlwSummary[, 前日比 := 検査人数 - shift(検査人数), by = c("都道府県名")]
mhlwSummary[, 週間平均移動 := round(frollmean(前日比, 7), 0), by = c("都道府県名")]
mhlwSummary[, 陽性率 := round(陽性者 / 検査人数 * 100, 1)]
pcrByRegionToday <- mhlwSummary[日付 == max(日付)]
pcrDiffSparkline <- sapply(pcrByRegionToday$都道府県名, function(region) {
  data <- mhlwSummary[都道府県名 == region]
  # 新規
  span <- nrow(data) - dateSpan
  value <- data$前日比[ifelse(span < 0, 0, span):nrow(data)]
  # 日付
  date <- data$日付[ifelse(span < 0, 0, span):nrow(data)]
  namesSetting <- as.list(date)
  names(namesSetting) <- 0:(length(date) - 1)
  
  if (length(value) > 0) {
    diff <- spk_chr(
      values = value,
      type = "bar",
      elementId = paste0("pcrDetail", region),
      width = 80,
      barColor = middleYellow,
      tooltipFormat = "{{offset:names}}<br><span style='color: {{color}}'>&#9679;</span> 新規{{value}}",
      tooltipValueLookups = list(
        names = namesSetting
      )
    )
  } else {
    diff <- NA
  }
  return(diff)
})

positiveRatioSparkline <- sapply(pcrByRegionToday$都道府県名, function(region) {
  data <- mhlwSummary[都道府県名 == region]
  # 新規
  span <- nrow(data) - dateSpan
  value <- data$陽性率[ifelse(span < 0, 0, span):nrow(data)]
  # 日付
  date <- data$日付[ifelse(span < 0, 0, span):nrow(data)]
  namesSetting <- as.list(date)
  names(namesSetting) <- 0:(length(date) - 1)
  
  if (length(value) > 0) {
    diff <- spk_chr(
      values = value,
      type = "line", 
      elementId = paste0("positiveRatio", region),
      width = 80,
      lineColor = darkRed,
      fillColor = "#f2b3aa",
      tooltipFormat = "{{offset:names}}<br><span style='color: {{color}}'>&#9679;</span> 陽性率：{{y}}%",
      tooltipValueLookups = list(
        names = namesSetting
      )
    )
  } else {
    diff <- NA
  }
  return(diff)
})

pcrByRegionToday$検査数推移 <- pcrDiffSparkline
pcrByRegionToday$陽性率推移 <- positiveRatioSparkline

print("テーブル作成")
totalToday <- paste(sprintf("%06d", total), total, today, sep = "|")

mergeDt <- data.table(
  region = names(total),
  count = total,
  today = today,
  totalToday = totalToday,
  untilToday = untilToday,
  diff = diffSparkline,
  dischargeDiff = "",
  detailBullet = "",
  death = deathByRegion$values,
  zeroContinuousDay = zeroContinuousDay$values,
  doubleTimeDay = doubleTimeDay
)

mergeDt <- merge(mergeDt, totalDischarged, all.x = T, sort = F)
signateSub <- provinceAttr[, .(都道府県略称, 人口)]
colnames(signateSub) <- c("region", "population")
mergeDt <- merge(mergeDt, signateSub, all.x = T, sort = F)

source(file = "00_System/CreatePerMillion.R")
byDateConfirmed <- getLatestWeekValue(byDate)
latestOneWeekDiff <- (byDateConfirmed$today / (mergeDt$population / 100000)) - (byDateConfirmed$yesterday / (mergeDt$population / 100000))
latestOneWeekDiff <- lapply(latestOneWeekDiff, diff2Icon)

mergeDt[, perHundredThousand := paste0(
  sprintf("%02d", rank(round(byDateConfirmed$today / (population / 100000), 1), ties.method = "first")),
  "|",
  round(byDateConfirmed$today / (population / 100000), 1), 
  latestOneWeekDiff
  )]
mergeDt$perHundredThousand[48:51] <- "99|0 <i style='color:#001f3f;' class=\"fa fa-lock\"></i>"
mergeDt[, perMillionDeath := round(death / (population / 1000000), 0)]

for (i in mergeDt$region) {
  mergeDt[region == i]$dischargeDiff <- dischargedDiffSparkline[i][[1]]
  mergeDt[region == i]$detailBullet <- detailSparkLine[i][[1]]
}

# グルーピング
groupList <- list(
  "北海道・東北" = provinceAttr[都道府県コード %in% 1:7]$都道府県略称,
  "関東" = provinceAttr[都道府県コード %in% 8:14]$都道府県略称,
  "中部" = provinceAttr[都道府県コード %in% 15:23]$都道府県略称,
  "近畿" = provinceAttr[都道府県コード %in% 24:30]$都道府県略称,
  "中国" = provinceAttr[都道府県コード %in% 31:35]$都道府県略称,
  "四国" = provinceAttr[都道府県コード %in% 36:39]$都道府県略称,
  "九州・沖縄" = provinceAttr[都道府県コード %in% 40:47]$都道府県略称,
  "他" = colnames(byDate)[(ncol(byDate) - 3):ncol(byDate)]
)
mergeDt$group = ""
for (i in seq(nrow(mergeDt))) {
  mergeDt[i]$group <- names(which(lapply(groupList, function(x) { mergeDt$region[i] %in% x }) == T))
}

# Rt value
source(file = "00_System/CreateRtColumn.R")
mergeDt$Rt <- createRtColumn(byDate[1:(nrow(byDate)-1)])$display

pcrByRegionToday[, `:=` (dischargedDiff = NULL)]
mergeDt <- merge(mergeDt, pcrByRegionToday, by.x = "region", by.y = "都道府県名", all.x = T, no.dups = T, sort = F)
active <- mergeDt$陽性者 - mergeDt$退院者 - ifelse(is.na(mergeDt$死亡者), 0, mergeDt$死亡者)
mergeDt[, `:=` (日付 = NULL, 陽性者 = NULL, 入院中 = NULL, 退院者 = NULL, 死亡者 = NULL, 確認中 = NULL, 分類 = NULL)]
mergeDt[, 百万人あたり := round(検査人数 / (population / 1000000), 0)]
mergeDt[, population := NULL]

# 現在患者数
mergeDt$active <- active
mergeDt[active < 0, active := 0] # チャーター便の単独対応
mergeDt[region == "クルーズ船", active := active - 40] # クルーズ船の単独対応

# 13個特定警戒都道府県
alertPref <-
  c(
    # "東京",
    # "大阪",
    # "北海道",
    # "茨城",
    # "埼玉",
    # "千葉",
    # "神奈川",
    # "石川",
    # "岐阜",
    # "愛知",
    # "京都",
    # "三重",
    # "兵庫",
    # "福岡",
    # "沖縄"
  )

for(i in seq(nrow(mergeDt))) {
  if (mergeDt[i]$region %in% alertPref) {
    mergeDt[i]$region <- paste0("<i style='color:#DD4B39;' class=\"fa fa-exclamation-triangle\"></i>", "<span style='float:right;'>", mergeDt[i]$region, "</span>")
  } else if (mergeDt[i]$active == 0 && !is.na(mergeDt[i]$active)) {
    mergeDt[i]$region <- paste0("<i style='color:#01A65A;' class=\"fa fa-check-circle\"></i>", "<span style='float:right;'>", mergeDt[i]$region, "</span>")
  } else {
    mergeDt[i]$region <- paste0("<span style='float:right;'>", mergeDt[i]$region, "</span>")
  }
}

# 自治体名前ソート用
prefNameId <- sprintf('%02d', seq(2:ncol(byDate)))
mergeDt[, region := paste0(prefNameId, "|", region)]

# オーダー
# setorder(mergeDt, - count)
# 読み取り時のエラーを回避するため
mergeDt[, diff := gsub("\\n", "", diff)]
mergeDt[, dischargeDiff := gsub("\\n", "", dischargeDiff)]
mergeDt[, detailBullet := gsub("\\n", "", detailBullet)]
mergeDt[, 検査数推移 := gsub("\\n", "", 検査数推移)]
mergeDt[, 陽性率推移 := gsub("\\n", "", 陽性率推移)]
# クルーズ船とチャーター便データ除外
# mergeDt <- mergeDt[!grepl(pattern = paste0(lang[[langCode]][35:36], collapse = "|"), x = mergeDt$region)]

print("テーブル出力")
fwrite(x = mergeDt, file = paste0(DATA_PATH, "Generated/resultSummaryTable.ja.csv"), sep = "@", quote = F)
source(file = "00_System/CreateTable.Translate.R")

# ====マップ用のデータ作成====
dt <- data.frame(date = byDate$date)
for (i in 2:ncol(byDate)) {
  dt[, i] <- cumsum(byDate[, i, with = F])
}
dt <- reshape2::melt(dt, id.vars = "date")
dt <- data.table(dt)
mapDt <- dt[!(variable %in% c("クルーズ船", "伊客船", "チャーター便", "検疫職員"))]
# マップデータ用意
mapDt <- merge(x = mapDt, y = provinceCode, by.x = "variable", by.y = "name-ja", all = T)
mapDt <- merge(x = mapDt, y = provinceAttr, by.x = "variable", by.y = "都道府県略称", all = T)
# 必要なカラムを保存
mapDt <- mapDt[, .(date, variable, 都道府県, `name-en`, value, regions, lat, lng)]
# カラム名変更
colnames(mapDt) <- c("date", "ja", "full_ja", "en", "count", "regions", "lat", "lng")
fwrite(x = mapDt, file = paste0(DATA_PATH, "result.map.csv"))

# ====COVID DATA HUB====
source(file = "00_System/Generate.covid19datahub.R")

