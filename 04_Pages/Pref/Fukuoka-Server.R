observeEvent(input$sideBarTab, {
  if (input$sideBarTab == "fukuoka" && is.null(GLOBAL_VALUE$Fukuoka$patients)) {
    # GLOBAL_VALUE <- list(Fukuoka = list(
    #   summary = NULL,
    #   patients = NULL,
    #   updateTime = NULL,
    #   nodes = NULL,
    #   edges = NULL,
    #   call = NULL,
    #   test = NULL
    # )) # TEST

    fileList <- list.files(paste0(DATA_PATH, "Pref/Fukuoka/"))

    indexName <- c("patients", "nodes", "edges", "call", "test")
    fileName <- c("patients.csv", "nodes.csv", "edges.csv", "call.csv", "test.csv")

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

output$FukuokaValueBoxes <- renderUI({
  totalPCR <- sum(GLOBAL_VALUE$Fukuoka$test$件数)
  positiveDt <- GLOBAL_VALUE$Fukuoka$patients[, (計 = .N), by = "公表_年月日"]
  totalPositive <- sum(positiveDt$V1)
  discharge <- mhlwSummary[都道府県名 == "福岡"]
  discharge[, 日次退院者 := 退院者 - shift(退院者)]
  totalDischarge <- tail(discharge$退院者, n = 1)
  totalDeath <- sum(death$福岡)

  dischargeRate <- paste0(
    round(
      totalDischarge / (totalPositive - totalDeath)  * 100, 2
    ), '%'
  )
  deathRate <- paste0(
    round(
      totalDeath / totalPositive * 100, 2
    ), '%'
  )
  
  return(
    tagList(
      fluidRow(
        createValueBox(value = totalPCR, # TODO 今はけんものデータを使ってる
                       subValue = tagList(
                         tags$span(id = "fukuokaTest", icon("info-circle"))
                         ), 
                       sparkline = createSparklineInValueBox(GLOBAL_VALUE$Fukuoka$test, '件数'),
                       subtitle = i18n$t("検査数"),
                       icon = 'vials',
                       color = 'yellow', 
                       diff = tail(GLOBAL_VALUE$Fukuoka$test$件数, n = 1)
        ),
        bsTooltip(id = "fukuokaTest", "民間検査実施分が含まれていません。"),
        createValueBox(value = totalPositive,
                       subValue = paste0(i18n$t('速報：'), sum(byDate$福岡, na.rm = T)), 
                       sparkline = createSparklineInValueBox(
                         positiveDt, 
                         'V1'),
                       subtitle = i18n$t("陽性者数"),
                       icon = 'procedures',
                       color = 'red', 
                       diff = tail(positiveDt$V1, n = 1)
        )
      ),
      fluidRow(
        createValueBox(value = totalDischarge, # TODO 今は厚労省のデータを使ってる
                       subValue = dischargeRate, # TODO
                       sparkline = createSparklineInValueBox(discharge, '日次退院者'),
                       subtitle = i18n$t("回復者数"),
                       icon = 'user-shield',
                       color = 'green',
                       diff = tail(discharge$日次退院者, n = 1)
        ),
        createValueBox(value = totalDeath, # TODO 公式データまだない
                       subValue = deathRate,
                       sparkline = createSparklineInValueBox(death, '福岡'),
                       subtitle = i18n$t("死亡者数"),
                       icon = 'bible',
                       color = 'navy',
                       diff = tail(death$福岡, n = 1)
        )
      )
    )
  )
})

# 陽性患者の感染経路====
output$FukuokaInfectedRoute <- renderEcharts4r({
  dt <- GLOBAL_VALUE$Fukuoka$patients
  dt <- dt[, lapply(.SD, function(x) {
    sum(x, na.rm = T)
  }),
  .SD = c("感染経路不明", "濃厚接触者", "海外渡航歴有"), by = "公表_年月日"
  ]
  dt[, `:=` (公表_年月日 = as.Date(公表_年月日), 
                   累計 = cumsum(感染経路不明 + 濃厚接触者 + 海外渡航歴有))] %>%
    e_chart(公表_年月日) %>%
    e_bar(感染経路不明, stack = 1, itemStyle = list(color = "#E9546B")) %>%
    e_bar(濃厚接触者, stack = 1, itemStyle = list(color = "#025BAC")) %>%
    e_bar(海外渡航歴有, stack = 1, itemStyle = list(color = "#4C4C4C")) %>%
    e_line(累計, itemStyle = list(color = darkRed), symbolSize = 1, y_index = 1) %>%
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
    e_y_axis(
      index = 1,
      splitLine = list(
        show = F
      )
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
      right = "10%"
    )
})

# 市区町村別の感染者数====
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

# 福岡県のクラスターネットワーク ====
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

# 陽性者テーブル ====
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

observeEvent(input$fukuokaPatientTable_rows_selected, {
  selectedId <- input$fukuokaPatientTable_rows_selected
  # フォーカス感染者
  echarts4rProxy("FukuokaCluster") %>%
    e_focus_adjacency_p(
      seriesIndex = 0,
      index = GLOBAL_VALUE$Fukuoka$nodes[都道府県症例番号 == GLOBAL_VALUE$Fukuoka$nodes[selectedId]$都道府県症例番号, which = T] - 1
    )
})

output$fukuokaProfile <- renderUI({
  selectedId <- input$fukuokaPatientTable_rows_selected
  if(!is.null(selectedId)) {
    profile <- GLOBAL_VALUE$Fukuoka$nodes[都道府県症例番号 == GLOBAL_VALUE$Fukuoka$nodes[selectedId]$都道府県症例番号]
    
    age <- ifelse(profile$年代 != "", profile$年代, i18n$t("不明"))
    gender <- tagList(icon("venus-mars"), profile$性別)
    if (profile$性別 == "男性") {
      gender <- tagList(icon("mars"), i18n$t("男性"))
    } else if (profile$性別 == "女性") {
      gender <- tagList(icon("venus"), i18n$t("女性"))
    }
    
    # リンク分割
    outerLinks <- strsplit(profile$情報源, split = ";")[[1]]
    outerLinkTags <-
      tagList(lapply(1:length(outerLinks), function(i) {
        tags$a(
          href = outerLinks[i],
          icon("link"),
          i18n$t("外部リンク"),
          style = "float: right!important;"
        )
      }))

    boxPlus(
      title = tagList(icon("id-card"), i18n$t("公開された感染者情報")),
      width = 12,
      closable = F,
      boxProfile(
        title = profile$都道府県症例番号,
        src = ifelse(profile$性別 == '男性', 'Icon/male.png', 'Icon/female.png'),
        subtitle = tagList(gender),
        boxProfileItemList(
          bordered = TRUE,
          boxProfileItem(
            title = tagList(icon("user-clock"), i18n$t("年代")),
            description = age
          ),
          boxProfileItem(
            title = tagList(icon("bullhorn"), i18n$t("公表日")),
            description = profile$公表日
          ),
          boxProfileItem(
            title = tagList(icon("user-tie"), i18n$t("職業")),
            description = profile$職業
          ),
          boxProfileItem(
            title = tagList(icon("home"), i18n$t("居住地")),
            description = paste(profile$居住都道府県, profile$居住市区町村)
          ),
          boxProfileItem(
            title = tagList(icon("external-link-alt"), i18n$t("情報源")),
            description = outerLinkTags
          ),
        )
      ),
      footer = tagList(
        tags$b(icon("handshake"), i18n$t("濃厚接触者状況")),
        tags$p(tags$small(HTML(gsub(pattern = "\n", replacement = "<br>", profile$濃厚接触者状況)))),
        tags$hr(),
        tags$b(icon("procedures"), i18n$t("症状・経過")),
        tags$p(tags$small(HTML(gsub(pattern = "\n", replacement = "<br>", profile$`症状・経過`)))),
        tags$hr(),
        tags$b(icon("walking"), i18n$t("行動歴")),
        tags$p(tags$small(HTML(gsub(pattern = "\n", replacement = "<br>", profile$行動歴))))
      )
    )
  } else {
    boxPlus(
      title = tagList(icon("id-card"), i18n$t("公開された感染者情報")),
      width = 12,
      closable = F,
      "詳細テーブルをクリックすると感染者の詳細情報が表示されます。"
    )
  }
})

# 帰国者・接触者相談センター相談件数 ====
output$FukuokaContact <- renderEcharts4r({
  call <- GLOBAL_VALUE$Fukuoka$call
  # call[, `:=` (日付 = as.Date(日付))] # 20200717 から変更
  call[, `:=` (日付 = as.Date(年月日), 合計 = 件数, 専用ダイヤル累計 = cumsum(件数))]
  call %>%
    e_chart(日付) %>%
    e_bar(合計, itemStyle = list(color = lightBlue), name = i18n$t("新規")) %>%
    e_line(専用ダイヤル累計, name = i18n$t("累計"), itemStyle = list(color = darkNavy), y_index = 1, symbolSize = 1) %>%
    e_title(text = "帰国者・接触者相談センター相談件数", 
            subtext = paste0(
              sprintf("最終更新日：%s", max(call$日付)), "   ",
              sprintf("計：%s件", tail(call$専用ダイヤル累計, n = 1))
            )) %>%
    e_y_axis(splitLine = list(show = F), index = 1) %>%
    e_y_axis(axisLabel = list(inside = T),
             axisTick = list(show = F),
             splitLine = list(lineStyle = list(opacity = 0.2))) %>%
    e_x_axis(splitLine = list(lineStyle = list(opacity = 0.2))) %>%
    e_grid(left = '5%', right = '10%') %>%
    e_legend(
      type = "scroll",
      orient = "vertical",
      left = "18%",
      top = "15%",
      right = "15%"
    ) %>%
    e_tooltip(trigger = "axis") %>%
    e_group("fukuokaBar")
})

# 検査実施数 ====
output$FukuokaTest <- renderEcharts4r({
  test <- GLOBAL_VALUE$Fukuoka$test
  test[, `:=` (年月日 = as.Date(年月日), 累計 = cumsum(件数))]
  setnafill(test, fill = 0, cols = c("福岡市", "北九州市", "福岡県"))
  test %>%
    e_chart(年月日) %>%
    e_bar(福岡市, stack = 1, itemStyle = list(color = darkYellow)) %>%
    e_bar(北九州市, stack = 1, itemStyle = list(color = middleYellow)) %>%
    e_bar(福岡県, stack = 1, itemStyle = list(color = lightYellow)) %>%
    e_line(累計, stack = 1, itemStyle = list(color = darkYellow), symbolSize = 1, y_index = 1) %>%
    e_y_axis(splitLine = list(show = F), index = 1) %>%
    e_y_axis(axisLabel = list(inside = T),
             axisTick = list(show = F),
             splitLine = list(lineStyle = list(opacity = 0.2))) %>%
    e_x_axis(splitLine = list(lineStyle = list(opacity = 0.2))) %>%
    e_grid(left = '5%', right = '10%', top = "20%") %>%
    e_legend(
      type = "scroll",
      orient = "vertical",
      left = "18%",
      top = "20%",
      right = "15%"
    ) %>%
    e_tooltip(trigger = "axis") %>%
    e_title(text = "検査実施数", 
            subtext = paste0(
              sprintf("最終更新日：%s", max(test$年月日)), "   ",
              sprintf("計：%s件", sum(test$件数)), 
              "\n※ 福岡県は福岡市、北九州市以外の自治体の合計です。",
              "\n※ 民間検査実施分が含まれていません。"
            )) %>%
    e_group("fukuokaBar") %>%
    e_connect_group("fukuokaBar")
})
