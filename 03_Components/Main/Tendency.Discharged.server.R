# ====退院推移図データセット====
dischargeData <- reactive({
  dt <- domesticDailyReport
  dt <- merge(x = domesticDailyReport, y = flightDailyReport, by = "date", all.x = T, suffixes = c(".d", ".f"))
  dt <- merge(x = dt, y = airportDailyReport, by = "date", all.x = T)
  dt <- merge(x = dt, y = shipDailyReport, by = "date", all.x = T)
  
  dataset <- domesticDailyReport
  
  dataset$positive <- rowSums(cbind(dataset$positive, dt$positive.x), na.rm = T)
  dataset$discharge <- rowSums(cbind(dataset$discharge, dt$discharge.x), na.rm = T)
  dataset$mild <- rowSums(cbind(dataset$mild, dt$mild), na.rm = T)
  dataset$severe <- rowSums(cbind(dataset$severe, dt$severe.x), na.rm = T)
  dataset$death <- rowSums(cbind(dataset$death, dt$death.x), na.rm = T)
  
  if (input$showFlightInDischarge) {
    dataset$positive <- dataset$positive + flightDailyReport$positive
    dataset$discharge <- dataset$discharge + flightDailyReport$discharge
    dataset$mild <- dataset$mild + flightDailyReport$mild
    dataset$severe <- dataset$severe + flightDailyReport$severe
    dataset$death <- dataset$death + flightDailyReport$death
  }
  if (input$showShipInDischarge) {
    ship <- shipDailyReport[2:nrow(shipDailyReport), ]
    setnafill(ship, fill = 0)
    dataset$positive <- dataset$positive + ship$positive
    dataset$discharge <- dataset$discharge + ship$discharge
    dataset$severe <- dataset$severe + ship$severe
    dataset$death <- dataset$death + ship$death
  }
  dataset
})

recoveredData <- reactive({
  dataset <- mhlwSummary[, .(陽性者 = sum(陽性者, na.rm = T), 
                                回復者 = sum(退院者, na.rm = T), 
                                重症者 = sum(重症者, na.rm = T), 
                                死亡者 = sum(死亡者, na.rm = T)), by = "日付"]
  dataset <- merge(dataset, confirmingData, all.x = T, by.x = "日付", by.y = "date")
  dataset[dailyReport, 重症者 := 重症者 + i.severe.d, on = c(日付 = "date")]
  dataset[, 回復突合中 := domesticDischarged - 回復者]
  # 訳わからないマイナスの値があるため、削除
  dataset[回復突合中 < 0, 回復突合中 := NA]
  dataset[, 死亡突合中 := domesticDeath - 死亡者]
  # 2020-05-09仕様変更
  dataset[日付 %in% as.Date(c("2020-05-09", "2020-04-22")), `:=` (回復突合中 = 0, 死亡突合中 = 0)]
  dataset
})

# ====退院推移図====
output$recoveredLine <- renderEcharts4r({
  # dt <- dataset
  dataset <- recoveredData()

  dataset %>%
    e_chart(日付) %>%
    e_line(
      陽性者,
      name = i18n$t("PCR検査陽性"),
      itemStyle = list(normal = list(color = lightRed)),
      areaStyle = list(opacity = 0.4), symbol = "circle", symbolSize = 1
    ) %>%
    e_line(
      死亡者,
      name = i18n$t("死亡"),
      stack = "1",
      itemStyle = list(normal = list(color = darkNavy)),
      areaStyle = list(opacity = 0.4), symbol = "circle", symbolSize = 1
    ) %>%
    e_line(
      死亡突合中,
      name = i18n$t("死亡（突合中）"),
      stack = "1",
      itemStyle = list(normal = list(color = darkNavy)),
      areaStyle = list(opacity = 0.4), symbol = "circle", symbolSize = 1
    ) %>%
    e_line(
      重症者,
      name = i18n$t("重症"),
      stack = "1",
      itemStyle = list(normal = list(color = darkRed)),
      areaStyle = list(opacity = 0.4), symbol = "circle", symbolSize = 1
    ) %>%
    e_line(
      回復者,
      name = i18n$t("回復"),
      stack = "1",
      itemStyle = list(normal = list(color = middleGreen)),
      areaStyle = list(opacity = 0.4), symbol = "circle", symbolSize = 1
    ) %>%
    e_line(
      回復突合中,
      name = i18n$t("回復（突合中）"),
      stack = "1",
      itemStyle = list(normal = list(color = middleGreen)),
      areaStyle = list(opacity = 0.4), symbol = "circle", symbolSize = 1
    ) %>%
    e_x_axis(splitLine = list(show = F), splitLine = list(lineStyle = list(opacity = 0.2))) %>%
    e_y_axis(
      splitLine = list(show = F),
      axisLabel = list(inside = T),
      splitLine = list(lineStyle = list(opacity = 0.2)),
      z = 999,
      axisTick = list(show = F)
    ) %>%
    e_y_axis(
      splitLine = list(show = F),
      index = 1,
      splitLine = list(lineStyle = list(opacity = 0.2)),
      z = 999,
      axisTick = list(show = F)
    ) %>%
    e_grid(left = "3%", bottom = "18%") %>%
    e_legend(
      type = "scroll",
      orient = "vertical",
      left = "18%",
      top = "15%",
      right = "15%"
    ) %>%
    e_title(i18n$t("回復・重症・死亡")) %>%
    e_tooltip(trigger = "axis") %>%
    e_datazoom(
      minValueSpan = 3600 * 24 * 1000 * 7,
      bottom = "0%",
      startValue = max(dataset$日付, na.rm = T) - 28
    )
})

# ====退院タブのサマリー====
# TODO 意味が大きくない、見ている人が少ない？
output$dischargeSummary <- renderUI({
  dt <- dischargeData()[nrow(dischargeData())]
  tagList(
    tags$ol(
    tags$li(i18n$t("令和2年4月22日から厚労省公開している退院者、死亡者数に突合作業中の人数が含まれていて、入退院等の状況の合計とPCR検査陽性者数は一致しないことが明らかにしました。"),
            tags$a(href = "https://www.mhlw.go.jp/stf/newpage_10989.html", icon("external-link"))),
    tags$li(i18n$t("令和2年5月9日公表分から、データソースを従来の厚生労働省が把握した個票を積み上げたものから、各自治体がウェブサイトで公表している数等を積み上げたものに変更した。"),
            tags$a(href = "https://www.mhlw.go.jp/stf/newpage_11229.html", icon("external-link")))
    )
  )
})


output$curedCalendar <- renderEcharts4r({
  dt <- data.table(
    "date" = domesticDailyReport$date,
    "discharge" = dischargeData()$discharge
  )
  dt[, diff := discharge - shift(discharge)]
  setnafill(dt, fill = 0)
  maxValue <- max(dt$diff)
  dt %>%
    e_charts(date) %>%
    e_calendar(
      range = c("2020-02-01", "2020-07-30"),
      top = 25,
      left = 25,
      cellSize = 15,
      splitLine = list(show = F),
      itemStyle = list(borderWidth = 2, borderColor = "#FFFFFF"),
      dayLabel = list(nameMap = switch(
        languageSetting,
        "ja" = c("日", "月", "火", "水", "木", "金", "土"),
        "cn" = "cn",
        "en" = "en"
      )),
      monthLabel = list(nameMap = ifelse(languageSetting != "en", "cn", "en"))
    ) %>%
    e_heatmap(diff, coord_system = "calendar", name = lang[[langCode]][80]) %>%
    e_legend(show = F) %>%
    e_visual_map(
      top = "15%",
      max = maxValue,
      show = F,
      inRange = list(color = c("#FFFFFF", darkGreen)),
      # scale colors
    ) %>%
    e_tooltip()
})

# TODO まだ実装されてない
output$todayCured <- renderUI({
  tagList(
    tags$b(i18n$t("本日新規")),
    dashboardLabel(lang[[langCode]][87], status = "success", style = "square")
  )
})
