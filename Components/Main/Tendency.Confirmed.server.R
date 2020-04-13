output$tendencyConfirmedRegionPicker <- renderUI({
  if (input$selectTendencyConfirmedMode == '一般') {
    return(
      pickerInput(
        inputId = 'regionPicker',
        # 地域選択
        label = lang[[langCode]][93],
        choices = regionName,
        selected = defaultSelectedRegionName,
        options = list(
          `actions-box` = TRUE,
          size = 10,
          # クリア
          `deselect-all-text` = lang[[langCode]][91],
          # 全部
          `select-all-text` = lang[[langCode]][92],
          # 三件以上選択されました
          `selected-text-format` = lang[[langCode]][94]
        ),
        multiple = T,
        width = '100%'
      )
    )
  } else {
    return()
  }
})

# ====新規感染者推移図（片対数）====
output$oneSideLogConfirmed <- renderEcharts4r({
  dt <- mapData[count > 10]
  dt[, index := 1:.N, by = ja]
  
  prefOver10 <- unique(dt[count > 10]$ja)
  dt <- dt[ja %in% prefOver10]
  
  regionCount <- dt[, .I[which.max(count)], by = ja]
  orderRegion <- dt[regionCount$V1][order(-count)]$ja
  mostNregion <- head(orderRegion, n = 7)
  regionName <- unique(dt$ja)
  unselected <- regionName[!(regionName %in% mostNregion)]
  unselected <- setNames(as.list(rep(F, length(unselected))),
                         unselected)
  
  dt[order(match(ja, orderRegion))] %>%
    group_by(ja) %>%
    e_chart(index) %>%
    e_line(count, symbol = 'circle') %>%
    e_y_axis(
      splitLine = list(lineStyle = list(opacity = 0.2)),
      name = '感染者数',
      type = 'log',
      axisLabel = list(inside = T),
      axisTick = list(show = F),
      nameGap = 10
    ) %>%
    e_x_axis(
      splitLine = list(lineStyle = list(opacity = 0.2)),
      name = '感染者が10人以上から経過した日数',
      nameLocation = 'center',
      nameGap = 25
    ) %>%
    e_tooltip(trigger = 'axis') %>%
    e_grid(bottom = '10%',
           right = '15%',
           left = '3%') %>%
    e_title(text = '100人以上の都道府県感染者数推移',) %>%
    e_legend(
      type = 'scroll',
      orient = 'vertical',
      right = '0%',
      top = '10%',
      selected = unselected,
      selector = list(
        list(type = 'all', title = '全'),
        list(type = 'inverse', title = '逆')
      )
    )
})

# ====新規感染者推移図（一般）====
output$confirmedLine <- renderEcharts4r({
  dt <- confirmedDataByDate()
  if (ncol(dt) > 1) {
    dt %>%
      e_charts(date) %>%
      e_line(
        total,
        name = '合計',
        itemStyle = list(normal = list(color = middleRed)),
        areaStyle = list(opacity = 0.4)
      ) %>%
      e_bar(
        difference,
        name = '新規感染者（日次）',
        y_index = 1,
        itemStyle = list(normal = list(color = middleRed)),
        areaStyle = list(opacity = 0.4)
      ) %>%
      e_grid(left = '3%',
             right = '15%',
             bottom = '10%') %>%
      e_x_axis(splitLine = list(lineStyle = list(opacity = 0.2))) %>%
      e_y_axis(
        name = '累積陽性者数',
        nameGap = 10,
        splitLine = list(lineStyle = list(opacity = 0.2)),
        axisLabel = list(inside = T),
        axisTick = list(show = F)
      ) %>%
      e_y_axis(
        name = '日次増加数',
        nameGap = 10,
        splitLine = list(show = F),
        index = 1,
        max = max(dt$difference, na.rm = T),
        axisTick = list(show = F)
      ) %>%
      e_title(text = '日次新規・累積陽性者の推移') %>%
      e_legend(
        type = 'scroll',
        orient = 'vertical',
        left = '10%',
        top = '15%',
        right = '15%'
      ) %>%
      e_tooltip(trigger = 'axis')
  }
})

output$confirmedLineWrapper <- renderUI({
  if (input$selectTendencyConfirmedMode == '一般') {
    if (is.null(input$regionPicker)) {
      tags$p('未選択です。地域を選択してください。')
    } else {
      echarts4rOutput('confirmedLine')
    }
  } else if (input$selectTendencyConfirmedMode == '片対数') {
    echarts4rOutput('oneSideLogConfirmed')
  }
})