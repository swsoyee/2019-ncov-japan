# 日次都道府県別新規発生数 ====
output$confirmedHeatmap <- renderEcharts4r({
  data <- melt(byDate, id.vars = "date")
  data <- data[variable %in% colnames(byDate)[2:48]]
  data[, variable := sapply(as.character(variable), i18n$t)]
  data %>%
    e_chart(date) %>%
    e_heatmap(variable, value, label = list(show = T, fontSize = 5)) %>%
    e_visual_map(
      value,
      inRange = list(color = c("#F6F7FA", middleYellow, darkRed)),
      type = "piecewise",
      splitList = list(
        list(min = 50),
        list(min = 20, max = 50),
        list(min = 10, max = 20),
        list(min = 5, max = 10),
        list(min = 0, max = 5),
        list(value = 0)
      ),
      orient = "horizontal",
      top = "5%",
      left = "1%"
    ) %>%
    e_y_axis(
      position = "right",
      axisLabel = list(fontSize = 8, interval = 0),
      axisTick = list(show = F),
      inverse = T
    ) %>%
    e_datazoom(startValue = max(data$date, na.rm = T) - 70) %>%
    e_mark_line(
      data = list(
        xAxis = "2020-04-07",
        label = list(
          formatter = i18n$t("4月7日\n緊急事態宣言"),
          position = "start"
        )
      ),
      lineStyle = list(opacity = 0.5),
      silent = T,
      symbol = "circle",
      symbolSize = 4
    ) %>%
    e_grid(
      right = "8%",
      bottom = "15%",
      left = "2%"
    ) %>%
    e_title(text = i18n$t("日次都道府県別新規発生数")) %>%
    e_tooltip(
      formatter = htmlwidgets::JS(
        "
      function(params) {
        console.log(params)
        return(`${params.value[0]}<br>${params.value[1]}：${Math.round(params.value[2])}",
        i18n$t("名"),
        "`)
      }
    "
      )
    )
})

# 倍加時間の経時的変化====
output$confirmedHeatmapDoublingTime <- renderEcharts4r({
  dt <- byDate[, lapply(.SD, cumsum), .SDcols = 2:ncol(byDate)]

  dt <- dt[, lapply(.SD, function(x) {
    7 * log(2) / (log(x / shift(x, n = 7)))
  })]
  dt$date <- byDate$date

  dt <- melt(dt, id.vars = "date")
  dt <- dt[variable %in% colnames(byDate)[2:48]]
  dt[, variable := sapply(as.character(variable), i18n$t)]
  dt %>%
    e_chart(date) %>%
    e_heatmap(
      variable,
      value,
      label = list(
        show = T,
        fontSize = 5,
        formatter = htmlwidgets::JS(
          "
              function(params) {
                return(Math.round(Number(params.value[2])))
              }
          "
        )
      ),
      itemStyle = list(borderWidth = 1, borderColor = "rgb(255, 255, 255, 0.2)")
    ) %>%
    e_visual_map(
      value,
      inRange = list(
        color = c(
          "white",
          darkRed,
          middleRed,
          middleYellow,
          lightYellow,
          "#F6F7FA"
        )
      ),
      type = "piecewise",
      splitList = list(
        list(min = 12),
        list(min = 7, max = 12),
        list(min = 5, max = 7),
        list(min = 3, max = 5),
        list(min = 0, max = 3),
        list(value = 0)
      ),
      orient = "horizontal",
      top = "5%",
      left = "1%"
    ) %>%
    e_y_axis(
      position = "right",
      axisLabel = list(fontSize = 8, interval = 0),
      axisTick = list(show = F),
      inverse = T
    ) %>%
    e_datazoom(startValue = max(dt$date, na.rm = T) - 70) %>%
    e_mark_line(
      data = list(
        xAxis = "2020-04-07",
        label = list(
          formatter = i18n$t("4月7日\n緊急事態宣言"),
          position = "start"
        )
      ),
      lineStyle = list(opacity = 0.5),
      silent = T,
      symbol = "circle",
      symbolSize = 4
    ) %>%
    e_grid(
      right = "8%",
      bottom = "15%",
      left = "2%"
    ) %>%
    e_title(text = sprintf(i18n$t("倍加時間の経時的変化（直近%s日間で計算）"), 7)) %>%
    e_tooltip(
      formatter = htmlwidgets::JS(
        "
      function(params) {
        console.log(params)
        return(`${params.value[0]}<br>${params.value[1]}：${Math.round(params.value[2])}",
        i18n$t("日"),
        "`)
      }
    "
      )
    )
})

output$confirmedHeatmapWrapper <- renderUI({
  if (input$confirmedHeatmapSelector == "confirmedHeatmap") {
    echarts4rOutput("confirmedHeatmap", height = "600px")
  } else if (input$confirmedHeatmapSelector == "confirmedHeatmapDoublingTime") {
    echarts4rOutput("confirmedHeatmapDoublingTime", height = "600px")
  }
})

output$confirmedHeatmapDoublingTimeOptions <- renderUI({
  if (input$confirmedHeatmapSelector == "confirmedHeatmapDoublingTime") {
    tagList(
      tags$p(i18n$t("日数の計算式は以下になります：")),
      withMathJax("$$7log2 \\div log(\\frac{day_7N}{day_0N})$$"),
      helpText(i18n$t("N：累積感染者数"))
    )
  }
})
