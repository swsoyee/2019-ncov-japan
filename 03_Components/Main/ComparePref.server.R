output$comparePrefP1 <- renderEcharts4r({
  pref <- input$comparePref
  dt <- compareDataset()
  dt %>%
    e_chart(日付) %>%
    e_line(
      速報陽性累積,
      name = i18n$t("速報値：陽性者数"),
      itemStyle = list(color = darkRed),
      symbol = "circle",
      symbolSize = 1
    ) %>%
    e_line(
      患者数,
      name = i18n$t("厚労省：陽性者数"),
      itemStyle = list(color = lightRed),
      symbol = "circle",
      symbolSize = 1
    ) %>%
    e_line(
      速報死亡累積,
      name = i18n$t("速報値：死亡者数"),
      itemStyle = list(color = darkNavy),
      y_index = 1,
      symbol = "circle",
      symbolSize = 1
    ) %>%
    e_line(
      死亡者,
      name = i18n$t("厚労省：死亡者数"),
      itemStyle = list(color = lightNavy),
      y_index = 1,
      symbol = "circle",
      symbolSize = 1
    ) %>%
    e_tooltip(trigger = "axis") %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), index = 1) %>%
    e_title(text = i18n$t("速報値と厚労省発表値の比較")) %>%
    e_legend(
      orient = "vertical",
      left = "15%",
      top = "15%"
    ) %>%
    e_datazoom(startValue = "2020-04-01", show = F) %>%
    e_grid(bottom = "4%", top = "18%") %>%
    e_group(paste0("compare_", pref))
})

output$comparePrefP2 <- renderEcharts4r({
  pref <- input$comparePref
  dt <- compareDataset()
  dt %>%
    e_chart(日付) %>%
    e_bar(検査人数,
      name = i18n$t("検査人数"),
      itemStyle = list(color = middleYellow)
    ) %>%
    e_bar(
      陽性者数,
      name = i18n$t("陽性者数"),
      itemStyle = list(color = middleRed),
      z = 2,
      barGap = "-100%"
    ) %>%
    e_line(
      陽性率,
      name = i18n$t("陽性率"),
      itemStyle = list(color = darkRed),
      y_index = 1
    ) %>%
    e_title(text = i18n$t("検査人数・陽性者数（厚労省）")) %>%
    e_tooltip(trigger = "axis") %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F)) %>%
    e_y_axis(
      splitLine = list(show = F),
      index = 1,
      max = 50
    ) %>%
    e_legend(
      orient = "vertical",
      left = "15%",
      top = "15%"
    ) %>%
    e_datazoom(startValue = "2020-04-01", show = F) %>%
    e_grid(bottom = "4%", top = "18%") %>%
    e_group(paste0("compare_", pref))
})
output$comparePrefP3 <- renderEcharts4r({
  pref <- input$comparePref
  dt <- compareDataset()
  dt %>%
    e_chart(日付) %>%
    e_bar(患者数,
      name = i18n$t("陽性者数"),
      itemStyle = list(color = middleRed)
    ) %>%
    e_bar(
      死亡者,
      name = i18n$t("死亡者数"),
      itemStyle = list(color = darkNavy),
      stack = 1
    ) %>%
    e_bar(
      退院者,
      name = i18n$t("退院者数"),
      itemStyle = list(color = middleGreen),
      barGap = "-100%",
      stack = 1
    ) %>%
    e_title(text = i18n$t("陽性・退院・死亡（厚労省）")) %>%
    e_tooltip(trigger = "axis") %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F)) %>%
    e_legend(
      orient = "vertical",
      left = "15%",
      top = "15%"
    ) %>%
    e_datazoom(startValue = "2020-04-01") %>%
    e_grid(top = "18%") %>%
    e_group(paste0("compare_", pref)) %>%
    e_connect_group(paste0("compare_", pref))
})

compareDataset <- reactive({
  pref <- input$comparePref
  realtime <- data.table(
    日付 = byDate$date,
    速報患者 = byDate[[pref]],
    速報死亡 = death[[pref]]
  )
  mhlw <-
    merge(
      x = detailByRegion[都道府県名 == pref],
      y = pcrByRegion[都道府県略称 == pref],
      by = "日付",
      all = T,
      sort = F
    )
  dt <- merge(
    x = realtime,
    y = mhlw,
    by = "日付",
    all = T,
    sort = F
  )
  dt[, 陽性率 := round(陽性者数 / 検査人数 * 100, 2)]
  dt[, 速報陽性累積 := cumsum(速報患者)]
  dt[, 速報死亡累積 := cumsum(速報死亡)]
  return(dt)
})
