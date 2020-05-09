# library(gtools)
# library(data.table)
# 
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
# fwrite(dataset, file = "50_Data/MHLW/summary.csv")
