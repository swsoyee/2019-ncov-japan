# ====退院推移図データセット====
recoveredData <- reactive({
  dataset <- mhlwSummary[, .(
    陽性者  = sum(陽性者, na.rm = T),
    回復者  = sum(退院者, na.rm = T),
    重症者  = sum(重症者, na.rm = T),
    死亡者  = sum(死亡者, na.rm = T)
  ), by = "日付"]
  dataset <-
    merge(
      dataset,
      confirmingData,
      all.x = T,
      by.x = "日付",
      by.y = "date"
    )
  dataset[dailyReport, 重症者 := 重症者 + i.severe.d, on = c(日付 = "date")]
  # 突合中の退院者データにチャーター便と空港検疫の分（17）を追加して、総数と見なす
  dataset[, domesticDischarged := domesticDischarged + 17]
  dataset[, 回復突合中 := domesticDischarged - 回復者]
  # 訳わからないマイナスの値があるため、削除
  dataset[回復突合中 < 0, 回復突合中 := NA]
  dataset[, 死亡突合中 := domesticDeath - 死亡者]
  # 2020-05-09仕様変更
  dataset[日付 %in% as.Date(c("2020-05-09", "2020-04-22")), `:=`(回復突合中 = 0, 死亡突合中 = 0)]
  dataset
})

# ====退院推移図====
output$recoveredLine <- renderEcharts4r({
  # dt <- dataset
  dataset <- recoveredData()

  dataset %>%
    e_chart(日付) %>%
    e_line(
      陽性者,
      name = i18n$t("PCR検査陽性"),
      itemStyle = list(normal = list(color = lightRed)),
      areaStyle = list(opacity = 0.4),
      symbol = "circle",
      symbolSize = 1
    ) %>%
    e_line(
      死亡者,
      name = i18n$t("死亡"),
      stack = "1",
      itemStyle = list(normal = list(color = darkNavy)),
      areaStyle = list(opacity = 0.4),
      symbol = "circle",
      symbolSize = 1
    ) %>%
    e_line(
      死亡突合中,
      name = i18n$t("死亡（突合作業中）"),
      stack = "1",
      itemStyle = list(normal = list(color = darkNavy)),
      areaStyle = list(opacity = 0.4),
      symbol = "circle",
      symbolSize = 1
    ) %>%
    e_line(
      重症者,
      name = i18n$t("重症"),
      stack = "1",
      itemStyle = list(normal = list(color = darkRed)),
      areaStyle = list(opacity = 0.4),
      symbol = "circle",
      symbolSize = 1
    ) %>%
    e_line(
      回復者,
      name = i18n$t("回復"),
      stack = "1",
      itemStyle = list(normal = list(color = middleGreen)),
      areaStyle = list(opacity = 0.4),
      symbol = "circle",
      symbolSize = 1
    ) %>%
    e_line(
      回復突合中,
      name = i18n$t("回復（突合作業中）"),
      stack = "1",
      itemStyle = list(normal = list(color = middleGreen)),
      areaStyle = list(opacity = 0.4),
      symbol = "circle",
      symbolSize = 1
    ) %>%
    e_x_axis(
      splitLine = list(show = F),
      splitLine = list(lineStyle = list(opacity = 0.2))
    ) %>%
    e_y_axis(
      splitLine = list(show = F),
      axisLabel = list(inside = T),
      splitLine = list(lineStyle = list(opacity = 0.2)),
      z = 999,
      axisTick = list(show = F)
    ) %>%
    e_y_axis(
      splitLine = list(show = F),
      index = 1,
      splitLine = list(lineStyle = list(opacity = 0.2)),
      z = 999,
      axisTick = list(show = F)
    ) %>%
    e_grid(left = "3%", bottom = "18%") %>%
    e_legend(
      type = "scroll",
      orient = "vertical",
      left = "18%",
      top = "15%",
      right = "15%"
    ) %>%
    e_title(i18n$t("回復・重症・死亡")) %>%
    e_tooltip(trigger = "axis") %>%
    e_datazoom(
      minValueSpan = 3600 * 24 * 1000 * 7,
      bottom = "0%",
      startValue = max(dataset$日付, na.rm = T) - 28
    )
})

# ====退院タブのサマリー====
# TODO 意味が大きくない、見ている人が少ない？
output$dischargeSummary <- renderUI({
  tagList(tags$ol(
    tags$li(
      i18n$t(
        "令和2年4月22日から厚労省が公開している退院者・死亡者数には突合作業中の人数が含まれているため、入退院等の状況の合計とPCR検査陽性者数は一致していません。"
      ),
      tags$a(href = "https://www.mhlw.go.jp/stf/newpage_10989.html", icon("external-link"))
    ),
    tags$li(
      i18n$t(
        "令和2年5月8日公表分から、データソースを従来の厚生労働省が把握した個票を積み上げたものから、各自治体がウェブサイトで公表している数等を積み上げたものに変更した。"
      ),
      tags$a(href = "https://www.mhlw.go.jp/stf/newpage_11229.html", icon("external-link"))
    )
  ))
})


output$curedCalendar <- renderEcharts4r({
  dataset <- recoveredData()
  dataset[is.na(domesticDischarged), domesticDischarged := 回復者]
  dataset[, diff := domesticDischarged - shift(domesticDischarged)]
  dataset %>%
    e_charts(日付) %>%
    e_calendar(
      range = c("2020-02-01", "2020-07-30"),
      top = 25,
      left = 25,
      cellSize = 15,
      splitLine = list(show = F),
      itemStyle = list(borderWidth = 2, borderColor = "#FFFFFF"),
      dayLabel = list(nameMap = switch(
        languageSetting,
        "ja" = c("日", "月", "火", "水", "木", "金", "土"),
        "cn" = "cn",
        "en" = "en"
      )),
      monthLabel = list(nameMap = ifelse(languageSetting != "en", "cn", "en"))
    ) %>%
    e_heatmap(diff, coord_system = "calendar") %>%
    e_legend(show = F) %>%
    e_visual_map(
      top = "15%",
      max = 500,
      show = F,
      inRange = list(color = c("#FFFFFF", darkGreen)),
      # scale colors
    ) %>%
    e_tooltip(formatter = htmlwidgets::JS(
      sprintf(
        "
        function(params) {
          return(`${params.value[0]}<br>%s${params.value[1]}`)
        }
      ",
        paste0(i18n$t("新規"), " ")
      )
    ))
})
