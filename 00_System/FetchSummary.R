# # 更新部分 =====
# library(tabulizer)
# library(gtools)
# library(data.table)
# 
# dataset <- fread(file = "50_Data/MHLW/summary.csv")
# locationList <- fread(file = "50_Data/MHLW/summaryUrlList.csv")
# location <- as.list(locationList$link)
# names(location) <- locationList$date
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
#     # remove space
#     dt[, 都道府県名 := gsub(" ", "", 都道府県名)]
#     # remove notes
#     dt[, 都道府県名 := gsub(pattern = "※\\d", "", 都道府県名)]
#     cols <- colnames(dt)[2:ncol(dt)]
#     dt[, (cols) := lapply(.SD, function(x){return(gsub(",", "", x))}), .SDcols = cols]
#     suppressWarnings(dt[, (cols) := lapply(.SD, as.numeric), .SDcols = cols])
#     dt$temp <- rowSums(dt[, c(4, 6:ncol(dt)), with = F], na.rm = T)
#     dt[, 確認中 := 陽性者 - temp]
#     # 確認中はマイナスの場合、退院者から引く
#     dt[確認中 < 0, 退院者 := 退院者 + 確認中]
#     dt[確認中 < 0, 確認中 := 0]
#     dt <- cbind(data.table("日付" = rep(names(location[i]), nrow(dt))), dt, "分類" = 0)
#     dt[, temp := NULL]
#     # 空港、チャーター便、クルーズ船のデータ処理
#     other <- tail(dataset, n = 3)
#     suppressWarnings(other[, 日付 := as.character(names(location[i]))])
#     dataset <- suppressWarnings(gtools::smartbind(dataset, dt))
#     dataset <- rbind(dataset, other)
#   }
# }
# 
# fwrite(dataset, "50_Data/MHLW/summary.csv")
# source(file = "00_System/FetchData.R")
# source(file = "00_System/FetchVaccine.R")
