# library(tabulizer)
# library(data.table)
# library(purrr)
# library(zoo)
# 
# dataPath <- "50_Data/MHLW/pcrByRegion.csv"
# 
# location <- list(
#   "20200324" = "https://www.mhlw.go.jp/content/10906000/000612050.pdf",
#   "20200325" = "https://www.mhlw.go.jp/content/10906000/000612830.pdf",
#   "20200326" = "https://www.mhlw.go.jp/content/10906000/000620398.pdf",
#   "20200327" = "https://www.mhlw.go.jp/content/10906000/000620404.pdf",
#   "20200328" = "https://www.mhlw.go.jp/content/10906000/000614804.pdf",
#   "20200329" = "https://www.mhlw.go.jp/content/10906000/000615054.pdf",
#   "20200330" = "https://www.mhlw.go.jp/content/10906000/000615919.pdf",
#   "20200331" = "https://www.mhlw.go.jp/content/10906000/000617079.pdf",
#   "20200401" = "https://www.mhlw.go.jp/content/10906000/000617889.pdf",
#   "20200402" = "https://www.mhlw.go.jp/content/10906000/000618483.pdf",
#   "20200403" = "https://www.mhlw.go.jp/content/10906000/000618767.pdf",
#   "20200404" = "https://www.mhlw.go.jp/content/10906000/000618981.pdf",
#   "20200405" = "https://www.mhlw.go.jp/content/10906000/000619077.pdf",
#   "20200406" = "https://www.mhlw.go.jp/content/10906000/000619392.pdf",
#   "20200407" = "https://www.mhlw.go.jp/content/10906000/000619755.pdf",
#   "20200408" = "https://www.mhlw.go.jp/content/10906000/000620190.pdf",
#   "20200409" = "https://www.mhlw.go.jp/content/10906000/000620474.pdf",
#   "20200410" = "https://www.mhlw.go.jp/content/10906000/000620964.pdf",
#   "20200411" = "https://www.mhlw.go.jp/content/10906000/000621071.pdf",
#   "20200412" = "https://www.mhlw.go.jp/content/10906000/000621113.pdf",
#   "20200413" = "https://www.mhlw.go.jp/content/10906000/000621415.pdf",
#   "20200414" = "https://www.mhlw.go.jp/content/10906000/000621710.pdf",
#   "20200415" = "https://www.mhlw.go.jp/content/10906000/000622037.pdf",
#   "20200416" = "https://www.mhlw.go.jp/content/10906000/000622366.pdf",
#   "20200417" = "https://www.mhlw.go.jp/content/10906000/000623178.pdf",
#   "20200418" = "https://www.mhlw.go.jp/content/10906000/000623174.pdf",
#   "20200419" = "https://www.mhlw.go.jp/content/10906000/000622872.pdf",
#   "20200420" = "https://www.mhlw.go.jp/content/10906000/000623123.pdf",
#   "20200421" = "https://www.mhlw.go.jp/content/10906000/000623705.pdf",
#   "20200422" = "https://www.mhlw.go.jp/content/10906000/000624007.pdf",
#   "20200423" = "https://www.mhlw.go.jp/content/10906000/000624611.pdf",
#   "20200424" = "https://www.mhlw.go.jp/content/10906000/000624956.pdf",
#   "20200425" = "https://www.mhlw.go.jp/content/10906000/000625188.pdf",
#   "20200426" = "https://www.mhlw.go.jp/content/10906000/000625317.pdf",
#   "20200427" = "https://www.mhlw.go.jp/content/10906000/000625630.pdf",
#   "20200428" = "https://www.mhlw.go.jp/content/10906000/000625952.pdf",
#   "20200429" = "https://www.mhlw.go.jp/content/10906000/000626144.pdf",
#   "20200430" = "https://www.mhlw.go.jp/content/10906000/000626511.pdf",
#   "20200501" = "https://www.mhlw.go.jp/content/10906000/000627218.pdf",
#   "20200502" = "https://www.mhlw.go.jp/content/10906000/000627445.pdf",
#   "20200503" = "https://www.mhlw.go.jp/content/10906000/000627492.pdf",
#   "20200504" = "https://www.mhlw.go.jp/content/10906000/000627546.pdf",
#   "20200505" = "https://www.mhlw.go.jp/content/10906000/000627546.pdf", # データなし
#   "20200506" = "https://www.mhlw.go.jp/content/10906000/000627645.pdf"
# )
# 
# result <- fread(file = dataPath)
# 
# for (i in seq(length(location))) {
#   if (!names(location[i]) %in% result$日付) {
#     out <- extract_tables(location[i][[1]], method = "stream")
# 
#     if (names(location[i]) %in% c("20200324", "20200325")) {
#       dt <- data.table(out[[3]])
#     } else {
#       dt <- data.table(out[[1]])
#     }
#     colnames(dt) <- unlist(dt[1])
#     dt <- dt[2:nrow(dt)]
# 
#     if (names(location[i]) <= "20200331") {
#       dt <- rbind(dt[, 1], dt[, 2])
#       dt[, c("都道府県名", "陽性者数", "検査人数", "備考") := tstrsplit(`都道府県名 陽性者数 検査人数 備考`, " ", fixed = TRUE)]
#     }
#     else if (names(location[i]) <= "20200403") {
#       dt <- rbind(dt[, 1:3], dt[, 5:7])
#       dt[, c("検査人数", "備考", "テスト") := tstrsplit(`検査人数 備考`, " ", fixed = TRUE)]
#     } else if (names(location[i]) <= "20200408") {
#       dt <- rbind(dt[, 1], dt[, 2])
#       dt[, c("都道府県名", "陽性者数", "検査人数", "備考") := tstrsplit(`都道府県名 陽性者数 検査人数 備考`, " ", fixed = TRUE)]
#     } else if (names(location[i]) == "20200409") {
#       dt <- rbind(dt[, 1], dt[, 4])
#       dt[, c("都道府県名", "陽性者数", "検査人数") := tstrsplit(`都道府県名 陽性者数 検査人数`, " ", fixed = TRUE)]
#     } else if (names(location[i]) < "20200414") {
#       dt <- rbind(dt[, 1:3], dt[, 6:8])
#     } else if (names(location[i]) == "20200414") {
#       dt <- rbind(dt[, 1], dt[, 4])
#       dt[, c("都道府県名", "陽性者数", "検査人数") := tstrsplit(`都道府県名 陽性者数 検査人数`, " ", fixed = TRUE)]
#     } else if (names(location[i]) > "20200414") {
#       dt <- rbind(dt[, 1:(ncol(dt) / 2)], dt[, (ncol(dt) / 2 + 1):ncol(dt)])
#       # 千葉、神奈川、大阪のデータ処理
#       dt[都道府県名 %in% c("(3/21~)", "(3/23~)"), 都道府県名 := NA]
#       dt[, 都道府県名 := na.locf(都道府県名)]
#       dt <- dt[`%` != "" & 都道府県名 != ""]
#       # 都道府県名処理
#       dt[, 都道府県名 := strsplit(都道府県名, " ") %>% map_chr(1)]
#       # 陽性者、検査人数処理
#       if ("陽性者数 検査人数" %in% colnames(dt)) {
#         dt[, c("陽性者数", "検査人数") := tstrsplit(`陽性者数 検査人数`, " ", fixed = TRUE)]
#       }
#       dt[, c("陽性者数", "検査人数") := lapply(.SD, function(x) {
#         as.numeric(gsub(pattern = "\\(|,|\\)", replacement = "", x))
#       }), .SDcols = c("陽性者数", "検査人数")]
#     }
# 
#     dt <- data.table(日付 = names(location[i]), 都道府県略称 = dt$都道府県名, 陽性者数 = dt$陽性者数, 検査人数 = dt$検査人数)
#     result <- rbind(result, dt)
#   }
# }
# 
# backup <- result
# 
# result[, 都道府県略称 := 都道府県略称]
# result[, 都道府県略称 := gsub("県", "", 都道府県略称)]
# result[, 都道府県略称 := gsub("府", "", 都道府県略称)]
# result[, 都道府県略称 := gsub("東京都", "東京", 都道府県略称)]
# 
# regionName <- unique(result$都道府県略称)[1:47]
# 
# result <- result[都道府県略称 %in% regionName]
# fwrite(x = result, file = dataPath)
