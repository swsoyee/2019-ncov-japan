# ====感染確認推移図====
output$confirmedLine <- renderEcharts4r({
  dt <- confirmedDataByDate()

  e <- dt %>% 
    e_charts(date) %>%
    e_grid(left = '10%', right = '8%', bottom = '18%', top = '7%') %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), index = 0) %>%
    e_y_axis(splitLine = list(show = F), index = 1) %>%
    # e_zoom() %>% e_datazoom() %>%
    e_legend(type = 'scroll', orient = 'vertical', left = '10%', top = '7%') %>%
    e_tooltip(trigger = 'axis') %>% e_theme("essos") %>% e_color(background = '#FFFFFF')

  for(i in input$regionPicker) {
    itemTotal <- paste0(i, '合計')
    itemNew <- paste0(i, '新規')
    assign(itemTotal, itemTotal)
    assign(i, i)
    e <- e %>%
      e_line_(itemTotal, name = itemTotal, stack = 'total') %>%
      e_bar_(i, name = paste0(i, '新規'), stack = 'new', y_index = 1)
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
  dt$国内 <- rowSums(byDate[, c(2:48)])
  if(!is.null(input$regionPicker)) {
    dt <- dt[, c('date', input$regionPicker)]
    # dt <- dt[, c('date', 'チャーター便', '国内', '検疫職員')] # TEST
    for (i in 2:ncol(dt)) {
      indexName <- colnames(dt)[i]
      dt[, paste0(colnames(dt)[i], '合計')] <- cumsum(dt[, i])
    }
    dt
  } else {
    dt[1] # 日付のカラムだけを返す
  }
})

curedDataByDate <- reactive({
# curedDataByDate <-({
  yData <- cumsum(rowSums(recovered[, 2:3]))
  xData <- as.Date(recovered$date, format = "%Y%m%d")
  cumSumTotalConfirmed <- cumsum(rowSums(byDate[, 2:(ncol(byDate) - 1)]))
  columnName <- c('date', 'domestic', 'domesticDiff', 'flight', 'flightDiff', 'total', 
                  'totalDiff', 'totalConfirmed', 
                  'curedVerseConfirmed', 'mildVerseConfirmed', 'severeVerseConfirmed', 'confirmingVerseConfirmed')
  dt <- data.table(xData, 
                   cumsum(recovered[, 2]), 
                   recovered[, 2],
                   cumsum(recovered[, 3]), 
                   recovered[, 3],
                   yData,
                   rowSums(recovered[, 2:3]),
                   cumSumTotalConfirmed,
                   round(yData / cumSumTotalConfirmed * 100, 2),
                   round((cumsum(recovered$mildDomestic + recovered$mildFlight) / cumSumTotalConfirmed) * 100, 2),
                   round((cumsum(recovered$severeDomestic + recovered$severeFlight) / cumSumTotalConfirmed) * 100, 2),
                   round((cumsum(recovered$confirmingDomestic + recovered$confirmingFlight) / cumSumTotalConfirmed) * 100, 2)
  )
  colnames(dt) <- columnName
  dt
})

# ====退院推移図（国内）====
output$recoveredLine <- renderEcharts4r({
  defaultUnselected <- list(F)
  names(defaultUnselected) <- c(lang[[langCode]][86])
  
  curedDataByDate() %>%
  # dt %>%
    e_chart(date) %>%
    e_area(total, name = lang[[langCode]][6], itemStyle = list(normal = list(color = '#2BA84A'))) %>%
    e_bar(totalDiff, name = lang[[langCode]][77], itemStyle = list(normal = list(color = '#248232'))) %>%
    e_line(confirmingVerseConfirmed, name = lang[[langCode]][86], stack = '1', y_index = 1, itemStyle = list(color = '#083D77')) %>%
    e_line(severeVerseConfirmed, name = lang[[langCode]][85], stack = '1', y_index = 1, itemStyle = list(color = '#F95738')) %>%
    e_line(mildVerseConfirmed, name = lang[[langCode]][84], stack = '1', y_index = 1, itemStyle = list(color = '#EE964B')) %>%
    e_line(curedVerseConfirmed, name = lang[[langCode]][83], stack = '1', y_index = 1, itemStyle = list(color = '#F4D35E')) %>%
    e_mark_point(lang[[langCode]][77], data = list(type = "max")) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(lineStyle = list(type = 'dotted'))) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = 100, formatter = htmlwidgets::JS('
      function(params) {
        return(params + "%")
      }
    ')) %>%
    e_grid(left = '8%', right = '8%', bottom = '20%', top = '7%') %>%
    e_legend(top = '7%', left = '8%', type = 'scroll', orient = 'vertical', selected = defaultUnselected) %>% 
    e_zoom() %>%
    e_datazoom() %>%
    e_tooltip(trigger = 'axis')
})
