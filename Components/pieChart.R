output$confirmedPie <- renderPlotly({
  plot_ly(data = CONFIRMED_PIE_DATA,
          labels = ~category,
          values = ~value, 
          textposition = 'inside',
          textinfo = 'value+percent',
          showlegend = F,
          hoverinfo = 'text',
          text = ~category,
          type = 'pie') %>%
    layout(margin = list(t = 0, l = 0, b = 5))
})
