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

positiveDetail <- positiveDetail[relationDt, 場所 := i.場所, on = c(都道府県症例番号 = "都道府県症例番号1")]

positiveDetail[, `:=` (label = paste(sep = "|", 都道府県症例番号, 公表日, 年代, 職業, 場所), 
                       symbol = ifelse(grepl(pattern = "医", 職業, fixed = T), "diamond", "circle"),
                       size = sapply(年代, function(x) {yearList[match(x, names(yearList))][[1]]}))]
positiveDetail$size[unlist(lapply(positiveDetail$size, is.null))] <- NA
positiveDetail$size <- unlist(positiveDetail$size)

fukuokaOffical <- fread(paste0(DATA_PATH, "Pref/", pref, "/patients.csv"))

fukuokaOffical[性別 == "男性", flag := "男性"]
fukuokaOffical[性別 == "女性", flag := "女性"]
# fukuokaOffical[感染経路不明 == 1, flag := "感染経路不明"]
# fukuokaOffical[is.na(flag), flag := "リンクあり"]
fukuokaOffical[感染経路不明 == 1, link := 1]

positiveDetail <- positiveDetail[fukuokaOffical, flag := i.flag, on = c(症例番号 = "No")]

fwrite(x = positiveDetail, file = paste0(DATA_PATH, "Pref/", pref, "/nodes.csv"))
fwrite(x = relationDt, file = paste0(DATA_PATH, "Pref/", pref, "/edges.csv"))

cutoffDate <- '2020/05/17'
positiveDetail <- positiveDetail[公表日 > cutoffDate]
fukuokaOffical <- fukuokaOffical[as.Date(公表_年月日) > as.Date(cutoffDate)]

e_charts() %>%
  e_graph(
    layout = "force",
    roam = T,
    draggable = T,
    symbolKeepAspect = T,
    focusNodeAdjacency = T
  ) %>%
  e_graph_nodes(
    nodes = positiveDetail,
    names = 都道府県症例番号,
    value = label,
    size = size,
    symbol = symbol,
    category = flag
  ) %>%
  e_graph_edges(
    relationDt,
    source = 都道府県症例番号1,
    target = 都道府県症例番号2
  ) %>%
  e_tooltip(formatter = htmlwidgets::JS("
    function(params) {
      const text = params.value.split('|')
      return(`
        番号：${text[0]}<br>
        公表日：${text[1]}<br>
        年代：${text[2]}<br>
        職業：${text[3]}<br>
        場所：${text[4]}
      `)
    }
  ")) %>%
  e_labels(
    formatter = htmlwidgets::JS(paste0("
    function(params) {
      const text = params.value.split('|')
      const id = text[0].split('-')[1]
      if(Date.parse(text[1]) >= Date.parse('", (Sys.Date() - 7), "')) {
        return(`{oneWeek|${id}}`)
      } else if(Date.parse(text[1]) >= Date.parse('", (Sys.Date() - 14), "')) {
        return(`{twoWeek|${id}}`)
      } else if(Date.parse(text[1]) >= Date.parse('", (Sys.Date() - 21), "')) {
        return(`{threeWeek|${id}}`)
      } else {
        return('')
      }
    }
  ")),
    rich = list(
      oneWeek = list(
        borderColor = "auto",
        color = "black",
        backgroundColor = "white",
        borderWidth = 4,
        borderRadius = 2,
        padding = 3,
        fontSize = 8
      ),
      twoWeek = list(
        borderColor = "auto",
        color = "black",
        backgroundColor = "white",
        borderWidth = 2,
        borderRadius = 2,
        padding = 3,
        fontSize = 8
      ),
      threeWeek = list(
        borderColor = "auto",
        color = "black",
        backgroundColor = "white",
        borderWidth = 0.5,
        borderRadius = 2,
        padding = 3,
        fontSize = 8
      )
    )
  ) %>%
  e_title(
    text = "福岡県のクラスターネットワーク",
    subtext = sprintf(
      "公表日：%s - %s\n感染経路不明率：%s%%",
      min(positiveDetail$公表日),
      max(positiveDetail$公表日),
      round(sum(fukuokaOffical$link, na.rm = T)/ nrow(fukuokaOffical) * 100, 2)
    )
  ) %>% 
  # e_theme_custom('{"color":["#304554", "#C23532"]}')
  e_theme_custom('{"color":["#C23532", "#304554"]}')
  # e_theme_custom('{"color":["#F5CA09", "#585E5D"]}')
