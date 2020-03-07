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

# ====退院推移図（国内）====
output$recoveredLine <- renderEcharts4r({
  defaultUnselected <- list(F, F, F)
  names(defaultUnselected) <- c('軽〜中等症の者', '人工呼吸又はICUに入院している者', '死亡者')
  domesticDailyReport %>%
    e_chart(date) %>%
    e_line(positive, name = 'PCR検査陽性者', itemStyle = list(normal = list(color = lightRed)), areaStyle = list(opacity = 0.4)) %>%
    e_line(symptomlessDischarge, name = '無症状退院者', stack = '1', itemStyle = list(normal = list(color = middleGreen)), areaStyle = list(opacity = 0.4)) %>%
    e_line(symptomDischarge, name = '有症状退院者', stack = '1', itemStyle = list(normal = list(color = middleGreen)), areaStyle = list(opacity = 0.4)) %>%
    e_line(mild, name = '軽〜中等症の者', stack = '1', itemStyle = list(normal = list(color = middleYellow)), areaStyle = list(opacity = 0.4)) %>%
    e_line(severe, name = '人工呼吸又はICUに入院している者', stack = '1', itemStyle = list(normal = list(color = darkRed)), areaStyle = list(opacity = 0.4)) %>%
    e_line(death, name = '死亡者', stack = '1', itemStyle = list(normal = list(color = darkNavy)), areaStyle = list(opacity = 0.4)) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), axisLabel = list(inside = T), axisTick = list(show = F)) %>%
    e_grid(left = '3%') %>%
    e_legend(type = 'scroll', orient = 'vertical', left = '10%', top = '15%', selected = defaultUnselected) %>%
    e_title(subtext = '厚生労働省が毎日１２時にまとめているデータを使用しています（チャーター便除く）。') %>%
    e_tooltip(trigger = 'axis')
})

# ====PCR検査数====
output$pcrLine <- renderEcharts4r({
  dm <- domesticDailyReport[, .(date, pcr)]
  fl <- flightDailyReport[, .(date, pcr)]
  sp <- shipDailyReport[, .(date, pcr)]
  
  dt <- merge(x = dm, y = fl, by = 'date', all.x = T)
  dt <- merge(x = dt, y = sp, by = 'date', all.y = T)
  
  dt[ , diffDomestic := pcr.x - shift(pcr.x)]
  dt[ , diffFlight := pcr.y - shift(pcr.y)]
  dt[ , diffShip := pcr - shift(pcr)]
  setnafill(dt, fill = 0)
  
  dt %>%
    e_chart(date) %>%
    e_line(pcr, name = 'クルーズ船', stack = '1', itemStyle = list(color = darkYellow), areaStyle = list(opacity = 0.4)) %>%
    e_line(pcr.y, name = 'チャーター便', stack = '1', itemStyle = list(color = middleYellow), areaStyle = list(opacity = 0.4)) %>%
    e_line(pcr.x, name = '国内', stack = '1', itemStyle = list(color = lightYellow), areaStyle = list(opacity = 0.4)) %>%
    e_bar(diffDomestic, name = '国内新規', stack = '2', y_index = 1, itemStyle = list(color = middleYellow)) %>%
    e_bar(diffFlight, name = 'チャーター便新規', stack = '2', y_index = 1, itemStyle = list(color = middleYellow)) %>%
    e_bar(diffShip, name = 'クルーズ船新規', stack = '2', y_index = 1, itemStyle = list(color = middleYellow)) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), axisLabel = list(inside = T)) %>%
    e_title(subtext = 'PCR検査実施人数については複数の検体・検査を重複してカウントしている\n自治体からの報告は合計に含めていない。また、データ公表がない日に０件扱いします\n（今後適切に修正します）。') %>%
    e_grid(left = '3%') %>%
    e_legend(type = 'scroll', orient = 'vertical', left = '10%', top = '15%') %>%
    e_tooltip(trigger = 'axis')
})
