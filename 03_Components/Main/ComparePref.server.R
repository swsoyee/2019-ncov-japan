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
      陽性者,
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
      陽性者,
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
    e_bar(陽性者,
      name = i18n$t("陽性者数"),
      itemStyle = list(color = middleRed)
    ) %>%
    e_bar(
      死亡者,
      name = i18n$t("死亡者数"),
      itemStyle = list(color = darkNavy),
      barGap = "-100%",
      stack = 1
    ) %>%
    e_bar(
      重症者,
      name = i18n$t("重症者数"),
      itemStyle = list(color = darkRed),
      barGap = "-100%",
      stack = 1
    ) %>%
    e_bar(
      退院者,
      name = i18n$t("回復者数"),
      itemStyle = list(color = middleGreen),
      barGap = "-100%",
      stack = 1
    ) %>%
    e_title(text = i18n$t("陽性・回復・死亡（厚労省）")) %>%
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
  mhlw<- mhlwSummary[都道府県名 == pref]
  dt <- merge(
    x = realtime,
    y = mhlw,
    by = "日付",
    all = T,
    sort = F
  )
  dt[, 陽性率 := round(陽性者 / 検査人数 * 100, 2)]
  dt[, 速報陽性累積 := cumsum(速報患者)]
  dt[, 速報死亡累積 := cumsum(速報死亡)]
  return(dt)
})

radarDataset <- reactive({
  mhlwDt <- mhlwSummary[分類 == 0 & 都道府県名 != "伊客船"][provinceCode, 人口 := i.pop, on = c(都道府県名 = "name-ja")]
  mhlwDt <- mhlwDt[, .(日付 = week(日付), 都道府県名,
                         検査人数 = frollmean(検査人数 - shift(検査人数), n = 7, fill = 0, na.rm = T),
                         百万人あたりの検査 = frollmean(検査人数 - shift(検査人数), n = 7, fill = 0, na.rm = T) / 人口 * 1000000,
                         陽性者 = frollmean(陽性者 - shift(陽性者), n = 7, fill = 0, na.rm = T),
                         陽性率 = 陽性者 / 検査人数 * 100,
                         回復率 = 退院者 / 陽性者 * 100,
                         回復死亡比 = 退院者 / 死亡者,
                         死亡率 = 死亡者 / 陽性者 * 100
  )]
  mhlwDt
})

output$prefRadar <- renderEcharts4r({
  mhlwDt <- radarDataset()

  # input <- list(comparePref = "千葉") # TEST
  
  monthDt <- mhlwDt[都道府県名 %in% input$comparePref, .SD[seq(.N, to = .N-26, by = -7)]]
  
  t <- dcast(melt(monthDt, 
                  id.vars = "日付", 
                  measure.vars = c("検査人数", "百万人あたりの検査", "陽性者", "陽性率", "回復率", "回復死亡比", "死亡率")
  ), variable ~ 日付)
  
  colnames(t) <- c("指標", "三週間前", "二週間前", "一週間前", "現在")
  
  t %>%
    e_chart(指標) %>%
    e_radar(三週間前, symbol = "circle", symbolSize = 1, name = i18n$t("三週間前")) %>%
    e_radar(二週間前, name = i18n$t("二週間前")) %>%
    e_radar(一週間前, name = i18n$t("一週間前")) %>%
    e_radar(現在, name = i18n$t("現在")) %>%
    e_radar_opts(indicator = list(
      list(name = i18n$t("検査人数"), max = max(monthDt$検査人数)),
      list(name = i18n$t("百万人あたりの検査"), max = max(monthDt$百万人あたりの検査)),
      list(name = i18n$t("陽性者"), max = max(monthDt$陽性者)),
      list(name = i18n$t("陽性率"), max = max(monthDt$陽性率)),
      list(name = i18n$t("回復率"), max = 100),
      list(name = i18n$t("回復 / 死亡"), max = max(monthDt$回復死亡比)),
      list(name = i18n$t("死亡率"), max = 10)
    )) %>%
    e_tooltip() %>% e_color(
      c("#F7DDBD", "#E8AD84", "#B03C2D", "#591F17")
    ) %>%
    e_legend(bottom = "0%") %>%
    e_title(text = sprintf(i18n$t("%sの直近１ヶ月の指標"), i18n$t(input$comparePref)))
})