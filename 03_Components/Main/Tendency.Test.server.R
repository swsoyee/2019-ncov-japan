# ====PCR検査数の推移図データセット====
pcrData <- reactive({
  dt <-
    merge(
      x = domesticDailyReport,
      y = flightDailyReport,
      by = "date",
      all.x = T
    )
  dt <-
    merge(
      x = dt,
      y = airportDailyReport,
      by = "date",
      suffixes = ".y",
      all.x = T
    )
  dt <-
    merge(
      x = dt,
      y = shipDailyReport,
      by = "date",
      all.x = T,
      suffixes = ".z"
    )
  dataset <- domesticDailyReport
  if (input$showFlightInPCR) {
    dataset$pcr <-
      rowSums(cbind(dt$pcr.x, dt$pcr.y, dt$pcr.z), na.rm = T)
  }
  if (input$showShipInPCR) {
    ship <- shipDailyReport[2:nrow(shipDailyReport), ]
    setnafill(ship, fill = 0)
    dataset$pcr <-
      rowSums(cbind(dt$pcr.x, dt$pcr.y, dt$pcr.z, dt$pcrNA), na.rm = T)
  }
  dataset[, diff := pcr - shift(pcr)]
  setnafill(dataset, fill = 0)
  dataset
})

# ====PCR検査数====
output$pcrLine <- renderEcharts4r({
  dt <- pcrData()
  dt$ma <- round(frollmean(dt$diff, n = input$testDaySpan, fill = 0), 2)
  dt %>%
    e_chart(date) %>%
    e_bar(
      pcr,
      name = "累積",
      itemStyle = list(color = lightYellow)
    ) %>%
    e_bar(
      diff,
      name = "新規",
      itemStyle = list(color = darkYellow),
      z = 2, barGap = "-100%"
    ) %>%
    e_line(ma, name = paste0(input$testDaySpan, "日移動平均（新規）"), y_index = 1, symbol = "none", smooth = T, itemStyle = list(color = darkRed)) %>%
    e_x_axis(splitLine = list(lineStyle = list(opacity = 0.2))) %>%
    e_y_axis(
      name = "検査人数",
      nameGap = 10,
      nameTextStyle = list(padding = c(0, 0, 0, 50)),
      splitLine = list(lineStyle = list(opacity = 0.2)),
      z = 999,
      axisLabel = list(inside = T),
      # min = -5000,
      axisTick = list(show = F)
    ) %>%
    e_y_axis(
      name = "移動平均新規数",
      nameGap = 10,
      splitLine = list(show = F),
      z = 999,
      index = 1,
      min = -250,
      axisTick = list(show = F)
    ) %>%
    e_grid(
      left = "3%",
      right = "15%",
      bottom = "18%"
    ) %>%
    e_legend(
      type = "scroll",
      orient = "vertical",
      left = "18%",
      top = "15%",
      right = "15%"
    ) %>%
    e_legend_unselect(
      name = "累積"
    ) %>%
    e_tooltip(trigger = "axis") %>%
    e_title(text = "日次新規・累積検査人数の推移") %>%
    e_datazoom(
      minValueSpan = 3600 * 24 * 1000 * 7,
      bottom = "0%",
      startValue = max(dt$date, na.rm = T) - 28
    )
})
