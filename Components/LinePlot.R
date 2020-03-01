# ====感染確認推移図====
output$confirmedLine <- renderEcharts4r({
  dt <- confirmedDataByDate()
  defaultUnselected <- list(F, F)
  names(defaultUnselected) <- c(lang[[langCode]][35], lang[[langCode]][76])
  dt %>% 
    e_charts(date) %>% 
    # 本土
    e_area(domestic, name = lang[[langCode]][75], stack = "grp", itemStyle = list(color = middleRed)) %>%
    # 検疫/職員
    e_area(officer, name = lang[[langCode]][55], stack = "grp", itemStyle = list(color = darkRed)) %>%
    # チャーター便
    e_area(flight, name = lang[[langCode]][36],stack = "grp", itemStyle = list(color = lightYellow)) %>%
    # 新規感染者数（日次、クルーズ船を除く）
    e_bar(dailyDiff, name = lang[[langCode]][77], stack = 'line', y_index = 1) %>%
    e_mark_point(lang[[langCode]][77], data = list(type = "max")) %>%
    # クルーズ船
    e_area(ship, name = lang[[langCode]][35], stack = "grp", itemStyle = list(color = lightRed)) %>%
    # クルーズ船の新規感染者数（日次）
    e_bar(dailyDiffShip, name = lang[[langCode]][76], stack = 'line', y_index = 1) %>%
    e_mark_point(lang[[langCode]][76], data = list(type = "max")) %>%
    e_legend(selected = defaultUnselected, top = '7%', left = '8%', type = 'scroll', orient = 'vertical') %>% 
    e_grid(left = '5%', right = '8%', bottom = '20%', top = '7%') %>%
    e_x_axis(splitLine =  list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = 120) %>%
    e_y_axis(splitLine = list(show = F)) %>%
    e_zoom() %>% e_datazoom() %>%
    e_tooltip(trigger = 'axis')
})

confirmedDataByDate <- reactive({
  domestic <- byDate[, c(2:48)]
  domestic <- cumsum(rowSums(domestic[, 1:ncol(domestic)]))
  columnName <- c('date', 'domestic', 'flight', 'officer', 'ship', 'dailyDiff', 'dailyDiffShip', 'dailyDiffAll')
  dt <- data.table(byDate$date,
                   domestic,
                   cumsum(byDate[, 49]),
                   cumsum(byDate[, 50]),
                   cumsum(byDate[, 51]),
                   rowSums(byDate[, 2:(ncol(byDate)-1)]),
                   byDate$クルーズ船,
                   rowSums(byDate[, 2:(ncol(byDate)-1)]) + byDate$クルーズ船
  )
  colnames(dt) <- columnName
  dt
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
