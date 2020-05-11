# ====PCR検査数の推移図データセット====
pcrData <- reactive({
  dt <-
    rbind(
      dailyReport[, .(
        日付 = date,
        国内 = pcr.d,
        チャーター便 = pcr.f,
        空港検疫 = pcr.x,
        クルーズ船 = pcr.y
      )],
      cbind(
        mhlwSummary[日付 > "2020-05-08" &
          分類 == 0][, .(
          国内 = sum(検査人数),
          チャーター便 = 829,
          クルーズ船 = 3618
        ), by = "日付"],
        mhlwSummary[日付 > "2020-05-08" &
          分類 == 1][, .(空港検疫 = 検査人数)]
      )
    )
  # input <- list(pcrRegionSelection = c("国内", "チャーター便"), testDaySpan = 7) # TEST
  dt$合計 <- rowSums(dt[, input$pcrRegionSelection, with = F], na.rm = T)
  dt[, diff := 合計 - shift(合計)]
})

# ====PCR検査数====
output$pcrLine <- renderEcharts4r({
  dt <- pcrData()
  dt$ma <- round(frollmean(dt$diff, n = input$testDaySpan, fill = 0), 2)
  dt %>%
    e_chart(日付) %>%
    e_bar(
      合計,
      name = i18n$t("累積"),
      itemStyle = list(color = lightYellow)
    ) %>%
    e_bar(
      diff,
      name = i18n$t("新規"),
      itemStyle = list(color = darkYellow),
      z = 2, barGap = "-100%"
    ) %>%
    e_line(ma, name = sprintf(i18n$t("%s日移動平均"), input$testDaySpan), y_index = 1, symbol = "none", smooth = T, itemStyle = list(color = darkRed)) %>%
    e_x_axis(splitLine = list(lineStyle = list(opacity = 0.2))) %>%
    e_y_axis(
      name = i18n$t("検査人数"),
      nameGap = 10,
      nameTextStyle = list(padding = c(0, 0, 0, 50)),
      splitLine = list(lineStyle = list(opacity = 0.2)),
      z = 999,
      axisLabel = list(inside = T),
      # min = -5000,
      axisTick = list(show = F)
    ) %>%
    e_y_axis(
      name = i18n$t("移動平均新規数"),
      nameGap = 10,
      splitLine = list(show = F),
      z = 999,
      index = 1,
      min = -250,
      axisTick = list(show = F)
    ) %>%
    e_grid(
      left = "3%",
      right = "15%",
      bottom = "18%"
    ) %>%
    e_legend(
      type = "scroll",
      orient = "vertical",
      left = "18%",
      top = "15%",
      right = "15%"
    ) %>%
    e_legend_unselect(
      name = i18n$t("累積")
    ) %>%
    e_tooltip(trigger = "axis") %>%
    e_title(text = i18n$t("日次新規・累積検査人数の推移")) %>%
    e_datazoom(
      minValueSpan = 3600 * 24 * 1000 * 7,
      bottom = "0%",
      startValue = max(dt$日付, na.rm = T) - 28
    )
})
