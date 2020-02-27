output$confirmedCalendar <- renderEcharts4r({
  maxValue <- max(confirmedDataByDate()$dailyDiff)
  confirmedDataByDate() %>% 
    e_charts(date) %>% 
    e_calendar(range = c('2020-01-01', '2020-06-30'),
               top = 30, left = 80,
               dayLabel = list(nameMap = c('日', '月', '火', '水', '木', '金', '土')),
               monthLabel = list(nameMap = 'cn')) %>% 
    e_heatmap(dailyDiff, coord_system = "calendar", name = lang[[langCode]][82]) %>% 
    e_heatmap(dailyDiffShip, coord_system = "calendar", name = lang[[langCode]][81]) %>% 
    e_heatmap(dailyDiffAll, coord_system = "calendar", name = lang[[langCode]][80]) %>% 
    e_legend(show = F) %>%
    e_visual_map(top = '2%', 
                 max = maxValue, 
                 inRange = list(color = c('#FFFFFF', '#DD4C3A', '#9D2A1B')), # scale colors
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
