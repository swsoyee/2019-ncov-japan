output$confirmedAccumulation <- renderPlotly({
  dataset <- db[c(1:47, 50, 51), 2:ncol(db)]
  dt <- dataset[, lapply(.SD, sum)]
  yData <- cumsum(transpose(dt))
  xData <- as.POSIXct(colnames(dt), format = "%Y%m%d")
  
  p <- plot_ly(
    x =  ~ xData,
    y = ~ yData$V1,
    name = lang[[langCode]][4],
    # 全国
    type = "scatter",
    mode = 'lines'
  )
  
  hasData <-
    db[, .(sum = sum(.SD)), .SDcols = colnames(dt), by = name]$sum > 0
  provinceHasDataset <- db[hasData]
  for (i in 1:nrow(provinceHasDataset)) {
    if (provinceHasDataset[i]$name != 'ダイアモンド・プリンセス号') {
      p <-
        add_trace(
          p,
          x = xData,
          y = cumsum(transpose(provinceHasDataset[i, 2:ncol(provinceHasDataset)]))$V1,
          name = provinceHasDataset[i, 1],
          line = list(dash = 'dot')
        )
    } else {
      p <-
        add_trace(
          p,
          x = xData,
          y = cumsum(transpose(provinceHasDataset[i, 2:ncol(provinceHasDataset)]))$V1,
          yaxis = 'y2',
          name = provinceHasDataset[i, 1],
          mode = 'lines+markers',
          line = list(color = 'black'),
          marker = list(color ='black')
        )
    }
  }
  p %>% layout(
    # 人数
    yaxis = list(title = paste0(lang[[langCode]][4], lang[[langCode]][11])),
    yaxis2 = list(title = paste0(lang[[langCode]][35], lang[[langCode]][11]), 
                  side = "right", 
                  overlaying = "y",
                  automargin = T),
    xaxis = list(title = ''),
    showlegend = F,
    legend = list(
      y = 0.5,
      x = 1.15
    )
  )
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
