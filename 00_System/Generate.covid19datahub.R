library(tidyverse)
library(lubridate)
library(jpndistrict)

# =====データ読み込み=====
df1 <- read_csv("50_Data/byDate.csv") %>% pivot_longer(-1, names_to = "name_ja", values_to = "new_cases")
df1[is.na(df1)] <- 0
df2 <- read_csv("50_Data/death.csv") %>% pivot_longer(-1, names_to = "name_ja", values_to = "new_deaths")
df2[is.na(df2)] <- 0
df3 <- read_csv("50_Data/MHLW/summary.csv")
df3$都道府県名[df3$都道府県名 == "空港検疫"] <- "検疫職員"
df4 <- read_csv("50_Data/result.map.csv")

# =====データ合併=====
data <- left_join(df1, df2, by = c("date", "name_ja"))
data <- left_join(data, df3, by = c("date" = "日付", "name_ja" = "都道府県名"))

# =====データ整形=====
# 英語の都道府県名を追加する
prefectures <- jpnprefs %>% mutate(name_ja = str_remove(prefecture, "県|都$|府"),
                                   name_en = str_remove(prefecture_en, "-.+")) %>%
  select(name_ja, name_en)
data <- left_join(data, prefectures, by = "name_ja")

# タイプを追加する
data <- data %>% mutate(type = ifelse(is.na(name_en), "other", "prefecture"))

# ほかの英語名を追加する
data$name_en[data$name_ja == "クルーズ船"] <- "Diamond Princess"
data$name_en[data$name_ja == "チャーター便"] <- "charter flights"
data$name_en[data$name_ja == "検疫職員"] <- "airport quarantine"
data$name_en[data$name_ja == "伊客船"] <- "Costa Atlantica"

# 変数名を英語にする
data <- data %>% mutate(date = ymd(date), tests = `検査人数`, recovered = `退院者`, hosp = `入院中`)

# 累計感染者数と累計死亡者数を計算する
data <- data %>% group_by(name_ja) %>%
  mutate(confirmed = cumsum(new_cases), deaths = cumsum(new_deaths))

# 「重症」は集中治療室（ICU）での治療を必要とする場合、もしくは人工呼吸器を装着する必要がある場合のことを指す
# https://news.yahoo.co.jp/articles/ed7c79007bf81fa5bd94c6e16a31b5ca055c7b4e
# data <- data %>% mutate(vent = `重症者`, icu = `重症者`)

data %>% select(date, tests, confirmed, deaths, recovered, hosp, name_ja, name_en, type) %>%
  write_csv("50_Data/covid19_jp.csv")

