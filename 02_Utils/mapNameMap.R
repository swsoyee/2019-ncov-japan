prefectureNameMapJa <- c(
  "北海道",
  "青森県",
  "岩手県",
  "宮城県",
  "秋田県",
  "山形県",
  "福島県",
  "茨城県",
  "栃木県",
  "群馬県",
  "埼玉県",
  "千葉県",
  "東京都",
  "神奈川県",
  "新潟県",
  "富山県",
  "石川県",
  "福井県",
  "山梨県",
  "長野県",
  "岐阜県",
  "静岡県",
  "愛知県",
  "三重県",
  "滋賀県",
  "京都府",
  "大阪府",
  "兵庫県",
  "奈良県",
  "和歌山県",
  "鳥取県",
  "島根県",
  "岡山県",
  "広島県",
  "山口県",
  "徳島県",
  "香川県",
  "愛媛県",
  "高知県",
  "福岡県",
  "佐賀県",
  "長崎県",
  "熊本県",
  "大分県",
  "宮崎県",
  "鹿児島県",
  "沖縄県",
  "チャーター便",
  "クルーズ船",
  "検疫職員",
  "伊客船"
)

prefectureNameMapCn <- c(
  "北海道",
  "青森县",
  "岩手县",
  "宫城县",
  "秋田县",
  "山形县",
  "福岛县",
  "茨城县",
  "枥木县",
  "群马县",
  "埼玉县",
  "千叶县",
  "东京都",
  "神奈川县",
  "新泻县",
  "富山县",
  "石川县",
  "福井县",
  "山梨县",
  "长野县",
  "岐阜县",
  "静冈县",
  "爱知县",
  "三重县",
  "滋贺县",
  "京都府",
  "大阪府",
  "兵库县",
  "奈良县",
  "和歌山县",
  "鸟取县",
  "岛根县",
  "冈山县",
  "广岛县",
  "山口县",
  "德岛县",
  "香川县",
  "爱媛县",
  "高知县",
  "福冈县",
  "佐贺县",
  "长崎县",
  "熊本县",
  "大分县",
  "宫崎县",
  "鹿儿岛县",
  "冲绳县",
  "撤侨包机",
  "公主号游轮",
  "检疫相关",
  "大西洋号游轮"
)

prefectureNameMapEn <- c(
  "Hokkaido",
  "Aomori",
  "Iwate",
  "Miyagi",
  "Akita",
  "Yamagata",
  "Fukushima",
  "Ibaraki",
  "Tochigi",
  "Gunma",
  "Saitama",
  "Chiba",
  "Tokyo",
  "Kanagawa",
  "Niigata",
  "Toyama",
  "Ishikawa",
  "Fukui",
  "Yamanashi",
  "Nagano",
  "Gifu",
  "Shizuoka",
  "Aichi",
  "Mie",
  "Shiga",
  "Kyoto",
  "Osaka",
  "Hyogo",
  "Nara",
  "Wakayama",
  "Tottori",
  "Shimane",
  "Okayama",
  "Hiroshima",
  "Yamaguchi",
  "Tokushima",
  "Kagawa",
  "Ehime",
  "Kochi",
  "Fukuoka",
  "Saga",
  "Nagasaki",
  "Kumamoto",
  "Oita",
  "Miyazaki",
  "Kagoshima",
  "Okinawa",
  "Air charter",
  "Cruise DP",
  "Quarantine",
  "Cruise CA"
)

prefectureNameMap <- list(
  "ja" = prefectureNameMapJa,
  "cn" = prefectureNameMapCn,
  "en" = prefectureNameMapEn
)

useMapNameMap <- function(target) {
  value <- as.list(prefectureNameMap[[target]])
  names(value) <- prefectureNameMap$ja
  return(value)
}

convertRegionName <- function(sourceName, targetLanguage, sourceLanguage = "ja") {
  return(prefectureNameMap[[targetLanguage]][match(sourceName, prefectureNameMap$ja)])
}

GenerateSelectProvinceOption <- function(data, column, languageSetting) {
  selectProvinceOption <- unique(data[[column]])
  selectProvinceOptionName <- sapply(selectProvinceOption, function(x){convertRegionName(x, languageSetting)})
  selectProvinceOption <- as.list(selectProvinceOption)
  names(selectProvinceOption) <- selectProvinceOptionName
  return(selectProvinceOption)
}

# TEST
# sourceName <- c("東京都", "北海道")
# convertRegionName(sourceName, targetLanguage = "en")
