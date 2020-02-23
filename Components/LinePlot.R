output$domesticLine <- renderPlotly({
  # 国内＋職員
  dataset <- byDate[, c(2:48, 50)]
  yData <- cumsum(rowSums(dataset[, 2:ncol(dataset)]))
  xData <-  as.POSIXct(as.character(byDate$date), format = "%Y%m%d")
  yFlight <- cumsum(byDate$チャーター便)
  yTotal <- yData + yFlight
  yDiffByDate <- rowSums(dataset)
  plot_ly(type = 'bar') %>%
    add_trace(
      x =  ~ xData,
      y = ~ yFlight,
      # text = yFlight,
      # textposition = 'auto',
      hoverinfo = 'text',
      # %{x}<br>累計確認数：%{y}
      hovertemplate = lang[[langCode]][66],
      marker = list(color = '#F39C12'),
      # 国内事例
      name = lang[[langCode]][36]
    )  %>%
    add_trace(
      x =  ~ xData,
      y = ~ yData,
      # text = yData,
      # textposition = 'inside',
      hoverinfo = 'text',
      # %{x}<br>累計確認数：%{y}
      hovertemplate = lang[[langCode]][66],
      marker = list(color = '#D35400'),
      name = lang[[langCode]][4]
    ) %>%
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
    layout(
      yaxis = list(title = '', showline = T),
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
      yaxis2 = list(
        side = 'right',
        rangemode = 'tozero',
        overlaying = "y",
        automargin = T,
        range = c(0, 50),
        showgrid = F,
        showline = T
      ),
      barmode = 'stack',
      margin = list(l = 0, r = 0),
      legend = list(x = 0, y = 1, bgcolor = 'rgba(0,0,0,0)')
    ) %>% config(displayModeBar = F)
})

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

# output$confirmedAccumulation <- renderPlotly({
#   dataset <- db[c(1:47, 50), 2:ncol(db)]
#   dt <- dataset[, lapply(.SD, sum)]
#   yData <- cumsum(transpose(dt))
#   xData <- as.POSIXct(colnames(dt), format = "%Y%m%d")
#   
#   p <- plot_ly(
#     x =  ~ xData,
#     y = ~ yData$V1,
#     name = lang[[langCode]][4],
#     # 全国
#     type = "scatter",
#     mode = 'lines'
#   )
#   
#   hasData <-
#     db[, .(sum = sum(.SD)), .SDcols = colnames(dt), by = name]$sum > 0
#   provinceHasDataset <- db[hasData]
#   for (i in 1:nrow(provinceHasDataset)) {
#     if (provinceHasDataset[i]$name != 'ダイアモンド・プリンセス号') {
#       p <-
#         add_trace(
#           p,
#           x = xData,
#           y = cumsum(transpose(provinceHasDataset[i, 2:ncol(provinceHasDataset)]))$V1,
#           name = provinceHasDataset[i, 1],
#           line = list(dash = 'dot')
#         )
#     } else {
#       p <-
#         add_trace(
#           p,
#           x = xData,
#           y = cumsum(transpose(provinceHasDataset[i, 2:ncol(provinceHasDataset)]))$V1,
#           yaxis = 'y2',
#           name = provinceHasDataset[i, 1],
#           mode = 'lines+markers',
#           line = list(color = 'black'),
#           marker = list(color = 'black')
#         )
#     }
#   }
#   p %>% layout(
#     # 人数
#     yaxis = list(title = paste0(lang[[langCode]][4], lang[[langCode]][11])),
#     yaxis2 = list(
#       title = paste0(lang[[langCode]][35], lang[[langCode]][11]),
#       side = "right",
#       overlaying = "y",
#       automargin = T
#     ),
#     xaxis = list(title = ''),
#     showlegend = F,
#     legend = list(y = 0.5,
#                   x = 1.15)
#   )
# })

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
      yaxis = list(title = lang[[langCode]][11]),
      xaxis = list(title = ''),
      showlegend = F
    ) %>% config(displayModeBar = F)
  p
})
