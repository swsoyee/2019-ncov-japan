# ====区域ごとの確認数====
output$totalConfirmedByRegionPlot <- renderEcharts4r({
  dt <- totalConfirmedByRegionData()[count > 0][order(-count)]
  # dt$name <- paste(totalConfirmedByRegionData()$region, totalConfirmedByRegionData()$count)
  dt$minusUntilToday <- 0 - dt$untilToday
  dt$minusToday <- 0 - dt$today
  dt$minusTotal <- dt$minusUntilToday + dt$minusToday
  dt %>%
    e_charts(region) %>%
    e_bar(minusUntilToday,
          stack = '1',
          z = 2,
          itemStyle = list(color = middleRed),
          label = list(show = T, position = 'inside', color = '#FFFFFF', formatter = htmlwidgets::JS('
            function(params) {
              if (params.value[0] < 0) {
                return(0 - params.value[0]);
              } else {
                return("");
              }
            }
          ')),
          name = lang[[langCode]][79]) %>%
    e_bar(minusToday,
          stack = '1',
          z = 2,
          itemStyle = list(color = lightNavy),
          label = list(show = T, position = 'inside', color = '#FFFFFF', formatter = htmlwidgets::JS('
            function(params) {
              if (params.value[0] < 0) {
                return(0 - params.value[0]);
              } else {
                return("");
              }
            }
          ')),
          name = lang[[langCode]][78]) %>%
    e_bar(minusTotal,
          z = 1,
          itemStyle = list(color = darkRed),
          barGap = '-100%',
          label = list(show = T, position = 'left', formatter = htmlwidgets::JS('
            function(params) {
              if (params.value[0] < 0) {
                return(params.value[1] + " (" +(0 - params.value[0] + ")"));
              } else {
                return("");
              }
            }
          ')),
          name = '合計') %>%
    e_grid(right = '0%', bottom = '5%', top = '0%', left = '20%') %>%
    e_x_axis(splitLine = list(show = F), axisLabel = list(show = F),
             axisLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), show = F) %>%
    e_legend(orient = 'vertical', top = '0%', left = '50%') %>%
    e_legend_unselect(name = lang[[langCode]][78]) %>%
    e_flip_coords()
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
  total
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

# ====感染者割合====
output$confirmedBar <- renderEcharts4r({
  dt <- data.table('label' = '感染者',
                   'domestic' = TOTAL_DOMESITC + TOTAL_OFFICER,
                   'ship' = TOTAL_SHIP,
                   'flight' = TOTAL_FLIGHT,
                   'domesticPer' = round((TOTAL_DOMESITC + TOTAL_OFFICER) / TOTAL_JAPAN * 100, 2),
                   'shipPer' = round(TOTAL_SHIP / TOTAL_JAPAN * 100, 2),
                   'flightPer' = round(TOTAL_FLIGHT / TOTAL_JAPAN * 100, 2)
  )
  e_charts(dt, label) %>%
    e_bar(shipPer, name = lang[[langCode]][35], stack = '1', itemStyle = list(color = lightRed)) %>%
    e_bar(domesticPer, name = lang[[langCode]][4], stack = '1', itemStyle = list(color = middleRed)) %>%
    e_bar(flightPer, name = lang[[langCode]][36], stack = '1', itemStyle = list(color = lightYellow)) %>%
    e_y_axis(max = 100, splitLine = list(show = F), show = F) %>%
    e_x_axis(splitLine = list(show = F), show = F) %>%
    e_grid(left = '0%', right = '0%', top = '0%', bottom = '0%') %>%
    e_labels(position = 'inside', formatter = htmlwidgets::JS('
      function(params) {
        return(params.value[0] + "%")
      }
    ')) %>%
    e_legend(show = F) %>%
    e_flip_coords() %>%
    e_tooltip(formatter = htmlwidgets::JS(paste0('
      function(params) {
        return(params.seriesName + "：" + Math.round(params.value[0] / 100 * ', TOTAL_JAPAN, ', 0) + "名")
      }
    ')))
})

# ====退院者割合====
output$curedBar <- renderEcharts4r({
  dt <- data.table('label' = '退院者',
                   'domestic' = SYMPTOM_DISCHARGE_WITHIN$final,
                   'flight' = SYMPTOM_DISCHARGE_FLIGHT$final,
                   'ship' = DISCHARGE_SHIP$final,
                   'symtomlessDomestic' = SYMPTOMLESS_DISCHARGE_WITHIN$final,
                   'symtomlessFlight' = SYMPTOMLESS_DISCHARGE_FLIGHT$final,
                   'domesticPer' = round(SYMPTOM_DISCHARGE_WITHIN$final / DISCHARGE_TOTAL * 100, 2),
                   'flightPer' = round(SYMPTOM_DISCHARGE_FLIGHT$final / DISCHARGE_TOTAL * 100, 2),
                   'symtomlessDomesticPer' = round(SYMPTOMLESS_DISCHARGE_WITHIN$final / DISCHARGE_TOTAL * 100, 2),
                   'symtomlessFlightPer' = round(SYMPTOMLESS_DISCHARGE_FLIGHT$final / DISCHARGE_TOTAL * 100, 2),
                   'shipPer' = round(DISCHARGE_SHIP$final / DISCHARGE_TOTAL * 100, 2)
                   )
  e_charts(dt, label) %>%
    e_bar(domesticPer, 
          name = paste0(lang[[langCode]][4], ' (', lang[[langCode]][95], ')'), # 国内事例 （症状あり）
          stack = '1', itemStyle = list(color = lightGreen)) %>%
    e_bar(symtomlessDomesticPer, 
          name = paste0(lang[[langCode]][4], ' (', lang[[langCode]][96], ')'), # 国内事例 （無症状）
          stack = '1', itemStyle = list(color = middleGreen)) %>%
    e_bar(flightPer, 
          name = paste0(lang[[langCode]][36], ' (', lang[[langCode]][95], ')'), # チャーター便 （症状あり）
          stack = '1', itemStyle = list(color = darkGreen)) %>%
    e_bar(symtomlessFlightPer, 
          name = paste0(lang[[langCode]][36], ' (', lang[[langCode]][96], ')'), # チャーター便 （無症状）
          stack = '1', itemStyle = list(color = superDarkGreen)) %>%
    e_bar(shipPer, 
          name = lang[[langCode]][35], # クルーズ船
          stack = '1', itemStyle = list(color = middleGreen)) %>%
    e_y_axis(max = 100, splitLine = list(show = F), show = F) %>%
    e_x_axis(splitLine = list(show = F), show = F) %>%
    e_grid(left = '0%', right = '0%', top = '0%', bottom = '0%') %>%
    e_labels(position = 'inside', formatter = htmlwidgets::JS('
      function(params) {
        if(params.value[0] > 10) {
          return(params.value[0] + "%")
        } else {
          return("")
        }
      }
    ')) %>%
    e_legend(show = F) %>%
    e_flip_coords() %>%
    e_tooltip(formatter = htmlwidgets::JS(paste0('
      function(params) {
        return("<b>" + params.seriesName + "</b><br>" + Math.round(params.value[0] / 100 * ',
        DISCHARGE_TOTAL, ', 0) + "名 (" + params.value[0] + "%)")
      }
    ')))
})

# ====死亡者割合====
output$deathBar <- renderEcharts4r({
  DEATH_TOTAL <- DEATH_DOMESITC + DEATH_SHIP
  dt <- data.table('label' = '死亡者',
                   'domestic' = DEATH_DOMESITC,
                   'flight' = DEATH_SHIP,
                   'domesticPer' = round(DEATH_DOMESITC / DEATH_TOTAL * 100, 2),
                   'shipPer' = round(DEATH_SHIP / DEATH_TOTAL * 100, 2)
  )
  e_charts(dt, label) %>%
    e_bar(domesticPer, name = lang[[langCode]][4], stack = '1', itemStyle = list(color = lightNavy)) %>%
    e_bar(shipPer, name = lang[[langCode]][35], stack = '1', itemStyle = list(color = darkNavy)) %>%
    e_y_axis(max = 100, splitLine = list(show = F), show = F) %>%
    e_x_axis(splitLine = list(show = F), show = F) %>%
    e_grid(left = '0%', right = '0%', top = '0%', bottom = '0%') %>%
    e_legend(show = F) %>%
    e_labels(position = 'inside', formatter = htmlwidgets::JS('
      function(params) {
        return(params.value[0] + "%")
      }
    ')) %>%
    e_flip_coords() %>%
    e_tooltip(formatter = htmlwidgets::JS(paste0('
      function(params) {
        return(params.seriesName + "：" + Math.round(params.value[0] / 100 * ', DEATH_TOTAL, ', 0) + "名")
      }
    ')))
})