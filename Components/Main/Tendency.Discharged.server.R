# ====退院タブのサマリー====
# TODO 意味が大きくない、見ている人が少ない？
output$dischargeSummary <- renderUI({
  dt <- dischargeData()[nrow(dischargeData())]
  tagList(
    tags$b(dt$date, "のサマリー"),
    tags$li("退院率：", round(dt$discharge / dt$positive * 100, 2), "%"),
    tags$li("重傷率：", round(dt$sever / dt$positive * 100, 2), "%"),
    tags$li("死亡率：", round(dt$death / dt$positive * 100, 2), "%"),
    tags$hr(),
  )
})

# ====退院推移図====
output$recoveredLine <- renderEcharts4r({
  # dt <- dataset
  dt <- dischargeData()

  dt[, diff := discharge - shift(discharge)]
  setnafill(dt, fill = 0)

  defaultUnselected <- list(F, F, F, F)
  names(defaultUnselected) <-
    c("軽〜中等症の者", "新規退院者（日次）", "重症者", "死亡者")
  dt %>%
    e_chart(date) %>%
    e_line(
      positive,
      name = "PCR検査陽性者",
      itemStyle = list(normal = list(color = lightRed)),
      areaStyle = list(opacity = 0.4)
    ) %>%
    e_line(
      discharge,
      name = "退院者",
      stack = "1",
      itemStyle = list(normal = list(color = middleGreen)),
      areaStyle = list(opacity = 0.4)
    ) %>%
    e_bar(
      diff,
      name = "新規退院者（日次）",
      y_index = 1,
      itemStyle = list(normal = list(color = middleGreen)),
      areaStyle = list(opacity = 0.4)
    ) %>%
    e_line(
      mild,
      name = "軽〜中等症の者",
      stack = "1",
      itemStyle = list(normal = list(color = middleYellow)),
      areaStyle = list(opacity = 0.4)
    ) %>%
    e_line(
      severe,
      name = "重症者",
      stack = "1",
      itemStyle = list(normal = list(color = darkRed)),
      areaStyle = list(opacity = 0.4)
    ) %>%
    e_line(
      death,
      name = "死亡者",
      stack = "1",
      itemStyle = list(normal = list(color = darkNavy)),
      areaStyle = list(opacity = 0.4)
    ) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(
      splitLine = list(show = F),
      axisLabel = list(inside = T),
      axisTick = list(show = F)
    ) %>%
    e_y_axis(
      splitLine = list(show = F),
      index = 1,
      axisTick = list(show = F)
    ) %>%
    e_grid(left = "3%") %>%
    e_legend(
      type = "scroll",
      orient = "vertical",
      left = "10%",
      top = "15%",
      selected = defaultUnselected
    ) %>%
    e_title(subtext = "厚生労働省が毎日１２時にまとめているデータを使用しているため、遅れがあります。") %>%
    e_tooltip(trigger = "axis")
})

output$curedCalendar <- renderEcharts4r({
  dt <- data.table(
    "date" = domesticDailyReport$date,
    "discharge" = dischargeData()$discharge
  )
  dt[, diff := discharge - shift(discharge)]
  setnafill(dt, fill = 0)
  maxValue <- max(dt$diff)
  dt %>%
    e_charts(date) %>%
    e_calendar(
      range = c("2020-02-01", "2020-07-30"),
      top = 25,
      left = 25,
      cellSize = 15,
      splitLine = list(show = F),
      itemStyle = list(borderWidth = 2, borderColor = "#FFFFFF"),
      dayLabel = list(nameMap = c("日", "月", "火", "水", "木", "金", "土")),
      monthLabel = list(nameMap = "cn")
    ) %>%
    e_heatmap(diff, coord_system = "calendar", name = lang[[langCode]][80]) %>%
    e_legend(show = F) %>%
    e_visual_map(
      top = "15%",
      max = maxValue,
      show = F,
      inRange = list(color = c("#FFFFFF", darkGreen)),
      # scale colors
    ) %>%
    e_tooltip()
})

# TODO まだ実装されてない
output$todayCured <- renderUI({
  tagList(
    tags$b(lang[[langCode]][78]),
    dashboardLabel(lang[[langCode]][87], status = "success", style = "square")
  )
})

# ====退院者割合====
# TODO 意味なさそう、削除または改修予定
output$curedBar <- renderEcharts4r({
  dt <- data.table(
    "label" = "退院者",
    "domestic" = DISCHARGE_WITHIN$final,
    "flight" = DISCHARGE_FLIGHT$final,
    "airport" = DISCHARGE_AIRPORT$final,
    "ship" = DISCHARGE_SHIP$final,
    "domesticPer" = round(DISCHARGE_WITHIN$final / DISCHARGE_TOTAL * 100, 2),
    "flightPer" = round(DISCHARGE_FLIGHT$final / DISCHARGE_TOTAL * 100, 2),
    "airportPer" = round(DISCHARGE_AIRPORT$final / DISCHARGE_TOTAL * 100, 2),
    "shipPer" = round(DISCHARGE_SHIP$final / DISCHARGE_TOTAL * 100, 2)
  )
  e_charts(dt, label) %>%
    e_bar(domesticPer,
      name = lang[[langCode]][4], # 国内事例
      stack = "1", itemStyle = list(color = lightGreen)
    ) %>%
    e_bar(airportPer,
      name = "空港検疫",
      stack = "1", itemStyle = list(color = middleGreen)
    ) %>%
    e_bar(flightPer,
      name = lang[[langCode]][36], # チャーター便 （症状あり）
      stack = "1", itemStyle = list(color = darkGreen)
    ) %>%
    e_bar(shipPer,
      name = lang[[langCode]][35], # クルーズ船
      stack = "1", itemStyle = list(color = middleGreen)
    ) %>%
    e_y_axis(max = 100, splitLine = list(show = F), show = F) %>%
    e_x_axis(splitLine = list(show = F), show = F) %>%
    e_grid(left = "0%", right = "0%", top = "0%", bottom = "0%") %>%
    e_labels(position = "inside", formatter = htmlwidgets::JS('
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
    e_tooltip(formatter = htmlwidgets::JS(paste0(
      '
      function(params) {
        return("<b>" + params.seriesName + "</b><br>" + Math.round(params.value[0] / 100 * ',
      DISCHARGE_TOTAL, ', 0) + "名 (" + params.value[0] + "%)")
      }
    '
    )))
})