# ====UI====
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

# ====DATA====
confirmedDataByDate <- reactive({
  dt <- data.table(byDate)
  dt$都道府県 <- rowSums(byDate[, c(2:48)])
  if(!is.null(input$regionPicker)) {
    dt <- dt[, c('date', input$regionPicker), with = F]
    # dt <- dt[, c('date', '北海道', '東京', '神奈川')] # TEST
    dt$total <- cumsum(rowSums(dt[, 2:ncol(dt)]))
    dt[, difference := total - shift(total)]
    setnafill(dt, fill = 0)
    dt
  } else {
    dt[, 1, with = F] # 日付のカラムだけを返す
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
    ) %>%
    e_mark_line(
      data = list(
        list(
          coord = c(0, 10),
          symbol = 'none'
        ),
        list(
          coord = c(9.5, 10*2^9.5),
          symbol = 'none',
          name = '１日２倍'
        )
      )
    ) %>%
    e_mark_line(
      data = list(
        list(
          coord = c(0, 10),
          symbol = 'none'
        ),
        list(
          coord = c(28.5, 10*2^9.5),
          symbol = 'none',
          name = '３日２倍'
        )
      )
    ) %>%
    e_mark_line(
      data = list(
        list(
          coord = c(0, 10),
          symbol = 'none'
        ),
        list(
          coord = c(56, 10*2^8),
          symbol = 'none',
          name = '１週間２倍'
        )
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


output$confirmedCalendar <- renderEcharts4r({
  dt <- confirmedDataByDate()
  if (length(confirmedDataByDate()) > 1) {
    maxValue <- max(dt$difference)
    dt %>%
      e_charts(date) %>%
      e_calendar(
        range = c('2020-02-01', '2020-07-30'),
        top = 25,
        left = 25,
        cellSize = 15,
        splitLine = list(show = F),
        itemStyle = list(borderWidth = 2, borderColor = '#FFFFFF'),
        dayLabel = list(nameMap = c('日', '月', '火', '水', '木', '金', '土')),
        monthLabel = list(nameMap = 'cn')
      ) %>%
      e_heatmap(difference, coord_system = "calendar") %>%
      e_legend(show = T) %>%
      e_visual_map(
        top = '2%',
        show = F,
        max = maxValue,
        inRange = list(color = c('#FFFFFF', middleRed, darkRed)),
        # scale colors
      ) %>%
      e_tooltip(formatter = htmlwidgets::JS('
        function(params) {
          return(`${params.value[0]}<br>新規${params.value[1]}人`)
        }
      '))
  } else {
    return()
  }
})