output$processSankey <- renderEcharts4r({
  # maxValue <- max(processDataSpecific$value)
  processDataSpecific() %>% 
    e_charts() %>% 
    e_sankey(source, target, value, focusNodeAdjacency = T) %>%
    e_theme('essos') %>% e_color(background = '#FFFFFF') %>%
    e_grid(left = '1%') %>%
    e_tooltip()
})

processDataSpecific <- reactive({
  # processData[date = input$processDate]
  # processDataSpecific <-
    processData[date == input$selectProcessDay]
})