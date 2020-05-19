observeEvent(input$sideBarTab, {
  if (input$sideBarTab == "fukuoka" && is.null(GLOBAL_VALUE$Fukuoka[[1]])) {
    # GLOBAL_VALUE <- list(Fukuoka = list(
    #   summary = NULL,
    #   patients = NULL,
    #   updateTime = NULL
    # )) # TEST

    fileList <- list.files(paste0(DATA_PATH, "Pref/Fukuoka/"))

    indexName <- c("patients")
    fileName <- c("patients.csv")

    for (i in 1:length(indexName)) {
      GLOBAL_VALUE$Fukuoka <- loadDataFromFile(
        fileList = fileList,
        FilePath = "Pref/Fukuoka/",
        fileName = fileName[i],
        object = GLOBAL_VALUE$Fukuoka,
        index = indexName[i]
      )
    }

    # GLOBAL_VALUE$Fukuoka$updateTime <- file.info(
    #   paste0(
    #     DATA_PATH,
    #     "Pref/Fukuoka/",
    #     fileList[sapply(fileList, function(x) {
    #       grepl("summary.csv", x)
    #     })]
    #   )
    # )$mtime
  }
})

output$FukuokaInfectedRoute <- renderEcharts4r({
  dt <- GLOBAL_VALUE$Fukuoka$patients
  dt <- dt[, lapply(.SD, function(x) {
    sum(x, na.rm = T)
  }),
  .SD = c("感染経路不明", "濃厚接触者", "海外渡航歴有"), by = "公表_年月日"
  ]
  dt[, 公表_年月日 := as.Date(公表_年月日)] %>%
    e_chart(公表_年月日) %>%
    e_bar(感染経路不明, stack = 1, itemStyle = list(color = "#E9546B")) %>%
    e_bar(濃厚接触者, stack = 1, itemStyle = list(color = "#025BAC")) %>%
    e_bar(海外渡航歴有, stack = 1, itemStyle = list(color = "#4C4C4C")) %>%
    e_x_axis(
      splitLine = list(
        lineStyle = list(opacity = 0.2)
      )
    ) %>%
    e_y_axis(
      splitLine = list(
        lineStyle = list(opacity = 0.2)
      ),
      axisLabel = list(inside = T),
      axisTick = list(show = F)
    ) %>%
    e_tooltip(trigger = "axis") %>%
    e_title(
      text = sprintf("%sの陽性患者の感染経路", i18n$t("福岡県")),
      subtext = paste0(sprintf("最終更新日：%s", max(GLOBAL_VALUE$Fukuoka$patients$公表_年月日)), "   ",
                       sprintf("計：%s名", sum(dt$感染経路不明, dt$濃厚接触者, dt$海外渡航歴有))),
    ) %>%
    e_legend(
      type = "scroll",
      orient = "vertical",
      left = "18%",
      top = "15%",
      right = "15%"
    ) %>%
    e_grid(
      left = "5%",
      right = "5%"
    )
})

output$FukuokaResidentialTreeMap <- renderEcharts4r({
  dt <- GLOBAL_VALUE$Fukuoka$patients
  dt <- data.table(
    gsub(pattern = "市", replacement = "市,", dt$居住地)
    )[, c("main", "sub") := tstrsplit(V1, ",", fixed=TRUE)]
  dt <- dt[, .(value = .N), by = c("main", "sub")]
  dt[is.na(sub),  sub := "内"]
  dt[, .(value = sum(value)), by = c("main", "sub")] %>%
    e_charts() %>%
    e_treemap(main, sub, value, upperLabel = list(show = T, color = "#222"),
              left = "1%", right = "1%", bottom = "10%") %>%
    e_title(text = "市区町村別の感染者数",
            subtext = paste0(sprintf("最終更新日：%s", max(GLOBAL_VALUE$Fukuoka$patients$公表_年月日)), "   ",
                             sprintf("計：%s名", sum(dt$value)))) %>%
    e_labels(formatter = htmlwidgets::JS(
      "
      function(param) {
        return(`${param.name}: ${param.value}`)
      }
      "
    ), position = "center")
})
  