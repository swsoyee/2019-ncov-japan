observeEvent(input$linePlot, {
  if ((input$linePlot == "vaccine") && is.null(GLOBAL_VALUE$vaccine)) {
    vaccine <- fread(file = "50_Data/MHLW/vaccine.csv")
    vaccine$date <- as.Date(as.character(vaccine$date), format = "%Y%m%d")
    GLOBAL_VALUE$vaccine <- vaccine
  }
})

output$vaccineLine <- renderEcharts4r({
  if (!is.null(GLOBAL_VALUE$vaccine)) {
    vaccine <- GLOBAL_VALUE$vaccine
    vaccine %>%
      e_chart(x = date) %>%
      e_bar(
        total,
        name = "合計",
        barGap = "-100%",
        itemStyle = list(
          color = darkBlue
        )
      ) %>%
      e_bar(
        first, 
        name = "１回目", 
        itemStyle = list(
          color = lightGreen
        ),
        stack = 1
      ) %>%
      e_bar(
        second,
        name = "２回目",
        itemStyle = list(
          color = darkGreen
        ),
        stack = 1
      ) %>%
      e_line(
        facility,
        name = "施設数",
        itemStyle = list(
          color = lightNavy
        )
      ) %>%
      e_grid(
        left = "3%",
        right = "15%",
        bottom = "18%"
      ) %>%
      e_x_axis(
        splitLine = list(
          lineStyle = list(opacity = 0.2)
        )
      ) %>%
      e_y_axis(
        name = "回数",
        nameGap = 10,
        nameTextStyle = list(padding = c(0, 0, 0, 50)),
        splitLine = list(lineStyle = list(opacity = 0.2)),
        z = 999,
        axisLabel = list(inside = T),
        axisTick = list(show = F)
      ) %>%
      e_title(
        text = "先行接種の接種実績"
      ) %>%
      e_legend(
        type = "scroll",
        orient = "vertical",
        left = "18%",
        top = "15%",
        right = "15%"
      ) %>%
      e_tooltip(trigger = "axis") %>%
      e_datazoom(
        minValueSpan = 604800000, #3600 * 24 * 1000 * 7,
        startValue = max(vaccine$date, na.rm = T) - 28
      )
  }
})
