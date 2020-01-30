source(file = "global.R",
       local = TRUE,
       encoding = "UTF-8")

shinyServer(function(input, output, session) {
  output$map <- renderPlot({
    province <- db$name
    total <- rowSums(db[, 2:ncol(db)])
    colorFunc <-
      colorRampPalette(c("#FFFFFF", "#FFA07A", "#CD5C5C"))
    names(province) <-
      colorFunc(3)[as.numeric(cut(total, breaks = c(-0.1, 0.5, 2.5, 100)))]
    plotData <- names(province)
    names(plotData) <- as.character(province)
    par(mar = c(0, 0, 0, 0))
    JapanPrefMap(col = plotData)
    legend(143, 33, c("0", "1 ~ 2", "> 2"), fill = colorFunc(3))
  })
  
  output$confirmedAccumulation <- renderPlotly({
    dataset <- db[, 2:ncol(db)]
    dt <- dataset[, lapply(.SD, sum)]
    yData <- cumsum(transpose(dt))
    xData <- as.POSIXct(colnames(dt), format = "%Y%m%d")
    
    p <- plot_ly(
      x =  ~ xData,
      y = ~ yData$V1,
      name = '全国',
      type = "scatter",
      mode = 'spline',
    ) %>% layout(
      xaxis = list(title = '日付'),
      yaxis = list(title = '人数'),
      showlegend = T,
      legend = list(
        orientation = 'h',
        y = 1.1,
        x = 1,
        xanchor = 'right',
        yanchor = 'top'
      )
    )
    
    hasData <-
      db[, .(sum = sum(.SD)), .SDcols = colnames(dt), by = name]$sum > 0
    provinceHasDataset <- db[hasData]
    for (i in 1:nrow(provinceHasDataset)) {
      p <-
        add_trace(p,
                  x = xData,
                  y = cumsum(transpose(provinceHasDataset[i, 2:ncol(provinceHasDataset)]))$V1,
                  name = provinceHasDataset[i, 1])
    }
    p
  })
  
  output$totalConfirmed <- renderValueBox({
    valueBox(value = sum(db[, 2:ncol(db)]), 
             subtitle = LABEL_CONFIRMED,
             icon = icon('sad-tear'),
             color = "red")
  })
  
  output$totalSuspicious <- renderValueBox({
    valueBox(value = "？", 
             subtitle = LABEL_SUSPICIOUS,
             icon = icon('flushed'),
             color = "orange")
  })
  
  output$totalDeath <- renderValueBox({
    valueBox(value = "0", 
             subtitle = LABEL_DEATH,
             icon = icon('dizzy'),
             color = "navy")
  })
  
  output$totalRecovered <- renderValueBox({
    valueBox(value = "1", 
             subtitle = LABLE_RECOVERTED,
             icon = icon('grin-squint'),
             color = "green")
  })
})