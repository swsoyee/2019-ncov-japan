observeEvent(input$sideBarTab, {
  if (input$sideBarTab == "fukuoka" && is.null(GLOBAL_VALUE$Fukuoka[[1]])) {
    # GLOBAL_VALUE <- list(Fukuoka = list(
    #   summary = NULL,
    #   patients = NULL,
    #   updateTime = NULL,
    #   nodes = NULL,
    #   edges = NULL,
    #   call = NULL
    # )) # TEST

    fileList <- list.files(paste0(DATA_PATH, "Pref/Fukuoka/"))

    indexName <- c("patients", "nodes", "edges", "call")
    fileName <- c("patients.csv", "nodes.csv", "edges.csv", "call.csv")

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
      subtext = paste0(
        sprintf("最終更新日：%s", max(GLOBAL_VALUE$Fukuoka$patients$公表_年月日)), "   ",
        sprintf("計：%s名", sum(dt$感染経路不明, dt$濃厚接触者, dt$海外渡航歴有))
      ),
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
    ) %>%
    e_group("fukuokaBar")
})

output$FukuokaResidentialTreeMap <- renderEcharts4r({
  dt <- GLOBAL_VALUE$Fukuoka$patients
  dt <- data.table(
    gsub(pattern = "市", replacement = "市,", dt$居住地)
  )[, c("main", "sub") := tstrsplit(V1, ",", fixed = TRUE)]
  dt <- dt[, .(value = .N), by = c("main", "sub")]
  dt[is.na(sub), sub := "内"]
  dt[, .(value = sum(value)), by = c("main", "sub")] %>%
    e_charts() %>%
    e_treemap(main, sub, value,
      upperLabel = list(show = T, color = "#222"),
      left = "1%", right = "1%", bottom = "10%"
    ) %>%
    e_title(
      text = "市区町村別の感染者数",
      subtext = paste0(
        sprintf("最終更新日：%s", max(GLOBAL_VALUE$Fukuoka$patients$公表_年月日)), "   ",
        sprintf("計：%s名", sum(dt$value))
      )
    ) %>%
    e_tooltip() %>%
    e_labels(formatter = htmlwidgets::JS(
      "
      function(param) {
        return(`${param.name}: ${param.value}`)
      }
      "
    ), position = "center")
})

output$FukuokaCluster <- renderEcharts4r({
  positiveDetail <- GLOBAL_VALUE$Fukuoka$nodes
  relationDt <- GLOBAL_VALUE$Fukuoka$edges
  e_charts() %>%
    e_graph(
      layout = "force",
      roam = T,
      draggable = T,
      symbolKeepAspect = T,
      focusNodeAdjacency = T
    ) %>%
    e_graph_nodes(
      nodes = positiveDetail,
      names = 都道府県症例番号,
      value = label,
      size = size,
      symbol = symbol,
      category = 性別
    ) %>%
    e_graph_edges(
      relationDt,
      source = 都道府県症例番号1,
      target = 都道府県症例番号2
    ) %>%
    e_tooltip(formatter = htmlwidgets::JS("
    function(params) {
      const text = params.value.split('|')
      return(`
        番号：${text[0]}<br>
        公表日：${text[1]}<br>
        年代：${text[2]}
      `)
    }
  ")) %>%
    e_labels(
      formatter = htmlwidgets::JS(paste0("
    function(params) {
      const text = params.value.split('|')
      if(Date.parse(text[1]) >= Date.parse('", (Sys.Date() - 7), "')) {
        return(`{oneWeek|${text[0]}}`)
      } else if(Date.parse(text[1]) >= Date.parse('", (Sys.Date() - 14), "')) {
        return(`{twoWeek|${text[0]}}`)
      } else if(Date.parse(text[1]) >= Date.parse('", (Sys.Date() - 21), "')) {
        return(`{threeWeek|${text[0]}}`)
      } else {
        return('')
      }
    }
  ")),
      rich = list(
        oneWeek = list(
          borderColor = "auto",
          color = "black",
          backgroundColor = "white",
          borderWidth = 4,
          borderRadius = 2,
          padding = 3,
          fontSize = 8
        ),
        twoWeek = list(
          borderColor = "auto",
          color = "black",
          backgroundColor = "white",
          borderWidth = 2,
          borderRadius = 2,
          padding = 3,
          fontSize = 8
        ),
        threeWeek = list(
          borderColor = "auto",
          color = "black",
          backgroundColor = "white",
          borderWidth = 0.5,
          borderRadius = 2,
          padding = 3,
          fontSize = 8
        )
      )
    ) %>%
    e_title(
      text = "福岡県のクラスターネットワーク",
      subtext = sprintf(
        "公表日：%s - %s",
        min(positiveDetail$公表日),
        max(positiveDetail$公表日)
      )
    )
})

output$fukuokaPatientTable <- renderDataTable({
  positiveDetail <- GLOBAL_VALUE$Fukuoka$nodes
  datatable(
    positiveDetail[, .(番号 = 都道府県症例番号, 発症日 = as.Date(発症日), 公表日 = as.Date(公表日), 
                         管轄 = (管理市区町村), 
                         居住地 = (居住市区町村), 
                         年代 = (年代), 
                         性別 = (性別), 職業 = (職業))],
    # filter = 'top',
    selection = 'single',
    options = list(
      # filter = 'top'
    )
  )
})

output$FukuokaContact <- renderEcharts4r({
  call <- GLOBAL_VALUE$Fukuoka$call
  call[, `:=` (年月日 = as.Date(年月日), 累計 = cumsum(件数))]
  call %>%
    e_chart(年月日) %>%
    e_bar(件数, itemStyle = list(color = lightBlue), name = i18n$t("新規")) %>%
    e_line(累計, name = i18n$t("累計"), itemStyle = list(color = darkNavy), y_index = 1, symbolSize = 1) %>%
    e_title(text = "帰国者・接触者相談センター相談件数", 
            subtext = paste0(
              sprintf("最終更新日：%s", max(call$年月日)), "   ",
              sprintf("計：%s件", tail(call$累計, n = 1))
            )) %>%
    e_y_axis(splitLine = list(show = F), index = 1) %>%
    e_y_axis(axisLabel = list(inside = T),
             axisTick = list(show = F),
             splitLine = list(lineStyle = list(opacity = 0.2))) %>%
    e_x_axis(splitLine = list(lineStyle = list(opacity = 0.2))) %>%
    e_grid(left = '5%', right = '5%') %>%
    e_legend(
      type = "scroll",
      orient = "vertical",
      left = "18%",
      top = "15%",
      right = "15%"
    ) %>%
    e_tooltip(trigger = "axis") %>%
    e_group("fukuokaBar") %>%
    e_connect_group("fukuokaBar")
})
