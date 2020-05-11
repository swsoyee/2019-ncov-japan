library(jsonlite)
library(purrr)

lang <- jsonlite::read_json(paste0("www/lang/translation.json"))

data <- fread(file = paste0(DATA_PATH, "Generated/resultSummaryTable.ja.csv"), sep = "@", quote = F)

ja <- lang$translation %>% map_chr(1)
cn <- lang$translation %>% map_chr(2)
en <- lang$translation %>% map_chr(3)

prefVector <- c("北海道", "青森", "岩手", "宮城", "秋田", "山形", "福島",
                "茨城", "栃木", "群馬", "埼玉", "千葉", "東京", "神奈川", 
                "新潟", "富山", "石川", "福井", "山梨", "長野", "岐阜", 
                "静岡", "愛知", "三重", "滋賀", "京都", "大阪", "兵庫", 
                "奈良", "和歌山", "鳥取", "島根", "岡山", "広島", "山口",
                "徳島", "香川", "愛媛", "高知", "福岡", "佐賀", "長崎",
                "熊本", "大分", "宮崎", "鹿児島", "沖縄", "クルーズ船", "検疫職員", "チャーター便", "伊客船")
tooltip <- list(
  "cn" = list("新規" = "新增", "累計" = "累计", "名" = "人", "情報待ち陽性者" = "等待消息的阳性患者", "入院者" = "住院", "回復者" = "恢复", "回復" = "恢复", "死亡者" = "死亡"),
  "en" = list("新規" = "New ", "累計" = "Total ", "名" = "", "情報待ち陽性者" = "Positive (more information needed) ", "入院者" = "Hospitalized ", "回復者" = "Recovered ", "回復" = "Recovered ", "死亡者" = "Death ")
)

for (language in c("en", "cn")) {
  dt <- copy(data)
  for (i in unique(data$group)) {
    dt[group == i, group := eval(as.name(language))[which(i == ja)]]
  }
  for (i in prefVector) {
    dt$region <- gsub(i, eval(as.name(language))[which(i == ja)], dt$region)
  }
  for (i in seq(tooltip[[language]])) {
    dt$diff <- gsub(names(tooltip[[language]][i]), tooltip[[language]][i], dt$diff)
    dt$dischargeDiff <- gsub(names(tooltip[[language]][i]), tooltip[[language]][i], dt$dischargeDiff)
    dt$detailBullet <- gsub(names(tooltip[[language]][i]), tooltip[[language]][i], dt$detailBullet)
  }
  fwrite(x = dt, file = paste0(DATA_PATH, paste0("Generated/resultSummaryTable.", language, ".csv")), sep = "@", quote = F)
}
