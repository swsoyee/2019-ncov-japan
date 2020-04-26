output$confirmedHeatmap <- renderEcharts4r({
  data <- melt(byDate, id.vars = "date")
  data[variable %in% colnames(byDate)[2:48]] %>%
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
      right = "2%"
    ) %>%
    e_y_axis(
      position = "right",
      axisLabel = list(fontSize = 8, interval = 0),
      axisTick = list(show = F),
      inverse = T
    ) %>%
    e_datazoom(startValue = max(data$date, na.rm = T) - 70) %>%
    e_grid(right = "8%", bottom = "15%", left = "2%") %>%
    e_title(text = "日次都道府県別新規発生数") %>%
    e_tooltip()
})
