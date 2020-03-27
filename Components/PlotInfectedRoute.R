infectedRouteByRegionData <- reactive({
  positiveDetail$announceDate <- as.Date(positiveDetail$発表日, '%m月%d日')
  positiveDetail[`渡航・接触歴` %in% c('', '未'), `渡航・接触歴` := '不明']
  dt <- positiveDetail[!is.na(announceDate), .(count = .N), by = .(都道府県, announceDate, `渡航・接触歴`)]
  # input <- list(infectedRouteByRegionPicker = c('東京都', '神奈川県'))
  dt <- dt[都道府県 %in% input$infectedRouteByRegionPicker]
  dt[, sum(count), by = .(announceDate, `渡航・接触歴`)]
})

output$infectedRouteByRegion <- renderEcharts4r({
  dt <- infectedRouteByRegionData()

  dt %>%
    group_by(`渡航・接触歴`) %>%
    e_chart(announceDate) %>%
    e_bar(V1, stack = 1) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), 
             max = max(dt[, sum(V1), by = announceDate][[2]], na.rm = T)) %>%
    e_tooltip(trigger = 'axis') %>%
    e_grid(left = '5%', right = '5%')
})
