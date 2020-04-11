# ====感染確認推移図====
output$confirmedLine <- renderEcharts4r({
  dt <- confirmedDataByDate()
  if(ncol(dt) > 1) {
    dt %>%
      e_charts(date) %>%
      e_line(
        total,
        name = '合計',
        itemStyle = list(normal = list(color = middleRed)),
        areaStyle = list(opacity = 0.4)
      ) %>%
      e_bar(
        difference,
        name = '新規感染者（日次）',
        y_index = 1,
        itemStyle = list(normal = list(color = middleRed)),
        areaStyle = list(opacity = 0.4)
      ) %>%
      e_grid(left = '3%') %>%
      e_x_axis(splitLine = list(show = F)) %>%
      e_y_axis(splitLine = list(show = F), axisLabel = list(inside = T), axisTick = list(show = F)) %>%
      e_y_axis(splitLine = list(show = F), 
               index = 1, 
               max = max(dt$difference, na.rm = T),
               axisTick = list(show = F)) %>%
      e_title(subtext = paste0(lang[[langCode]][62], UPDATE_DATETIME)) %>%
      e_legend(type = 'scroll', orient = 'vertical', left = '10%', top = '15%') %>%
      e_tooltip(trigger = 'axis')
  }
})

output$confirmedLineWrapper <- renderUI({
  if(is.null(input$regionPicker)) {
    tags$p('未選択です。地域を選択してください。')
  } else {
    echarts4rOutput('confirmedLine')
  }
})

confirmedDataByDate <- reactive({
  dt <- data.table(byDate)
  dt$都道府県 <- rowSums(byDate[, c(2:48)])
  if(!is.null(input$regionPicker)) {
    dt <- dt[, c('date', input$regionPicker), with = F]
    # dt <- dt[, c('date', '北海道', '東京', '神奈川')] # TEST
    dt$total <- cumsum(rowSums(dt[, 2:ncol(dt)]))
    dt[, difference := total - shift(total)]
    setnafill(dt, fill = 0)
    dt
  } else {
    dt[, 1, with = F] # 日付のカラムだけを返す
  }
})

# ====退院推移図データセット====
dischargeData <- reactive({
  dt <- domesticDailyReport
  dt <- merge(x = domesticDailyReport, y = flightDailyReport, by = 'date', all.x = T, suffixes = c('.d', '.f'))
  dt <- merge(x = dt, y = airportDailyReport, by = 'date', all.x = T)
  dt <- merge(x = dt, y = shipDailyReport, by = 'date', all.x = T)

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

# ====PCR検査数の推移図データセット====
pcrData <- reactive({
  dt <- domesticDailyReport
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
    ship <- shipDailyReport[2:nrow(shipDailyReport),]
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
    e_line(pcr, name = '累計', itemStyle = list(color = lightYellow), areaStyle = list(opacity = 0.5)) %>%
    e_bar(diff, name = '新規（日次）',  y_index = 1, itemStyle = list(color = middleYellow)) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), axisLabel = list(inside = T), axisTick = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), index = 1, axisTick = list(show = F)) %>%
    e_grid(left = '3%') %>%
    e_legend(type = 'scroll', orient = 'vertical', left = '10%', top = '15%') %>%
    e_tooltip(trigger = 'axis')
})
