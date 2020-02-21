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
    layout(margin = list(t = 0, l = 0, b = 5))
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
    layout(margin = list(t = 0, l = 0, b = 5))
})
