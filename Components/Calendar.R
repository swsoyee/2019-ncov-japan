output$confirmedCalendar <- renderEcharts4r({
  maxValue <- max(confirmedDataByDate()$dailyDiff)
  # maxValue <- max(dt$dailyDiff)
  confirmedDataByDate() %>%
  # dt %>%
    e_charts(date) %>% 
    e_calendar(range = c('2020-01-01', '2020-06-30'),
               top = 25, left = 0, cellSize = 15,
               splitLine = list(show = F), itemStyle = list(borderWidth = 2, borderColor = '#FFFFFF'),
               dayLabel = list(nameMap = c('日', '月', '火', '水', '木', '金', '土')),
               monthLabel = list(nameMap = 'cn')) %>% 
    e_heatmap(dailyDiff, coord_system = "calendar", name = lang[[langCode]][82]) %>% 
    e_heatmap(dailyDiffShip, coord_system = "calendar", name = lang[[langCode]][81]) %>% 
    e_heatmap(dailyDiffAll, coord_system = "calendar", name = lang[[langCode]][80]) %>% 
    e_legend(show = F) %>%
    e_visual_map(top = '2%', 
                 show = F,
                 max = maxValue, 
                 inRange = list(color = c('#FFFFFF', middleRed, darkRed)), # scale colors
    ) %>%
    e_tooltip() %>%
    e_legend_select(name = lang[[langCode]][82], btn = 'withoutShipCalendar') %>%
    e_legend_unselect(name = lang[[langCode]][80], btn = 'withoutShipCalendar') %>%
    e_legend_unselect(name = lang[[langCode]][81], btn = 'withoutShipCalendar') %>%
    e_legend_select(name = lang[[langCode]][81], btn = 'shipCalendar') %>%
    e_legend_unselect(name = lang[[langCode]][80], btn = 'shipCalendar') %>%
    e_legend_unselect(name = lang[[langCode]][82], btn = 'shipCalendar') %>%
    e_legend_select(name = lang[[langCode]][80], btn = 'allCalendar') %>%
    e_legend_unselect(name = lang[[langCode]][81], btn = 'allCalendar') %>%
    e_legend_unselect(name = lang[[langCode]][82], btn = 'allCalendar')
})

output$curedCalendar <- renderEcharts4r({
  maxValue <- max(curedDataByDate()$totalDiff)
  # maxValue <- max(curedDataByDate)
  curedDataByDate() %>%
  # curedDataByDate %>%
    e_charts(date) %>% 
    e_calendar(range = c('2020-01-01', '2020-06-30'),
               top = 25, left = 0, cellSize = 15,
               splitLine = list(show = F), itemStyle = list(borderWidth = 2, borderColor = '#FFFFFF'),
               dayLabel = list(nameMap = c('日', '月', '火', '水', '木', '金', '土')),
               monthLabel = list(nameMap = 'cn')) %>% 
    e_heatmap(totalDiff, coord_system = "calendar", name = lang[[langCode]][80]) %>% 
    e_legend(show = F) %>%
    e_visual_map(top = '15%', 
                 max = maxValue, 
                 show = F,
                 inRange = list(color = c('#FFFFFF', darkGreen)), # scale colors
    ) %>%
    e_tooltip()
})

output$renderCalendar <- renderUI({
  if (input$linePlot == 'confirmed') {
    tagList(
      actionButton(inputId = 'withoutShipCalendar', 
                 label = lang[[langCode]][82]# , 
                 # size = 'xs', style = 'fill', color = 'danger'
                 ),
      actionButton(inputId = 'shipCalendar', 
                 label = lang[[langCode]][81]# ,
                 # size = 'xs', style = 'fill', color = 'danger'
                 ),
      actionButton(inputId = 'allCalendar',
                 label = lang[[langCode]][80]# ,
                 #size = 'xs', style = 'fill', color = 'danger'
                 ),
      echarts4rOutput('confirmedCalendar', height = '130px') 
    )
  } else {
    tagList(
      echarts4rOutput('curedCalendar', height = '130px') 
    )
  }
})