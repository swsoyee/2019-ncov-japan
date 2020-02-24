output$confirmedPie <- renderPlotly({
  plot_ly(data = CONFIRMED_PIE_DATA,
          labels = ~category,
          values = ~value, 
          textposition = 'inside',
          textinfo = 'value+percent',
          showlegend = F,
          hoverinfo = 'text',
          text = ~category,
          marker = list(colors = c('#D35400', '#DD4B38', '#F39C12'),
                        line = list(color = '#FFFFFF', width = 1)),
          type = 'pie') %>%
    layout(margin = list(t = 0, l = 0, b = 5)) %>% config(displayModeBar = F)
})

output$curedPie <- renderPlotly({
  plot_ly(data = CURED_PIE_DATA,
          labels = ~category,
          values = ~value, 
          textposition = 'inside',
          textinfo = 'value+percent',
          showlegend = F,
          hoverinfo = 'text',
          text = ~category,
          marker = list(colors = c('#00a65a', '#16A085'),
                        line = list(color = '#FFFFFF', width = 1)),
          type = 'pie') %>%
    layout(margin = list(t = 0, l = 0, b = 5)) %>% config(displayModeBar = F)
})

output$deathPie <- renderPlotly({
  plot_ly(data = DEATH_PIE_DATA,
          labels = ~category,
          values = ~value, 
          textposition = 'inside',
          textinfo = 'value+percent',
          showlegend = F,
          hoverinfo = 'text',
          text = ~category,
          marker = list(colors = c('#011E3F', '#34495E'),
                        line = list(color = '#FFFFFF', width = 1)),
          type = 'pie') %>%
    layout(margin = list(t = 0, l = 0, b = 5)) %>% config(displayModeBar = F)
})

output$totalConfirmedByRegionPlot <- renderEcharts4r({
  totalConfirmedByRegionData() %>%
    e_charts(region) %>%
    e_polar() %>%
    e_angle_axis(region) %>%
    e_radius_axis() %>%
    e_bar(count, 
          coord_system = "polar", 
          name = lang[[langCode]][9],
          label = list(show = T)) %>%
    e_tooltip()
})

totalConfirmedByRegionData <- reactive({
  total <- colSums(byDate[, 2:ncol(byDate)])
  tableDt <- data.table(region = names(total), count = total)

  if (is.null(input$showOtherRegion)) {
    tableDt <- tableDt[!(region %in% lang[[langCode]][35:36])]
  } else {
    if (!('showShip' %in% input$showOtherRegion)) {
      tableDt <- tableDt[region != lang[[langCode]][35]] # クルーズ船
    }
    if (!('showFlight' %in% input$showOtherRegion)) {
      tableDt <- tableDt[region != lang[[langCode]][36]] # チャーター便
    }
  }
  tableDt[count > 0][order(-count)]
})
