library(data.table)

pref <- list("福岡県" = "Fukuoka")

signateDetail <- fread(paste0(DATA_PATH, "SIGNATE COVID-2019 Dataset - 罹患者.csv"), header = T)
positiveDetail <- signateDetail[受診都道府県 == names(pref)]


signateRelation <- fread(paste0(DATA_PATH, "/Signate/relation.csv"), header = T)
relationDt <- signateRelation[`都道府県症例番号1` %in% positiveDetail$都道府県症例番号 |
                                `都道府県症例番号2` %in% positiveDetail$都道府県症例番号]

baseSize <- 8
baseRation <- 0.7
yearList <- list(
  '非公表' = baseSize + baseRation * 0,
  '0 - 9' = baseSize + baseRation * 1,
  '10 - 19' = baseSize + baseRation * 2,
  '20 - 29' = baseSize + baseRation * 3,
  '30 - 39' = baseSize + baseRation * 4,
  '40 - 49' = baseSize + baseRation * 5,
  '50 - 59' = baseSize + baseRation * 6,
  '60 - 69' = baseSize + baseRation * 7,
  '70 - 79' = baseSize + baseRation * 8,
  '80 - 89' = baseSize + baseRation * 9,
  '80 - 89' = baseSize + baseRation * 10,
  '90 -' = baseSize + baseRation * 11
)
positiveDetail[, `:=` (label = paste(sep = "|", 都道府県症例番号, 公表日, 年代), 
                       symbol = ifelse(医療従事者ﾌﾗｸﾞ == 1, "diamond", "circle"),
                       size = sapply(年代, function(x) {yearList[match(x, names(yearList))][[1]]}))]

fwrite(x = positiveDetail, file = paste0(DATA_PATH, "Pref/", pref, "/nodes.csv"))
fwrite(x = relationDt, file = paste0(DATA_PATH, "Pref/", pref, "/edges.csv"))
