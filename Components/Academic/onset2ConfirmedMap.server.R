observeEvent(input$sideBarTab, {
  if (input$sideBarTab == "academic" && is.null(GLOBAL_VALUE$Academic[[1]])) {
    GLOBAL_VALUE$Academic <- list(
      onSet2ConfirmedMap = fread(paste0(DATA_PATH, "/Academic/onset2ConfirmedMap.csv"))
    )
  }
  # data <- fread(paste0(DATA_PATH, '/Academic/onset2ConfirmedMap.csv')) # TEST
})

output$onSet2ConfirmedMap <- renderEcharts4r({
  data <- GLOBAL_VALUE$Academic$onSet2ConfirmedMap
  if (!is.null(data)) {
    nameMap <- as.list(data$ja)
    names(nameMap) <- data$`name-en`
    maxPref <- data[発症から診断までの平均日数 == max(発症から診断までの平均日数, na.rm = T)]
    minPref <- data[発症から診断までの平均日数 == min(発症から診断までの平均日数, na.rm = T)]
    data %>%
      e_charts(ja) %>%
      em_map("Japan") %>%
      e_map(
        発症から診断までの平均日数,
        map = "Japan",
        name = "感染確認数",
        nameMap = nameMap,
        layoutSize = "50%",
        center = c(137.1374062, 36.8951298),
        zoom = 1.5,
        itemStyle = list(
          borderWidth = 0.2,
          borderColor = "white"
        ),
        emphasis = list(label = list(fontSize = 8)),
        roam = "move"
      ) %>%
      e_visual_map(
        発症から診断までの平均日数,
        top = "20%",
        left = "0%",
        inRange = list(color = c("#EEEEEE", lightYellow, darkRed)),
        type = "piecewise",
        splitList = list(
          list(min = 7),
          list(min = 6, max = 7),
          list(min = 5, max = 6),
          list(min = 0, max = 5),
          list(value = 0, label = "データなし")
        )
      ) %>%
      e_color(background = "#FFFFFF") %>%
      e_tooltip(
        formatter = htmlwidgets::JS(
          '
        function(params) {
          if(params.value) {
            return(`${params.name}<br>平均所要${Math.round(params.value * 100) / 100}日`)
          } else {
            return("");
          }
        }
      '
        )
      ) %>%
      e_title(
        text = "発症から診断までの平均日数マップ",
        subtext = paste0(
          "最長：", maxPref$ja, maxPref$発症から診断までの平均日数,
          "日　最短：", minPref$ja, minPref$発症から診断までの平均日数,
          "日\n\nデータ：SIGNATE COVID-19 Case Dataset"
        ),
        sublink = "https://docs.google.com/spreadsheets/d/10MFfRQTblbOpuvOs_yjIYgntpMGBg592dL8veXoPpp4/edit#gid=0"
      )
  }
})