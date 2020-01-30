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
    
    plot_ly(
      x =  ~ xData,
      y = ~ yData$V1,
      name = '確認数',
      mode = 'spline',
      fill = 'tozeroy'
    ) %>% layout(
      xaxis = list(title = '日付'),
      yaxis = list(title = '人数'),
      showlegend = T,
      legend = list(orientation = 'h', y = 1.1, x = 0.9)
    )
  })

})