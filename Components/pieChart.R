# ====確認数扇形図====
output$confirmedPiePlus <- renderEcharts4r({
  CONFIRMED_PIE_DATA %>%
    e_charts(category) %>%
    e_pie(
      value,
      minAngle = 15,
      itemStyle = list(color = '#DD4B38'),
      name = lang[[langCode]][9],
      animationType = 'scale',
      labelLine = list(show = F),
      label = list(position = 'inner', formatter = '{d}%'),
      radius = '85%',
      animationEasing = 'elasticOut'
    ) %>%
    e_visual_map(
      show = F,
      min = 0,
      max = 2000,
      inRange = list(colorLightness = c(0.3, 1))
    ) %>%
    e_legend(show = F) %>%
    e_tooltip()
})

# ====退院数扇形図====
output$curedPiePlus <- renderEcharts4r({
  CURED_PIE_DATA %>%
    e_charts(category) %>%
    e_pie(
      value,
      itemStyle = list(color = '#00a65a'),
      name = lang[[langCode]][6],
      animationType = 'scale',
      labelLine = list(show = F),
      label = list(position = 'inner', formatter = '{d}%'),
      radius = '85%',
      animationEasing = 'elasticOut'
    ) %>%
    e_visual_map(
      show = F,
      min = 0,
      max = 200,
      inRange = list(colorLightness = c(0.3, 1))
    ) %>%
    e_legend(show = F) %>%
    e_tooltip()
})

# ====死亡数扇形図====
output$deathPiePlus <- renderEcharts4r({
  DEATH_PIE_DATA %>%
    e_charts(category) %>%
    e_pie(
      value,
      itemStyle = list(color = '#34495E'),
      minShowLabelAngle = 200,
      name = lang[[langCode]][6],
      animationType = 'scale',
      labelLine = list(show = F),
      label = list(position = 'inner', formatter = '{d}%'),
      radius = '85%',
      animationEasing = 'elasticOut'
    ) %>%
    e_visual_map(
      show = F,
      min = 0,
      max = 10,
      inRange = list(colorLightness = c(0.2, 0.8))
    ) %>%
    e_legend(show = F) %>%
    e_tooltip()
})

# ====区域ごとの確認数====
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
