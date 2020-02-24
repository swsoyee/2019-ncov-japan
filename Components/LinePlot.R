# output$domesticLine <- renderPlotly({
#   # 国内＋職員
#   dataset <- byDate[, c(2:48, 50)]
#   yData <- cumsum(rowSums(dataset[, 2:ncol(dataset)]))
#   xData <-  as.POSIXct(as.character(byDate$date), format = "%Y%m%d")
#   yFlight <- cumsum(byDate$チャーター便)
#   yTotal <- yData + yFlight
#   yDiffByDate <- rowSums(dataset)
#   plot_ly(type = 'bar') %>%
#     add_trace(
#       x =  ~ xData,
#       y = ~ yFlight,
#       # text = yFlight,
#       # textposition = 'auto',
#       hoverinfo = 'text',
#       # %{x}<br>累計確認数：%{y}
#       hovertemplate = lang[[langCode]][66],
#       marker = list(color = '#F39C12'),
#       # 国内事例
#       name = lang[[langCode]][36]
#     )  %>%
#     add_trace(
#       x =  ~ xData,
#       y = ~ yData,
#       # text = yData,
#       # textposition = 'inside',
#       hoverinfo = 'text',
#       # %{x}<br>累計確認数：%{y}
#       hovertemplate = lang[[langCode]][66],
#       marker = list(color = '#D35400'),
#       name = lang[[langCode]][4]
#     ) %>%
#     add_trace(
#       x = ~ xData,
#       y = ~ yDiffByDate,
#       yaxis = 'y2',
#       type = 'scatter',
#       name = lang[[langCode]][65],
#       # 新規感染者数(日次)
#       marker = list(color = '#2C3E50'),
#       line = list(color = '#2C3E50'),
#       mode = 'lines+markers'
#     ) %>%
#     layout(
#       yaxis = list(title = '', showline = T),
#       xaxis = list(
#         title = '',
#         type = 'date',
#         tickformat = '%m/%d',
#         rangeslider = list(type = "date"),
#         rangeselector = list(
#           buttons = list(
#             list(
#               count = 7,
#               label = '１週間',
#               step = 'day',
#               stepmode = 'backward'),
#             list(
#               count = 14,
#               label = '２週間',
#               step = 'day',
#               stepmode = 'backward'),
#             list(
#               count = 1,
#               label = '１ヶ月',
#               step = 'month',
#               stepmode = "backward"),
#             list(label = '全部', step = 'all')
#             ))
#       ),
#       yaxis2 = list(
#         side = 'right',
#         rangemode = 'tozero',
#         overlaying = "y",
#         automargin = T,
#         range = c(0, 50),
#         showgrid = F,
#         showline = T
#       ),
#       barmode = 'stack',
#       margin = list(l = 0, r = 0),
#       legend = list(x = 0, y = 1, bgcolor = 'rgba(0,0,0,0)')
#     ) %>% config(displayModeBar = F)
# })

output$shipLine <- renderPlotly({
  # クルーズ船
  yData <- cumsum(byDate$クルーズ船)
  xData <-  as.POSIXct(as.character(byDate$date), format = "%Y%m%d")
  yDiffByDate <- byDate$クルーズ船
  
  plot_ly(type = 'bar') %>%
    add_trace(
      x = ~ xData,
      y = ~ yDiffByDate,
      yaxis = 'y2',
      type = 'scatter',
      name = lang[[langCode]][65],
      # 新規感染者数(日次)
      marker = list(color = '#2C3E50'),
      line = list(color = '#2C3E50'),
      mode = 'lines+markers'
    ) %>%
    add_trace(
      x = ~ xData,
      y = ~ yData,
      hoverinfo = 'text',
      # %{x}<br>累計確認数：%{y}
      hovertemplate = lang[[langCode]][66],
      marker = list(color = '#DD4B38'),
      # クルーズ船
      name = lang[[langCode]][35]
    ) %>%
    layout(
      xaxis = list(
        title = '',
        type = 'date',
        tickformat = '%m/%d',
        rangeslider = list(type = "date"),
        rangeselector = list(
          buttons = list(
            list(
              count = 7,
              label = '１週間',
              step = 'day',
              stepmode = 'backward'),
            list(
              count = 14,
              label = '２週間',
              step = 'day',
              stepmode = 'backward'),
            list(
              count = 1,
              label = '１ヶ月',
              step = 'month',
              stepmode = "backward"),
            list(label = '全部', step = 'all')
          ))
      ),
      yaxis = list(title = '', showline = T),
      yaxis2 = list(
        side = 'right',
        rangemode = 'tozero',
        overlaying = "y",
        automargin = T,
        range = c(0, 200),
        showgrid = F,
        showline = T
      ),
      margin = list(l = 0, r = 0),
      legend = list(x = 0, y = 1, bgcolor = 'rgba(0,0,0,0)')
    ) %>% config(displayModeBar = F)
})

output$recoveredAccumulation <- renderPlotly({
  dt <- cumsum(rowSums(recovered[, 2:3]))
  xData <- as.Date(recovered$date, format = "%Y%m%d")
  p <- plot_ly(
    x = ~ xData,
    y = ~ dt,
    type = 'scatter',
    line = list(color = '#01A65A'),
    marker = list(color = '#01A65A'),
    mode = 'lines+markers'
  ) %>%
    layout(
      yaxis = list(title = '',
                   automargin = T,
                   showgrid = F,
                   showline = T),
      xaxis = list(title = '',
                   type = 'date',
                   tickformat = '%m/%d',
                   rangeslider = list(type = "date"),
                   rangeselector = list(
                     buttons = list(
                       list(
                         count = 7,
                         label = '１週間',
                         step = 'day',
                         stepmode = 'backward'),
                       list(
                         count = 14,
                         label = '２週間',
                         step = 'day',
                         stepmode = 'backward'),
                       list(
                         count = 1,
                         label = '１ヶ月',
                         step = 'month',
                         stepmode = "backward"),
                       list(label = '全部', step = 'all')))),
      annotations = list(text = '厚生労働省のサイトにおいて、退院に関する情報は非常に少なく、</br></br>また公表も遅れがあるため、当サイトのデータはご参考まで',
                        x = 0,
                        y = 1,
                        showarrow = F, xref='paper', yref='paper'),
      showlegend = F
    ) %>% config(displayModeBar = F)
  p
})

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
    e_legend(selected = defaultUnselected) %>%
    e_tooltip(trigger = 'axis')
})
