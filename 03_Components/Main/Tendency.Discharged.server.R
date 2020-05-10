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
    tags$b(sprintf(i18n$t("%sのサマリー"), dt$date)),
    tags$li(i18n$t("退院率："), round(dt$discharge / dt$positive * 100, 2), "%"),
    tags$li(i18n$t("重傷率："), round(dt$sever / dt$positive * 100, 2), "%"),
    tags$li(i18n$t("死亡率："), round(dt$death / dt$positive * 100, 2), "%"),
    tags$small(i18n$t("※令和２年４月２２日から厚労省公開している退院者、死亡者数に突合作業中の人数が含まれていて、入退院等の状況の合計とPCR検査陽性者数は一致しないため、正しい分母がわからないのでこちらの計算はあくまでも参考程度にしてください。対処法考え＆調整中。")),
    tags$hr()
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

# ====退院者割合====
# TODO 意味なさそう、削除または改修予定
output$curedBar <- renderEcharts4r({
  dt <- data.table(
    "label" = "退院者",
    "domestic" = DISCHARGE_WITHIN$final,
    "flight" = DISCHARGE_FLIGHT$final,
    "airport" = DISCHARGE_AIRPORT$final,
    "ship" = DISCHARGE_SHIP$final,
    "domesticPer" = round(DISCHARGE_WITHIN$final / DISCHARGE_TOTAL * 100, 2),
    "flightPer" = round(DISCHARGE_FLIGHT$final / DISCHARGE_TOTAL * 100, 2),
    "airportPer" = round(DISCHARGE_AIRPORT$final / DISCHARGE_TOTAL * 100, 2),
    "shipPer" = round(DISCHARGE_SHIP$final / DISCHARGE_TOTAL * 100, 2)
  )
  e_charts(dt, label) %>%
    e_bar(domesticPer,
      name = i18n$t("国内事例"),
      stack = "1", itemStyle = list(color = lightGreen)
    ) %>%
    e_bar(airportPer,
      name = i18n$t("空港検疫"),
      stack = "1", itemStyle = list(color = middleGreen)
    ) %>%
    e_bar(flightPer,
      name = i18n$t("チャーター便"),
      stack = "1", itemStyle = list(color = darkGreen)
    ) %>%
    e_bar(shipPer,
      name = i18n$t("クルーズ船"),
      stack = "1", itemStyle = list(color = middleGreen)
    ) %>%
    e_y_axis(max = 100, splitLine = list(show = F), show = F) %>%
    e_x_axis(splitLine = list(show = F), show = F) %>%
    e_grid(left = "0%", right = "0%", top = "0%", bottom = "0%") %>%
    e_labels(position = "inside", formatter = htmlwidgets::JS('
      function(params) {
        if(params.value[0] > 10) {
          return(params.value[0] + "%")
        } else {
          return("")
        }
      }
    ')) %>%
    e_legend(show = F) %>%
    e_flip_coords() %>%
    e_tooltip(formatter = htmlwidgets::JS(paste0(
      '
      function(params) {
        return("<b>" + params.seriesName + "</b><br>" + Math.round(params.value[0] / 100 * ',
      DISCHARGE_TOTAL, ', 0) + " (" + params.value[0] + "%)")
      }
    '
    )))
})