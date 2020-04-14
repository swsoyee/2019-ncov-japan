# ====PCR検査数の推移図データセット====
pcrData <- reactive({
  dt <-
    merge(x = domesticDailyReport,
          y = flightDailyReport,
          by = 'date',
          all.x = T)
  dt <-
    merge(
      x = dt,
      y = airportDailyReport,
      by = 'date',
      suffixes = '.y',
      all.x = T
    )
  dt <-
    merge(
      x = dt,
      y = shipDailyReport,
      by = 'date',
      all.x = T,
      suffixes = '.z'
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
  
  dt %>%
    e_chart(date) %>%
    e_line(
      pcr,
      name = '累計',
      itemStyle = list(color = lightYellow),
      areaStyle = list(opacity = 0.5)
    ) %>%
    e_bar(
      diff,
      name = '新規（日次）',
      y_index = 1,
      itemStyle = list(color = middleYellow)
    ) %>%
    e_x_axis(splitLine = list(lineStyle = list(opacity = 0.2))) %>%
    e_y_axis(
      name = '累積検査人数',
      nameGap = 10,
      nameTextStyle = list(padding = c(0, 0, 0, 80)),
      splitLine = list(lineStyle = list(opacity = 0.2)),
      axisLabel = list(inside = T),
      axisTick = list(show = F)
    ) %>%
    e_y_axis(
      name = '日次新規検査人数',
      nameGap = 10,
      splitLine = list(show = F),
      index = 1,
      axisTick = list(show = F)
    ) %>%
    e_grid(left = '3%',
           right = '15%',
           bottom = '10%') %>%
    e_legend(
      type = 'scroll',
      orient = 'vertical',
      left = '10%',
      top = '15%'
    ) %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = '日次新規・累積検査人の推移')
})
