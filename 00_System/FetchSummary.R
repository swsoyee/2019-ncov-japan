# library(gtools)
# library(data.table)
# 
# 統合部分 =====
# pcrByRegion <- fread(file = paste0(DATA_PATH, "MHLW/pcrByRegion.csv"))
# 
# detailByRegion <- fread(paste0(DATA_PATH, "detailByRegion.csv"))
# detailByRegion[, 都道府県名 := gsub("県|府", "", 都道府県名)]
# detailByRegion[, 都道府県名 := gsub("東京都", "東京", 都道府県名)]
# 
# detailByRegion[pcrByRegion, 検査人数 := i.検査人数, on = c(都道府県名 = "都道府県略称", 日付 = "日付")]
# detailByRegion$日付 <- as.character(detailByRegion$日付)
# names(detailByRegion) <- c("日付", "都道府県名", "陽性者", "入院中", "退院者", "死亡者", "検査人数")
# 
# location <- list("20200509" = "https://www.mhlw.go.jp/content/10906000/000628667.pdf")
# 
# out <- extract_tables(location[1][[1]], method = "lattice")
# 
# dt <- data.table(out[[1]])
# colnames(dt) <- c("都道府県名", "陽性者", "検査人数", "入院中", "重症者", "退院者", "死亡者")
# dt <- dt[3:(nrow(dt) - 1)]
# dt[grepl("その他", 都道府県名), 都道府県名 := "伊客船"]
# dt[, 都道府県名 := gsub(" ", "", 都道府県名)]
# cols <- colnames(dt)[2:ncol(dt)]
# dt[, (cols) := lapply(.SD, function(x){return(gsub(",", "", x))}), .SDcols = cols]
# suppressWarnings(dt[, (cols) := lapply(.SD, as.numeric), .SDcols = cols])
# dt$temp <- rowSums(dt[, c(4, 6:ncol(dt)), with = F], na.rm = T)
# dt[, 確認中 := 陽性者 - temp]
# 
# dt[, temp := NULL]
# dt <- cbind(data.table("日付" = rep(names(location[1]), nrow(dt))), dt)
# 
# dataset<- smartbind(detailByRegion, dt)
# dataset <- data.table(dataset)
# 
# # fwrite(dataset, file = "50_Data/MHLW/summary.csv")
# 
# airportDailyReport <- fread(paste0(DATA_PATH, "airportDailyReport.csv"))
# flightDailyReport <- fread(paste0(DATA_PATH, "flightDailyReport.csv"))
# shipDailyReport <- fread(paste0(DATA_PATH, "shipDailyReport.csv"))
# 
# ConvertDailyReport <- function(data, type) {
#   return(data[, .(
#     日付  = as.character(date),
#     都道府県名 = type,
#     陽性者  = positive,
#     入院中  = hospitalized, # hospitalize,
#     退院者  = discharge,
#     重症者  = severe,
#     死亡者  = death,
#     検査人数  = pcr,
#     確認中  = confirming
#   )])
# }
# 
# airport <- ConvertDailyReport(airportDailyReport, "空港検疫")
# flight <- ConvertDailyReport(flightDailyReport, "チャーター便")
# 
# ship <- shipDailyReport[, .(日付 = as.character(date),
#                       都道府県名 = "クルーズ船",
#                       陽性者  = positive,
#                       退院者  = discharge,
#                       重症者  = severe,
#                       死亡者  = death,
#                       検査人数  = pcr,
#                       確認中 = positive - discharge - severe - death - 40
#                       )]
# 
# dataset <- smartbind(dataset, airport, flight, ship)
# 
# provinceCode <- fread(paste0(DATA_PATH, "prefectures.csv"))
# code <- c(sprintf("%02d", provinceCode$id), 48:51)
# codeName <- c(provinceCode$`name-ja`, "伊客船", "空港検疫", "チャーター便", "クルーズ船")
# names(codeName) <- code
# 
# dataset$id <- names(codeName[match(dataset$都道府県名, codeName)])
# dataset <- data.table(dataset)
# dataset <- dataset[order(日付, id)]
# dataset <- dataset[,.(日付, 都道府県名, 陽性者, 検査人数, 入院中, 重症者, 退院者, 死亡者, 確認中)]
# fwrite(dataset, file = "50_Data/MHLW/summary.csv")
# dataset <- fread(file = "50_Data/MHLW/summary.csv")
# dataset[都道府県名 == "空港検疫", 分類 := 1]
# dataset[都道府県名 == "チャーター便", 分類 := 2]
# dataset[都道府県名 == "クルーズ船", 分類 := 3]
# dataset[is.na(分類), 分類 := 0]
# fwrite(dataset, file = "50_Data/MHLW/summary.csv")

# 更新部分 =====
# library(tabulizer)
# library(gtools)
# library(data.table)
# 
# dataset <- fread(file = "50_Data/MHLW/summary.csv")
# location <- list(
#   "20200509" = "https://www.mhlw.go.jp/content/10906000/000628667.pdf",
#   "20200510" = "https://www.mhlw.go.jp/content/10906000/000628697.pdf",
#   "20200511" = "https://www.mhlw.go.jp/content/10906000/000628917.pdf",
#   "20200512" = "https://www.mhlw.go.jp/content/10906000/000629544.pdf",
#   "20200513" = "https://www.mhlw.go.jp/content/10906000/000630162.pdf",
#   "20200514" = "https://www.mhlw.go.jp/content/10906000/000630534.pdf",
#   "20200515" = "https://www.mhlw.go.jp/content/10906000/000630924.pdf",
#   "20200516" = "https://www.mhlw.go.jp/content/10906000/000631063.pdf",
#   "20200517" = "https://www.mhlw.go.jp/content/10906000/000631149.pdf",
#   "20200518" = "https://www.mhlw.go.jp/content/10906000/000631428.pdf",
#   "20200519" = "https://www.mhlw.go.jp/content/10906000/000631887.pdf",
#   "20200520" = "https://www.mhlw.go.jp/content/10906000/000632211.pdf",
#   "20200521" = "https://www.mhlw.go.jp/content/10906000/000632553.pdf",
#   "20200522" = "https://www.mhlw.go.jp/content/10906000/000632894.pdf",
#   "20200523" = "https://www.mhlw.go.jp/content/10906000/000633030.pdf",
#   "20200524" = "https://www.mhlw.go.jp/content/10906000/000633053.pdf",
#   "20200525" = "https://www.mhlw.go.jp/content/10906000/000633317.pdf",
#   "20200526" = "https://www.mhlw.go.jp/content/10906000/000633684.pdf",
#   "20200527" = "https://www.mhlw.go.jp/content/10906000/000634251.pdf",
#   "20200528" = "https://www.mhlw.go.jp/content/10906000/000634785.pdf",
#   "20200529" = "https://www.mhlw.go.jp/content/10906000/000635194.pdf",
#   "20200530" = "https://www.mhlw.go.jp/content/10906000/000635510.pdf",
#   "20200531" = "https://www.mhlw.go.jp/content/10906000/000635537.pdf",
#   "20200601" = "https://www.mhlw.go.jp/content/10906000/000635775.pdf",
#   "20200602" = "https://www.mhlw.go.jp/content/10906000/000636131.pdf",
#   "20200603" = "https://www.mhlw.go.jp/content/10906000/000636580.pdf",
#   "20200604" = "https://www.mhlw.go.jp/content/10906000/000636974.pdf",
#   "20200605" = "https://www.mhlw.go.jp/content/10906000/000637373.pdf",
#   "20200606" = "https://www.mhlw.go.jp/content/10906000/000637517.pdf",
#   "20200607" = "https://www.mhlw.go.jp/content/10906000/000637546.pdf",
#   "20200608" = "https://www.mhlw.go.jp/content/10906000/000637898.pdf",
#   "20200609" = "https://www.mhlw.go.jp/content/10906000/000638331.pdf",
#   "20200610" = "https://www.mhlw.go.jp/content/10906000/000638689.pdf",
#   "20200611" = "https://www.mhlw.go.jp/content/10906000/000638963.pdf",
#   "20200612" = "https://www.mhlw.go.jp/content/10906000/000639340.pdf",
#   "20200613" = "https://www.mhlw.go.jp/content/10906000/000639746.pdf",
#   "20200614" = "https://www.mhlw.go.jp/content/10906000/000639768.pdf",
#   "20200615" = "https://www.mhlw.go.jp/content/10906000/000640012.pdf",
#   "20200616" = "https://www.mhlw.go.jp/content/10906000/000640391.pdf",
#   "20200617" = "https://www.mhlw.go.jp/content/10906000/000640744.pdf",
#   "20200618" = "https://www.mhlw.go.jp/content/10906000/000641279.pdf",
#   "20200619" = "https://www.mhlw.go.jp/content/10906000/000641749.pdf",
#   "20200620" = "https://www.mhlw.go.jp/content/10906000/000641953.pdf",
#   "20200621" = "https://www.mhlw.go.jp/content/10906000/000641965.pdf",
#   "20200622" = "https://www.mhlw.go.jp/content/10906000/000642110.pdf",
#   "20200623" = "https://www.mhlw.go.jp/content/10906000/000642429.pdf",
#   "20200624" = "https://www.mhlw.go.jp/content/10906000/000642770.pdf",
#   "20200625" = "https://www.mhlw.go.jp/content/10906000/000643524.pdf",
#   "20200626" = "https://www.mhlw.go.jp/content/10906000/000644137.pdf",
#   "20200627" = "https://www.mhlw.go.jp/content/10906000/000644324.pdf",
#   "20200628" = "https://www.mhlw.go.jp/content/10906000/000644366.pdf",
#   "20200629" = "https://www.mhlw.go.jp/content/10906000/000644581.pdf",
#   "20200630" = "https://www.mhlw.go.jp/content/10906000/000645008.pdf",
#   "20200701" = "https://www.mhlw.go.jp/content/10906000/000645319.pdf",
#   "20200702" = "https://www.mhlw.go.jp/content/10906000/000645664.pdf",
#   "20200703" = "https://www.mhlw.go.jp/content/10906000/000646191.pdf",
#   "20200704" = "https://www.mhlw.go.jp/content/10906000/000646571.pdf",
#   "20200705" = "https://www.mhlw.go.jp/content/10906000/000646607.pdf",
#   "20200706" = "https://www.mhlw.go.jp/content/10906000/000646810.pdf",
#   "20200707" = "https://www.mhlw.go.jp/content/10906000/000647060.pdf",
#   "20200708" = "https://www.mhlw.go.jp/content/10906000/000647417.pdf",
#   "20200709" = "https://www.mhlw.go.jp/content/10906000/000647788.pdf",
#   "20200710" = "https://www.mhlw.go.jp/content/10906000/000648105.pdf",
#   "20200711" = "https://www.mhlw.go.jp/content/10906000/000648217.pdf",
#   "20200712" = "https://www.mhlw.go.jp/content/10906000/000648243.pdf",
#   "20200713" = "https://www.mhlw.go.jp/content/10906000/000648451.pdf",
#   "20200714" = "https://www.mhlw.go.jp/content/10906000/000648880.pdf",
#   "20200715" = "https://www.mhlw.go.jp/content/10906000/000649241.pdf",
#   "20200716" = "https://www.mhlw.go.jp/content/10906000/000649591.pdf",
#   "20200717" = "https://www.mhlw.go.jp/content/10906000/000650036.pdf",
#   "20200718" = "https://www.mhlw.go.jp/content/10906000/000650224.pdf",
#   "20200719" = "https://www.mhlw.go.jp/content/10906000/000650237.pdf",
#   "20200720" = "https://www.mhlw.go.jp/content/10906000/000650553.pdf",
#   "20200721" = "https://www.mhlw.go.jp/content/10906000/000651137.pdf",
#   "20200722" = "https://www.mhlw.go.jp/content/10906000/000651653.pdf",
#   "20200723" = "https://www.mhlw.go.jp/content/10906000/000651930.pdf",
#   "20200724" = "https://www.mhlw.go.jp/content/10906000/000651992.pdf",
#   "20200725" = "https://www.mhlw.go.jp/content/10906000/000652019.pdf",
#   "20200726" = "https://www.mhlw.go.jp/content/10906000/000652038.pdf",
#   "20200727" = "https://www.mhlw.go.jp/content/10906000/000652356.pdf",
#   "20200728" = "https://www.mhlw.go.jp/content/10906000/000652732.pdf",
#   "20200729" = "https://www.mhlw.go.jp/content/10906000/000653369.pdf",
#   "20200730" = "https://www.mhlw.go.jp/content/10906000/000654091.pdf",
#   "20200731" = "https://www.mhlw.go.jp/content/10906000/000655123.pdf",
#   "20200801" = "https://www.mhlw.go.jp/content/10906000/000655356.pdf",
#   "20200802" = "https://www.mhlw.go.jp/content/10906000/000655374.pdf",
#   "20200803" = "https://www.mhlw.go.jp/content/10906000/000655729.pdf",
#   "20200804" = "https://www.mhlw.go.jp/content/10906000/000656116.pdf",
#   "20200805" = "https://www.mhlw.go.jp/content/10906000/000656951.pdf",
#   "20200806" = "https://www.mhlw.go.jp/content/10906000/000657338.pdf",
#   "20200807" = "https://www.mhlw.go.jp/content/10906000/000657779.pdf",
#   "20200808" = "https://www.mhlw.go.jp/content/10906000/000657896.pdf",
#   "20200809" = "https://www.mhlw.go.jp/content/10906000/000657918.pdf",
#   "20200810" = "https://www.mhlw.go.jp/content/10906000/000657932.pdf",
#   "20200811" = "https://www.mhlw.go.jp/content/10906000/000658223.pdf",
#   "20200812" = "https://www.mhlw.go.jp/content/10906000/000658575.pdf",
#   "20200813" = "https://www.mhlw.go.jp/content/10906000/000659103.pdf",
#   "20200814" = "https://www.mhlw.go.jp/content/10906000/000659316.pdf",
#   "20200815" = "https://www.mhlw.go.jp/content/10906000/000659499.pdf",
#   "20200816" = "https://www.mhlw.go.jp/content/10906000/000659513.pdf",
#   "20200817" = "https://www.mhlw.go.jp/content/10906000/000659782.pdf",
#   "20200818" = "https://www.mhlw.go.jp/content/10906000/000660161.pdf",
#   "20200819" = "https://www.mhlw.go.jp/content/10906000/000660643.pdf",
#   "20200820" = "https://www.mhlw.go.jp/content/10906000/000661109.pdf",
#   "20200821" = "https://www.mhlw.go.jp/content/10906000/000661604.pdf",
#   "20200822" = "https://www.mhlw.go.jp/content/10906000/000661892.pdf",
#   "20200823" = "https://www.mhlw.go.jp/content/10906000/000661903.pdf",
#   "20200824" = "https://www.mhlw.go.jp/content/10906000/000662166.pdf",
#   "20200825" = "https://www.mhlw.go.jp/content/10906000/000662629.pdf",
#   "20200826" = "https://www.mhlw.go.jp/content/10906000/000663401.pdf",
#   "20200827" = "https://www.mhlw.go.jp/content/10906000/000663890.pdf",
#   "20200828" = "https://www.mhlw.go.jp/content/10906000/000664559.pdf",
#   "20200829" = "https://www.mhlw.go.jp/content/10906000/000664884.pdf",
#   "20200830" = "https://www.mhlw.go.jp/content/10906000/000664898.pdf",
#   "20200831" = "https://www.mhlw.go.jp/content/10906000/000665403.pdf",
#   "20200901" = "https://www.mhlw.go.jp/content/10906000/000666237.pdf",
#   "20200902" = "https://www.mhlw.go.jp/content/10906000/000666718.pdf",
#   "20200903" = "https://www.mhlw.go.jp/content/10906000/000667719.pdf",
#   "20200904" = "https://www.mhlw.go.jp/content/10906000/000668100.pdf",
#   "20200905" = "https://www.mhlw.go.jp/content/10906000/000668309.pdf",
#   "20200906" = "https://www.mhlw.go.jp/content/10906000/000668338.pdf",
#   "20200907" = "https://www.mhlw.go.jp/content/10906000/000668579.pdf",
#   "20200908" = "https://www.mhlw.go.jp/content/10906000/000669043.pdf",
#   "20200909" = "https://www.mhlw.go.jp/content/10906000/000669634.pdf",
#   "20200910" = "https://www.mhlw.go.jp/content/10906000/000670165.pdf",
#   "20200911" = "https://www.mhlw.go.jp/content/10906000/000670663.pdf",
#   "20200912" = "https://www.mhlw.go.jp/content/10906000/000670936.pdf",
#   "20200913" = "https://www.mhlw.go.jp/content/10906000/000671385.pdf",
#   "20200914" = "https://www.mhlw.go.jp/content/10906000/000671889.pdf",
#   "20200915" = "https://www.mhlw.go.jp/content/10906000/000672486.pdf",
#   "20200916" = "https://www.mhlw.go.jp/content/10906000/000672911.pdf",
#   "20200917" = "https://www.mhlw.go.jp/content/10906000/000673389.pdf",
#   "20200918" = "https://www.mhlw.go.jp/content/10906000/000673976.pdf",
#   "20200919" = "https://www.mhlw.go.jp/content/10906000/000674178.pdf",
#   "20200920" = "https://www.mhlw.go.jp/content/10906000/000674196.pdf",
#   "20200921" = "https://www.mhlw.go.jp/content/10906000/000674225.pdf",
#   "20200922" = "https://www.mhlw.go.jp/content/10906000/000674437.pdf",
#   "20200923" = "https://www.mhlw.go.jp/content/10906000/000674736.pdf",
#   "20200924" = "https://www.mhlw.go.jp/content/10906000/000675158.pdf",
#   "20200925" = "https://www.mhlw.go.jp/content/10906000/000675878.pdf",
#   "20200926" = "https://www.mhlw.go.jp/content/10906000/000676311.pdf",
#   "20200927" = "https://www.mhlw.go.jp/content/10906000/000676331.pdf",
#   "20200928" = "https://www.mhlw.go.jp/content/10906000/000676580.pdf",
#   "20200929" = "https://www.mhlw.go.jp/content/10906000/000677146.pdf",
#   "20200930" = "https://www.mhlw.go.jp/content/10906000/000677754.pdf",
#   "20201001" = "https://www.mhlw.go.jp/content/10906000/000678194.pdf",
#   "20201002" = "https://www.mhlw.go.jp/content/10906000/000678803.pdf",
#   "20201003" = "https://www.mhlw.go.jp/content/10906000/000679295.pdf",
#   "20201004" = "https://www.mhlw.go.jp/content/10906000/000679319.pdf",
#   "20201005" = "https://www.mhlw.go.jp/content/10906000/000679488.pdf",
#   "20201006" = "https://www.mhlw.go.jp/content/10906000/000679932.pdf",
#   "20201007" = "https://www.mhlw.go.jp/content/10906000/000680529.pdf",
#   "20201008" = "https://www.mhlw.go.jp/content/10906000/000680671.pdf",
#   "20201009" = "https://www.mhlw.go.jp/content/10906000/000681170.pdf",
#   "20201010" = "https://www.mhlw.go.jp/content/10906000/000681517.pdf",
#   "20201011" = "https://www.mhlw.go.jp/content/10906000/000681654.pdf",
#   "20201012" = "https://www.mhlw.go.jp/content/10906000/000681717.pdf",
#   "20201013" = "https://www.mhlw.go.jp/content/10906000/000682295.pdf",
#   "20201014" = "https://www.mhlw.go.jp/content/10906000/000682777.pdf",
#   "20201015" = "https://www.mhlw.go.jp/content/10906000/000683213.pdf",
#   "20201016" = "https://www.mhlw.go.jp/content/10906000/000683797.pdf",
#   "20201017" = "https://www.mhlw.go.jp/content/10906000/000683945.pdf",
#   "20201018" = "https://www.mhlw.go.jp/content/10906000/000683987.pdf",
#   "20201019" = "https://www.mhlw.go.jp/content/10906000/000684350.pdf",
#   "20201020" = "https://www.mhlw.go.jp/content/10906000/000684985.pdf",
#   "20201021" = "https://www.mhlw.go.jp/content/10906000/000685495.pdf",
#   "20201022" = "https://www.mhlw.go.jp/content/10906000/000686102.pdf",
#   "20201023" = "https://www.mhlw.go.jp/content/10906000/000686678.pdf",
#   "20201024" = "https://www.mhlw.go.jp/content/10906000/000687050.pdf",
#   "20201025" = "https://www.mhlw.go.jp/content/10906000/000687078.pdf",
#   "20201026" = "https://www.mhlw.go.jp/content/10906000/000687548.pdf",
#   "20201027" = "https://www.mhlw.go.jp/content/10906000/000688479.pdf",
#   "20201028" = "https://www.mhlw.go.jp/content/10906000/000688887.pdf",
#   "20201029" = "https://www.mhlw.go.jp/content/10906000/000689594.pdf",
#   "20201030" = "https://www.mhlw.go.jp/content/10906000/000690151.pdf",
#   "20201031" = "https://www.mhlw.go.jp/content/10906000/000690441.pdf",
#   "20201101" = "https://www.mhlw.go.jp/content/10906000/000690453.pdf",
#   "20201102" = "https://www.mhlw.go.jp/content/10906000/000690720.pdf"
# )
# 
# for (i in names(location)) {
#   if (!i %in% dataset$日付) {
#     out <- tabulizer::extract_tables(location[i][[1]], method = "lattice")
# 
#     dt <- data.table(out[[ifelse(length(out) > 1, 2, 1)]])
#     # 沖縄処理
#     # dt[49] <- dt[49, c(1:3, 6:7, 10, 13, 4, 5, 8, 9, 11, 12)]
#     # dt[, `:=` (V8 = NULL, V9 = NULL, V10 = NULL, V11 = NULL, V12 = NULL, V13 = NULL)]
# 
#     colnames(dt) <- c("都道府県名", "陽性者", "検査人数", "入院中", "重症者", "退院者", "死亡者")
#     dt <- dt[3:(nrow(dt) - 1)]
#     dt[grepl("その他", 都道府県名), 都道府県名 := "伊客船"]
#     dt[, 都道府県名 := gsub(" ", "", 都道府県名)]
#     cols <- colnames(dt)[2:ncol(dt)]
#     dt[, (cols) := lapply(.SD, function(x){return(gsub(",", "", x))}), .SDcols = cols]
#     suppressWarnings(dt[, (cols) := lapply(.SD, as.numeric), .SDcols = cols])
#     dt$temp <- rowSums(dt[, c(4, 6:ncol(dt)), with = F], na.rm = T)
#     dt[, 確認中 := 陽性者 - temp]
#     dt <- cbind(data.table("日付" = rep(names(location[i]), nrow(dt))), dt, "分類" = 0)
#     dt[, temp := NULL]
#     dataset <- suppressWarnings(gtools::smartbind(dataset, dt))
#   }
# }
# 
# fwrite(dataset, "50_Data/MHLW/summary.csv")
