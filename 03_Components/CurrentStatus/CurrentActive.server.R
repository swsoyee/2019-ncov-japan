output$currentActive <- renderEcharts4r({
  dt <- simpleMapDataset()
  # 本日増加分
  todayTotalIncreaseNumber <- sum(dt$diff, na.rm = T)
  subText <- i18n$t("各都道府県からの新規報告なし")
  if (todayTotalIncreaseNumber > 0) {
    subText <- paste0(
      sprintf(
        i18n$t("発表がある%s都道府県合計新規%s人, 合計%s人\n\n"),
        sum(dt$diff > 0), todayTotalIncreaseNumber, sum(dt$count.x, na.rm = T)
      ),
      i18n$t("※こちらの合計値には空港検疫、チャーター便、\n　クルーズ関連の事例などは含まれていない。")
    )
  }

  dt[, translatedRegionName := convertRegionName(full_ja, languageSetting)]

  visualMapColorScheme <- c(
    "#DADADA",
    "#FFCEAB",
    "#FF9D57",
    "#FF781E",
    "#EA5432",
    "#C02B11",
    "#8C0B00",
    "#000000"
  )

  map <- dt %>%
    e_charts(translatedRegionName) %>%
    e_map_register("japan", japanMap) %>%
    e_map_("active",
      map = "japan",
      name = "感染確認数",
      nameMap = useMapNameMap(languageSetting),
      layoutSize = "50%",
      center = c(137.1374062, 36.8951298),
      zoom = 1.5,
      itemStyle = list(
        borderWidth = 0.2,
        borderColor = "white"
      ),
      emphasis = list(
        label = list(
          fontSize = 8
        )
      ),
      roam = "move"
    ) %>%
    e_visual_map_(
      "active",
      top = "25%",
      left = "0%",
      inRange = list(
        color = visualMapColorScheme
      ),
      type = "piecewise",
      splitList = list(
        list(min = 5000),
        list(min = 1000, max = 5000),
        list(min = 500, max = 1000),
        list(min = 100, max = 500),
        list(min = 50, max = 100),
        list(min = 10, max = 50),
        list(min = 1, max = 10),
        list(value = 0)
      )
    ) %>%
    e_mark_point(serie = dt[diff > 0]$en) %>%
    e_tooltip(formatter = htmlwidgets::JS(paste0(
      "
      function(params) {
        if(params.value) {
          return(`${params.name}<br>",
      i18n$t("現在感染者数："),
      '${params.value}`)
        } else {
          return("");
        }
      }
    '
    ))) %>%
    e_title(
      text = i18n$t("リアルタイム感染者数マップ"),
      subtext = subText
    )

  # 本日増加分をプロット
  # if (input$selectMapBottomButton %in% c("total", "active")) {
  newToday <- dt[diff > 0]
  for (i in 1:nrow(newToday)) {
    map <- map %>%
      e_mark_point(
        data = list(
          name = newToday[i]$ja,
          coord = c(newToday[i]$lng, newToday[i]$lat),
          symbolSize = c(6, newToday[i]$diff / 2)
        ),
        symbol = "triangle",
        slient = TRUE,
        symbolOffset = c(0, "-50%"),
        itemStyle = list(
          color = "#520e05",
          shadowColor = "white",
          shadowBlur = 0,
          opacity = 0.75
        )
      )
    # }
  }
  map
})
