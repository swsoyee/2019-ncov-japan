# ====感染確認推移図====
output$confirmedLine <- renderEcharts4r({
  # 国内
  domestic <- byDate[, c(2:48)]
  domestic <- cumsum(rowSums(domestic[, 2:ncol(domestic)]))
  columnName <- c('date', 'domestic', 'flight', 'officer', 'ship', 'dailyDiff', 'dailyDiffShip')
  dt <- data.table(lapply(byDate[, 1], function(x){as.Date(as.character(x), format = '%Y%m%d')})$date,
                   domestic,
                   cumsum(byDate[, 49]),
                   cumsum(byDate[, 50]),
                   cumsum(byDate[, 51]),
                   rowSums(byDate[, 2:(ncol(byDate)-1)]),
                   byDate$クルーズ船
  )
  colnames(dt) <- columnName
  defaultUnselected <- list(F, F)
  names(defaultUnselected) <- c(lang[[langCode]][35], lang[[langCode]][76])
  dt %>% 
    e_charts(date) %>% 
    # 本土
    e_bar(domestic, name = lang[[langCode]][75], stack = "grp") %>%
    # 検疫/職員
    e_bar(officer, name = lang[[langCode]][55], stack = "grp") %>%
    # チャーター便
    e_bar(flight, name = lang[[langCode]][36],stack = "grp") %>%
    # 新規感染者数（日次、クルーズ船を除く）
    e_line(dailyDiff, name = lang[[langCode]][77], y_index = 1) %>%
    # クルーズ船
    e_bar(ship, name = lang[[langCode]][35], stack = "grp") %>%
    # クルーズ船の新規感染者数（日次）
    e_line(dailyDiffShip, name = lang[[langCode]][76], y_index = 1) %>%
    e_legend(selected = defaultUnselected, top = '5%', left = '5%', type = 'scroll', orient = 'vertical') %>% 
    e_grid(left = '5%', right = '5%', bottom = '10%', top = '5%') %>%
    e_x_axis(splitLine =  list(show = F)) %>%
    e_y_axis(splitLine =  list(show = F), index = 1) %>%
    e_y_axis(splitLine = list(lineStyle = list(type = 'dotted'))) %>%
    # e_zoom() %>% e_datazoom() %>%
    e_tooltip(trigger = 'axis')
})

# ====退院推移図（国内）====
output$recoveredLine <- renderEcharts4r({
  yData <- cumsum(rowSums(recovered[, 2:3]))
  xData <- as.Date(recovered$date, format = "%Y%m%d")
  dt <- data.table('date' = xData, 
                   'domestic' = cumsum(recovered[, 2]), 
                   'domesticDiff' = recovered[, 2],
                   'flight' = cumsum(recovered[, 3]), 
                   'flightDiff' = recovered[, 3],
                   'total' = yData,
                   'totalDiff' = rowSums(recovered[, 2:3])
                   )
  dt %>%
    e_chart(date) %>%
    e_line(total, name = lang[[langCode]][6], itemStyle = list(normal = list(color = '#01A65A'))) %>%
    e_line(totalDiff, name = lang[[langCode]][77], itemStyle = list(normal = list(color = '#068E4C'))) %>%
    e_x_axis(splitLine =  list(show = F)) %>%
    e_y_axis(splitLine = list(lineStyle = list(type = 'dotted'))) %>%
    e_grid(left = '5%', right = '5%', bottom = '20%', top = '5%') %>%
    e_legend(top = '5%', left = '5%', type = 'scroll', orient = 'vertical') %>% 
    e_zoom() %>%
    e_datazoom() %>%
    e_tooltip(trigger = 'axis')
})
