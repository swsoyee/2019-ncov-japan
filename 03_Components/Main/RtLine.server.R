output$RtLine <- renderEcharts4r({
  input$generateRtLine
  isolate({
    # parameters
    mean_si <- input$RtLineMeanSi
    std_si <- input$RtLineStdSi
    selectedPref <- input$regionRtLinePicker

    incid <- as.incidence(rowSums(byDate[, selectedPref, with = FALSE]),
      dates = byDate$date
    )

    # handling ending date
    continuous <- continuousZero(incid$counts)
    index <- length(incid$counts) - continuous

    res <- suppressMessages(suppressWarnings(estimate_R(incid,
      method = "parametric_si",
      config = make_config(list(
        mean_si = mean_si,
        std_si = std_si,
        t_end = max(byDate$date)
      ))
    )))
    dt <- as.data.table(res$R)
    cols <- colnames(dt)
    dt[, (cols) := lapply(.SD, function(x) {
      return(round(x, 2))
    }), .SDcols = cols]
    dt$dates <- res$dates[res$R$t_end]
    dt$Incidence <- res$I[res$R$t_end]

    if (continuous > 7) {
      dt[index:nrow(dt), 3] <- 0
      dt[index:nrow(dt), 4] <- 0
      dt[index:nrow(dt), 6] <- 0
      dt[index:nrow(dt), 10] <- 0
    }

    dt %>%
      e_chart(dates) %>%
      e_line(
        serie = `Mean(R)`,
        itemStyle = list(color = darkNavy),
        symbolSize = 0,
        name = i18n$t("実効再生産数")
      ) %>%
      e_bar(
        serie = Incidence,
        y_index = 1,
        itemStyle = list(color = lightRed),
        barCategoryGap = "10%",
        name = i18n$t("症例数")
      ) %>%
      e_band(
        min = `Quantile.0.05(R)`,
        max = `Quantile.0.95(R)`,
        areaStyle = list(
          list(color = "rgba(0,0,0,0)"),
          list(color = lightNavy)
        )
      ) %>%
      e_tooltip(trigger = "axis") %>%
      e_datazoom(
        minValueSpan = 28,
        startValue = (max(dt$dates, na.rm = T) - 90)
      ) %>%
      e_legend(
        orient = "vertical",
        left = "12%",
        top = "15%"
      ) %>%
      e_y_axis(
        name = i18n$t("実効再生産数"),
        nameLocation = "middle",
        splitLine =
          list(lineStyle = list(opacity = 0.4)),
        z = 999,
        axisLabel = list(inside = T),
        axisTick = list(show = F)
      ) %>%
      e_y_axis(
        name = i18n$t("症例数"),
        nameGap = 10,
        splitLine = list(show = F),
        z = 999,
        index = 1,
        axisTick = list(show = F)
      ) %>%
      e_mark_line(
        data = list(yAxis = 1),
        symbolSize = 0,
        label = list(show = FALSE)
      ) %>%
      e_grid(
        left = "8%",
        right = "15%"
      ) %>%
      e_title(
        text = sprintf(
          i18n$t("実効再生産数：%s±%s（%s）"),
          tail(dt$`Mean(R)`, 1)[[1]],
          tail(dt$`Std(R)`, 1)[[1]],
          tail(dt$dates, 1)[[1]]
        ),
        subtext = sprintf(
          i18n$t("発症間隔：%s±%s"),
          mean_si, std_si
        )
      )
  })
})

observeEvent(input$presetRtLineOption, {
  if (input$presetRtLineOption == "nishiura") {
    updateSliderInput(
      inputId = "RtLineMeanSi",
      session = session,
      value = 4.6
    )
    updateSliderInput(
      inputId = "RtLineStdSi",
      session = session,
      value = 2.6
    )
  }
  if (input$presetRtLineOption == "ali") {
    updateSliderInput(
      inputId = "RtLineMeanSi",
      session = session,
      value = 4.7
    )
    updateSliderInput(
      inputId = "RtLineStdSi",
      session = session,
      value = 2.9
    )
  }
})
