# ====感染確認推移図====
output$confirmedLine <- renderEcharts4r({
  dt <- confirmedDataByDate()

  e <- dt %>% 
    e_charts(date) %>%
    e_grid(left = '3%') %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), index = 0, axisLabel = list(inside = T)) %>%
    e_y_axis(splitLine = list(show = F), index = 1, axisLabel = list(inside = T)) %>%
    e_title(subtext = paste0(lang[[langCode]][62], UPDATE_DATETIME)) %>%
    # e_zoom() %>% e_datazoom() %>%
    e_legend(type = 'scroll', orient = 'vertical', left = '10%', top = '15%') %>%
    e_tooltip(trigger = 'axis') %>% e_theme("essos") %>% e_color(background = '#FFFFFF')

  for(i in input$regionPicker) {
    itemTotal <- paste0(i, '合計')
    itemNew <- paste0(i, '新規')
    assign(itemTotal, itemTotal)
    assign(i, i)
    e <- e %>%
      e_line_(itemTotal, name = itemTotal, stack = 'total', areaStyle = list(opacity = 0.4)) %>%
      e_bar_(i, name = paste0(i, '新規'), stack = 'new', y_index = 1, itemStyle = list(color = middleRed))
  }
  e
})

output$confirmedLineWrapper <- renderUI({
  if(is.null(input$regionPicker)) {
    tags$p('未選択です。地域を選択してください。')
  } else {
    echarts4rOutput('confirmedLine')
  }
})

confirmedDataByDate <- reactive({
  dt <- data.frame(byDate)
  dt$都道府県 <- rowSums(byDate[, c(2:48)])
  if(!is.null(input$regionPicker)) {
    dt <- dt[, c('date', input$regionPicker)]
    # dt <- dt[, 1:4] # TEST
    for (i in 2:ncol(dt)) {
      indexName <- colnames(dt)[i]
      dt[, paste0(colnames(dt)[i], '合計')] <- cumsum(dt[, i])
    }
    dt
  } else {
    dt[1] # 日付のカラムだけを返す
  }
})

# ====退院推移図データセット====
dischargeData <- reactive({
  dt <- domesticDailyReport
  dt <- merge(x = domesticDailyReport, y = flightDailyReport, by = 'date', all.x = T)
  dt <- merge(x = dt, y = shipDailyReport, by = 'date', all.x = T)
  dataset <- domesticDailyReport
  if (input$showFlightInDischarge) {
    dataset$positive <- dataset$positive + flightDailyReport$positive
    # dataset$symptomlessDischarge <- dataset$symptomlessDischarge + flightDailyReport$symptomlessDischarge
    # dataset$symptomDischarge <- dataset$symptomDischarge + flightDailyReport$symptomDischarge
    dataset$discharge <- dataset$discharge + flightDailyReport$discharge
    dataset$mild <- dataset$mild + flightDailyReport$mild
    dataset$severe <- dataset$severe + flightDailyReport$severe
    dataset$death <- dataset$death + flightDailyReport$death
  }
  if (input$showShipInDischarge) {
    ship <- shipDailyReport[2:nrow(shipDailyReport), ]
    setnafill(ship, fill = 0)
    dataset$positive <- dataset$positive + ship$positive
    # dataset$symptomlessDischarge <- dataset$symptomlessDischarge + ship$symptomlessDischarge
    # dataset$symptomDischarge <- dataset$symptomDischarge + ship$symptomDischarge
    dataset$discharge <- dataset$discharge + ship$discharge
    dataset$severe <- dataset$severe + ship$severe
    dataset$death <- dataset$death + ship$death
  }
  dataset
})

# ====退院タブのサマリー====
output$dischargeSummary <- renderUI({
  dt <- dischargeData()[nrow(dischargeData())]
  tagList(
    tags$b(dt$date, 'のサマリー'),
    tags$li('退院率：', round(dt$discharge / dt$positive * 100, 2), '%'),
    tags$li('重傷率：', round(dt$sever / dt$positive * 100, 2), '%'),
    tags$li('死亡率：', round(dt$death / dt$positive * 100, 2), '%'),
    tags$hr(),
  )
})

# ====退院推移図====
output$recoveredLine <- renderEcharts4r({
  # dt <- dataset
  dt <- dischargeData()
  defaultUnselected <- list(F, F, F)
  names(defaultUnselected) <-
    c('軽〜中等症の者', '重症者', '死亡者')
  dt %>%
    e_chart(date) %>%
    e_line(
      positive,
      name = 'PCR検査陽性者',
      itemStyle = list(normal = list(color = lightRed)),
      areaStyle = list(opacity = 0.4)
    ) %>%
    e_line(
      discharge,
      name = '退院者',
      stack = '1',
      itemStyle = list(normal = list(color = middleGreen)),
      areaStyle = list(opacity = 0.4)
    ) %>%
    e_line(
      mild,
      name = '軽〜中等症の者',
      stack = '1',
      itemStyle = list(normal = list(color = middleYellow)),
      areaStyle = list(opacity = 0.4)
    ) %>%
    e_line(
      severe,
      name = '重症者',
      stack = '1',
      itemStyle = list(normal = list(color = darkRed)),
      areaStyle = list(opacity = 0.4)
    ) %>%
    e_line(
      death,
      name = '死亡者',
      stack = '1',
      itemStyle = list(normal = list(color = darkNavy)),
      areaStyle = list(opacity = 0.4)
    ) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(
      splitLine = list(show = F),
      axisLabel = list(inside = T),
      axisTick = list(show = F)
    ) %>%
    e_grid(left = '3%') %>%
    e_legend(
      type = 'scroll',
      orient = 'vertical',
      left = '10%',
      top = '15%',
      selected = defaultUnselected
    ) %>%
    e_title(subtext = '厚生労働省が毎日１２時にまとめているデータを使用しているため、遅れがあります。') %>%
    e_tooltip(trigger = 'axis')
})

# ====PCR検査数の推移図データセット====
dischargeData <- reactive({
  dt <- domesticDailyReport
  dt <- merge(x = domesticDailyReport, y = flightDailyReport, by = 'date', all.x = T)
  dt <- merge(x = dt, y = shipDailyReport, by = 'date', all.x = T)
  dataset <- domesticDailyReport
  if (input$showFlightInPCR) {
    dataset$pcr <- dataset$pcr + flightDailyReport$pcr
  }
  if (input$showShipInPCR) {
    ship <- shipDailyReport[2:nrow(shipDailyReport), ]
    setnafill(ship, fill = 0)
    dataset$pcr <- dataset$pcr + ship$pcr
  }
  dataset
})

# ====PCR検査数====
output$pcrLine <- renderEcharts4r({
  dt <- dischargeData()
  
  dt[ , diff := pcr - shift(pcr)]
  setnafill(dt, fill = 0)
  
  dt %>%
    e_chart(date) %>%
    e_line(pcr, name = '累計', itemStyle = list(color = lightYellow), areaStyle = list(opacity = 0.5)) %>%
    e_bar(diff, name = '新規（日次）',  y_index = 1, itemStyle = list(color = middleYellow)) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), axisLabel = list(inside = T), axisTick = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), index = 1, axisTick = list(show = F)) %>%
    e_grid(left = '3%') %>%
    e_legend(type = 'scroll', orient = 'vertical', left = '10%', top = '15%') %>%
    e_tooltip(trigger = 'axis')
})
