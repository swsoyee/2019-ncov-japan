output$confirmedCalendar <- renderEcharts4r({
  dt <- confirmedDataByDate()
  if(length(confirmedDataByDate()) > 1) {
    maxValue <- max(dt$difference)
    dt %>%
      e_charts(date) %>% 
      e_calendar(range = c('2020-01-01', '2020-06-30'),
                 top = 25, left = 0, cellSize = 15,
                 splitLine = list(show = F), itemStyle = list(borderWidth = 2, borderColor = '#FFFFFF'),
                 dayLabel = list(nameMap = c('日', '月', '火', '水', '木', '金', '土')),
                 monthLabel = list(nameMap = 'cn')) %>% 
      e_heatmap(difference, coord_system = "calendar") %>%
      e_legend(show = F) %>%
      e_visual_map(top = '2%', 
                   show = F,
                   max = maxValue, 
                   inRange = list(color = c('#FFFFFF', middleRed, darkRed)), # scale colors
      ) %>%
      e_tooltip()
  } else {
    return()
  }
})

output$pcrCalendar <- renderEcharts4r({
  dt <- pcrData()
  maxValue <- max(dt$diff)
  dt %>%
    e_charts(date) %>% 
    e_calendar(range = c('2020-01-01', '2020-06-30'),
               top = 25, left = 0, cellSize = 15,
               splitLine = list(show = F), itemStyle = list(borderWidth = 2, borderColor = '#FFFFFF'),
               dayLabel = list(nameMap = c('日', '月', '火', '水', '木', '金', '土')),
               monthLabel = list(nameMap = 'cn')) %>% 
    e_heatmap(diff, coord_system = "calendar", name = lang[[langCode]][80]) %>% 
    e_legend(show = F) %>%
    e_visual_map(top = '15%', 
                 max = maxValue, 
                 show = F,
                 inRange = list(color = c('#FFFFFF', darkYellow)), # scale colors
    ) %>%
    e_tooltip()
})

output$renderCalendar <- renderUI({
  if (input$linePlot == 'confirmed') {
    if(is.null(input$regionPicker)) {
      tags$p('未選択です。地域を選択してください。')
    } else {
      echarts4rOutput('confirmedCalendar', height = '130px')
    }
  } else {
    tagList(
      tags$p('開発中')
    )
  }
})

output$callCenterCanlendar <- renderEcharts4r({
  dt <- callCenterDailyReport
  setnafill(dt, fill = 0)
  dt <- data.table('date' = dt$date,
                   'count' = dt$call + dt$mail + dt$fax)
  maxValue <- max(dt$count)
  dt %>%
    e_charts(date) %>% 
    e_calendar(range = c('2020-01-01', '2020-06-30'),
               top = 25, left = 0, cellSize = 15,
               splitLine = list(show = F), itemStyle = list(borderWidth = 2, borderColor = '#FFFFFF'),
               dayLabel = list(nameMap = c('日', '月', '火', '水', '木', '金', '土')),
               monthLabel = list(nameMap = 'cn')) %>% 
    e_heatmap(count, coord_system = "calendar", name = lang[[langCode]][80]) %>% 
    e_legend(show = F) %>%
    e_visual_map(top = '15%', 
                 max = maxValue, 
                 show = F,
                 inRange = list(color = c('#FFFFFF', darkBlue)), # scale colors
    ) %>%
    e_tooltip()
})
