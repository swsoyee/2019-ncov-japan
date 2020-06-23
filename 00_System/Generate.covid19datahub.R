library(tidyverse)
library(lubridate)
library(jpndistrict)

# =====データ読み込み=====
# 都道府県別新規感染者数
df1 <- read_csv("50_Data/byDate.csv") %>% pivot_longer(-1, names_to = "name_ja", values_to = "new_cases")
df1[is.na(df1)] <- 0

# 都道府県別新規死亡者数
df2 <- read_csv("50_Data/death.csv") %>% pivot_longer(-1, names_to = "name_ja", values_to = "new_deaths")
df2[is.na(df2)] <- 0

# 都道府県別検査人数、入院中、重症者、退院者
df3 <- read_csv("50_Data/MHLW/summary.csv")
df3$都道府県名[df3$都道府県名 == "空港検疫"] <- "検疫職員"

# 都道府県別人口
df4 <- read_csv("50_Data/SIGNATE COVID-2019 Dataset - 都道府県マスタ.csv") %>%
  transmute(name_ja = str_remove(`都道府県`, "県|都$|府"), population = `人口`)

# =====データ合併=====
data <- left_join(df1, df2, by = c("date", "name_ja"))
data <- left_join(data, df3, by = c("date" = "日付", "name_ja" = "都道府県名"))
data <- left_join(data, df4, by = "name_ja")

# =====データ整形=====
# administrative_area_level変数を追加する
data$administrative_area_level <- 2
data$administrative_area_level_1 <- "Japan"

# 英語の都道府県名を追加する
prefectures <- jpnprefs %>% mutate(name_ja = str_remove(prefecture, "県|都$|府"),
                                   administrative_area_level_2 = str_remove(prefecture_en, "-.+")) %>%
  select(name_ja, administrative_area_level_2)
data <- left_join(data, prefectures, by = "name_ja")

# タイプを追加する
data <- data %>% mutate(type = ifelse(is.na(administrative_area_level_2), "other", "prefecture"))

# ほかの英語名を追加する
data$administrative_area_level_2[data$name_ja == "クルーズ船"] <- "Diamond Princess"
data$administrative_area_level_2[data$name_ja == "チャーター便"] <- "Charter Flight"
data$administrative_area_level_2[data$name_ja == "検疫職員"] <- "Quarantine"
data$administrative_area_level_2[data$name_ja == "伊客船"] <- "Costa Atlantica"

# 変数名を英語にする
# 「重症」は集中治療室（ICU）での治療を必要とする場合、もしくは人工呼吸器を装着する必要がある場合のことを指す
# https://news.yahoo.co.jp/articles/ed7c79007bf81fa5bd94c6e16a31b5ca055c7b4e
data <- data %>% mutate(date = ymd(date),
                        tests = `検査人数`,
                        recovered = `退院者`,
                        hosp = `入院中`,
                        vent = NA,
                        icu = NA,
                        severe = `重症者`)

# 累計感染者数と累計死亡者数を計算する
data <- data %>% group_by(administrative_area_level_2) %>%
  mutate(confirmed = cumsum(new_cases), deaths = cumsum(new_deaths)) %>%
  select(date, tests, confirmed, deaths, recovered, hosp, vent, icu, severe, population,
         administrative_area_level, administrative_area_level_1, administrative_area_level_2, type)

# 5月8日以前の国レベルデータを読み込む
data_national1 <- read_csv("50_Data/domesticDailyReport.csv") %>%
  transmute(date = ymd(date),
            tests = pcr,
            confirmed = positive,
            deaths = death,
            recovered = discharge,
            hosp = hospitalize,
            vent = NA,
            icu = NA,
            severe = severe,
            population = 126216142,
            administrative_area_level = 1,
            administrative_area_level_1 = "Japan",
            administrative_area_level_2 = "",
            type = "nation")

# 5月8日以前の全国感染者数を計算する
data_national2 <- data %>% ungroup() %>%
  filter(administrative_area_level_2 != "Diamond Princess" & date > ymd("2020-05-08")) %>%
  group_by(date) %>%
  transmute(date = date,
            tests = sum(tests, na.rm = TRUE),
            confirmed = sum(confirmed),
            deaths = sum(deaths, na.rm = TRUE),
            recovered = sum(recovered, na.rm = TRUE),
            hosp = sum(hosp, na.rm = TRUE),
            vent = NA,
            icu = NA,
            severe = sum(severe, na.rm = TRUE),
            population = sum(population, na.rm = TRUE),
            administrative_area_level = 1,
            administrative_area_level_1 = "Japan",
            administrative_area_level_2 = "",
            type = "nation") %>% distinct()

bind_rows(data_national1, data_national2, data) %>% write_csv("50_Data/covid19_jp.csv")
