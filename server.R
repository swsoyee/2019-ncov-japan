source(file = "global.R",
       local = TRUE,
       encoding = "UTF-8")

shinyServer(function(input, output, session) {
  output$map <- renderPlot({
    province <- db$name
    total <- rowSums(db[, 2:ncol(db)])
    colorFunc <-
      colorRampPalette(c("#FFFFFF", "#FFA07A", "#CD5C5C"))
    
    breaks <- c(-0.1, 0.5, 1.5, 2.5, 100)
    breaks.length <- length(breaks) - 1
    names(province) <-
      colorFunc(breaks.length)[as.numeric(cut(total, breaks = breaks))]
    plotData <- names(province)
    names(plotData) <- as.character(province)
    par(mar = c(0, 0, 0, 0))
    JapanPrefMap(col = plotData)
    legend(143, 35, c(0, 1, 2, ">2"), fill = colorFunc(breaks.length))
  })
  
  output$confirmedAccumulation <- renderPlotly({
    dataset <- db[, 2:ncol(db)]
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
  
  output$totalConfirmed <- renderValueBox({
    valueBox(
      value = sum(db[, 2:ncol(db)]),
      subtitle = paste0(lang[[langCode]][9], '*'),
      # 確認数
      icon = icon('sad-tear'),
      color = "red"
    )
  })
  
  output$totalSuspicious <- renderValueBox({
    valueBox(
      value = "？",
      subtitle = lang[[langCode]][8],
      # 観察中
      icon = icon('flushed'),
      color = "orange"
    )
  })
  
  output$totalDeath <- renderValueBox({
    valueBox(
      value = "0",
      subtitle = lang[[langCode]][7],
      # 死亡数
      icon = icon('dizzy'),
      color = "navy"
    )
  })
  
  output$totalRecovered <- renderValueBox({
    valueBox(
      value = "1",
      subtitle = lang[[langCode]][6],
      # 完治数
      icon = icon('grin-squint'),
      color = "green"
    )
  })
  
  output$totalConfirmedByProvince <- renderDataTable({
    total <- rowSums(db[, 2:ncol(db)])
    tableDt <- data.table('行政区域' = db$name, # 行政区域
                          '確認数' = total # 確認数
                          )
                          # displayData <- tableDt[確認数 > 0][order(-確認数)]
                          displayData <- tableDt[order(-確認数)]
                          datatable(
                            displayData,
                            rownames = FALSE,
                            options = list(
                              dom = 't',
                              scrollY = '440px',
                              scrollCollapse = T,
                              paging = F
                            )
                          ) %>%
                            formatStyle(
                              c('確認数'),
                              background = styleColorBar(range(tableDt[, '確認数']), 'lightblue'),
                              backgroundSize = '98% 88%',
                              backgroundRepeat = 'no-repeat',
                              backgroundPosition = 'center'
                            )
  })
    
  output$news <- renderDataTable({
      newsData <-
        data.table(
          paste0(
            "<small>",
            as.POSIXct(as.character(news$date), format = "%Y%m%d"),
            "</small><br><a href='",
            news$link,
            "'>",
            news$title,
            "</a>"
          )
        )
      datatable(
        newsData[order(-V1)],
        options = list(
          dom = 't',
          scrollCollapse = T,
          scrollY = '440px'
        ),
        rownames = FALSE,
        colnames = lang[[langCode]][14],
        # 最新情報
        escape = FALSE
      )
    })
})
