# ====区域ごとの確認数====
output$totalConfirmedByRegionPlot <- renderEcharts4r({
  dt <- totalConfirmedByRegionData()
  dt$name <- paste(totalConfirmedByRegionData()$region, totalConfirmedByRegionData()$count)
  dt %>%
    e_charts(name) %>%
    e_bar(untilToday, 
          stack = '1',
          name = lang[[langCode]][79],
          label = list(show = T)) %>%
    e_bar(today, 
          stack = '1',
          name = lang[[langCode]][78],
          label = list(show = T, formatter = htmlwidgets::JS('
          function(params) {
            if (params.value[0] > 0) {
              return params.value[0];
            } else {
              return "";
            }
          }
                                                             '))) %>%
    e_grid(left = '20%', right = '5%', bottom = '5%', top = '0%') %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F)) %>%
    e_legend(orient = 'vertical', top = '5%', right = '5%') %>%
    e_flip_coords() %>%
    e_tooltip(trigger = 'axis', 
              axisPointer = list(type = 'shadow'))
})

totalConfirmedByRegionData <- reactive({
  total <- colSums(byDate[, 2:ncol(byDate)])
  today <- colSums(byDate[nrow(byDate), 2:ncol(byDate)])
  untilToday <- colSums(byDate[1:nrow(byDate) - 1, 2:ncol(byDate)])
  total <- data.table(region = names(total), 
                      count = total, 
                      today = today, 
                      untilToday = untilToday)
  
  if (is.null(input$showOtherRegion)) {
    total <- total[!(region %in% lang[[langCode]][35:36])]
  } else {
    if (!('showShip' %in% input$showOtherRegion)) {
      total <- total[region != lang[[langCode]][35]] # クルーズ船
    }
    if (!('showFlight' %in% input$showOtherRegion)) {
      total <- total[region != lang[[langCode]][36]] # チャーター便
    }
  }
  total[count > 0][order(-count)]
})

output$genderBar <- renderEcharts4r({
  dt <- detail[, c('gender', 'age'), with = F]
  dt <- dt[, .(count = .N), by = c('gender', 'age')]
  dt <- reshape(data = dt, idvar = 'age', timevar = 'gender', direction = 'wide')
  dt$count.女 <- 0 - dt$count.女
  
  dt %>%
    e_chart(age) %>%
    e_bar(count.男, stack = '1', name = '男性', itemStyle = list(color = '#2DA0CD')) %>%
    e_bar(count.女, stack = '1', name = '女性', itemStyle = list(color = '#B73376')) %>%
    e_x_axis(type = 'category') %>%
    e_labels(position = 'inside', formatter = htmlwidgets::JS('
      function(params) {
        let count = params.value[0]
        if(count < 0) {
          count = -count
        }
        return(count)
      }
    ')) %>%
    e_y_axis(axisLabel = '', splitLine = list(show = F)) %>%
    e_flip_coords() %>%
    e_tooltip(formatter = htmlwidgets::JS('
      function(params) {
        let count = params.value[0]
        if(count < 0) {
          count = -count
        }
        return("歳代：" + params.value[1]+ "<br>確認数：" + count)
      }
                                          '),
    ) %>%
    e_legend(top = '0%', right = '20%') %>%
    e_grid(top = '0%', bottom = '1%', left = '10%', right = '10%')
})
