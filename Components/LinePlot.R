output$confirmedAccumulation <- renderPlotly({
  dataset <- db[1:47, 2:ncol(db)]
  dt <- dataset[, lapply(.SD, sum)]
  yData <- cumsum(transpose(dt))
  xData <- as.POSIXct(colnames(dt), format = "%Y%m%d")
  
  p <- plot_ly(
    x =  ~ xData,
    y = ~ yData$V1,
    name = lang[[langCode]][4],
    # 全国
    type = "scatter",
    mode = 'lines+markers'
  ) %>% layout(
    # 人数
    yaxis = list(title = lang[[langCode]][11]),
    xaxis = list(title = ''),
    showlegend = T,
    legend = list(
      orientation = 'h',
      y = -0.1,
      x = 0.1
    )
  )
  
  hasData <-
    db[, .(sum = sum(.SD)), .SDcols = colnames(dt), by = name]$sum > 0
  provinceHasDataset <- db[hasData]
  for (i in 1:nrow(provinceHasDataset)) {
    p <-
      add_trace(
        p,
        x = xData,
        y = cumsum(transpose(provinceHasDataset[i, 2:ncol(provinceHasDataset)]))$V1,
        name = provinceHasDataset[i, 1],
        line = list(dash = 'dot')
      )
  }
  p
})

output$recoveredAccumulation <- renderPlotly({
  dt <- cumsum(rowSums(recovered[, 2:3]))
  xData <- as.Date(recovered$date, format = "%Y%m%d")
  p <- plot_ly(x = ~ xData,
               y = ~ dt,
               type = 'scatter',
               line = list(color = '#01A65A'),
               marker = list(color = '#01A65A'),
               mode = 'lines+markers') %>% 
    layout(
      yaxis = list(title = lang[[langCode]][11]),
      xaxis = list(title = ''),
      showlegend = F
    )
  p
})
