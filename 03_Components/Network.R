observeEvent(input$sideBarTab, {
  if (input$sideBarTab == "route") {
    # GLOBAL_VALUE <- list(signateDetail = NULL) # TEST
    GLOBAL_VALUE$signateDetail <- fread(file = paste0(DATA_PATH, "resultSignateDetail.csv"))
    GLOBAL_VALUE$signateLink <- fread(file = paste0(DATA_PATH, "resultSignateLink.csv"))
  }
})

clusterData <- reactive({
  # フィルター
  prefCode <- input$clusterRegionPicker
  if (length(prefCode) > 0) {
    linkFilter <- GLOBAL_VALUE$signateLink[`id1-1` %in% prefCode | `id2-1` %in% prefCode]
    idFilter <- unique(c(linkFilter$罹患者id1, linkFilter$罹患者id2))
    signateDetailFilter <- GLOBAL_VALUE$signateDetail[罹患者id %in% idFilter | 都道府県コード %in% prefCode]
    return(list(node = signateDetailFilter, edge = linkFilter))
  } else {
    return(list(node = NULL, edge = NULL))
  }
})

output$clusterDateRangeSelector <- renderUI({
  node <- clusterData()$node
  if (!is.null(node) && nrow(node) > 0) {
    dateRangeInput(
      "clusterDateRange",
      label = i18n$t("公表日"),
      start = Sys.Date() - 14,
      end = Sys.Date(),
      min = min(node$公表日, na.rm = T),
      max = Sys.Date(),
      separator = " - ",
      format = "yyyy年m月d日",
      language = languageSetting
    )
  } else {
    tagList(tags$b(i18n$t("該当地域には感染者が確認されていません。またはデータの更新が必要です。")))
  }
})

output$clusterNetworkWrapper <- renderUI({
  node <- clusterData()$node
  if (is.null(node)) {
    tags$p(i18n$t("少なくとも一個以上の地域を選択してください。"))
  } else {
    echarts4rOutput("clusterNetwork", height = "600px")
  }
})

output$clusterProfileSearchBox <- renderUI({
  node <- clusterData()$node
  if (!is.null(node) && nrow(clusterData()$node) > 0) {
    choicesLabel <- paste0(node$受診都道府県, node$都道府県別罹患者No, "（", node$年代, node$性別, "）")
    choices <- node$罹患者id
    names(choices) <- choicesLabel
    selectizeInput(
      label = tagList(icon("search"), i18n$t("感染者検索")),
      choices = choices,
      inputId = "searchProfileInCluster"
    )
  }
})

observeEvent(input$clusterNetwork_clicked_data, {
  updateSelectizeInput(
    session = session,
    inputId = "searchProfileInCluster",
    selected = input$clusterNetwork_clicked_data$name
  )
})

output$profile <- renderUI({
  if (!is.null(input$searchProfileInCluster) && !is.null(clusterData()$node) && nrow(clusterData()$node) > 0) {
    # 検索ボックスで検索する場合
    patientInfo <- clusterData()$node[罹患者id == input$searchProfileInCluster]

    # フォーカス感染者
    echarts4rProxy("clusterNetwork") %>%
      e_focus_adjacency_p(
        seriesIndex = 0,
        index = clusterData()$node[罹患者id == input$searchProfileInCluster, which = T] - 1
      )
    if (length(patientInfo$label) > 0) {
      profile <- unlist(strsplit(patientInfo$label, "\\|")[[1]])

      age <- ifelse(profile[3] != "", profile[3], i18n$t("不明"))
      confirmedDate <- ifelse(profile[2] != "", profile[2], i18n$t("不明"))
      job <- ifelse(profile[5] != "", profile[5], i18n$t("不明"))
      gender <- tagList(icon("venus-mars"), profile[4])
      if (profile[4] == "男性") {
        gender <- tagList(icon("mars"), i18n$t("男性"))
      } else if (profile[4] == "女性") {
        gender <- tagList(icon("venus"), i18n$t("女性"))
      }

      # リンク分割
      outerLinks <- strsplit(profile[8], split = ";")[[1]]
      outerLinkTags <- tagList(lapply(1:length(outerLinks), function(i) {
        tags$a(href = outerLinks[i], icon("link"), i18n$t("外部リンク"), style = "float: right!important;")
      }))
      # 行動歴
      activityLog <- ifelse(profile[7] == "", i18n$t("不明"), profile[7])
      # ステータス
      statusBadge <- ""
      if (profile[9] == "罹患中") {
        statusBadge <- dashboardLabel(i18n$t("罹患中"), status = "warning")
      } else if (profile[9] == "回復") {
        statusBadge <- dashboardLabel(i18n$t("回復"), status = "success")
      } else if (profile[9] == "死亡") {
        statusBadge <- dashboardLabel(i18n$t("死亡"), status = "primary")
      } else {
        statusBadge <- dashboardLabel(profile[9], status = "info")
      }

      boxPlus(
        title = tagList(icon("id-card"), i18n$t("公開された感染者情報")),
        width = 12,
        closable = F,
        boxProfile(
          title = profile[1],
          subtitle = tagList(gender, statusBadge),
          boxProfileItemList(
            bordered = TRUE,
            boxProfileItem(
              title = tagList(icon("user-clock"), i18n$t("年代")),
              description = age
            ),
            boxProfileItem(
              title = tagList(icon("bullhorn"), i18n$t("公表日")),
              description = confirmedDate
            ),
            boxProfileItem(
              title = tagList(icon("user-tie"), i18n$t("職業")),
              description = job
            ),
            boxProfileItem(
              title = tagList(icon("home"), i18n$t("居住地")),
              description = profile[10]
            ),
            boxProfileItem(
              title = tagList(icon("external-link-alt"), i18n$t("情報源")),
              description = outerLinkTags
            ),
          )
        ),
        footer = tagList(
          tags$b(icon("handshake"), i18n$t("濃厚接触者状況")),
          tags$p(tags$small(HTML(profile[11]))),
          tags$hr(),
          tags$b(icon("procedures"), i18n$t("症状・経過")),
          tags$p(tags$small(HTML(profile[6]))),
          tags$hr(),
          tags$b(icon("walking"), i18n$t("行動歴")),
          tags$p(tags$small(HTML(activityLog)))
        )
      )
    }
  } else {
    boxPlus(
      title = tagList(icon("id-card"), i18n$t("公開された感染者情報")),
      width = 12,
      closable = F,
      i18n$t("左側の丸いアイコンをクリックすると詳細情報が表示されます。")
    )
  }
})

output$clusterNetwork <- renderEcharts4r({
  # node <- signateDetailFilter # TEST
  # edge <- linkFilter # TEST
  node <- clusterData()$node
  edge <- clusterData()$edge

  if (!is.null(node)) {
    e_charts() %>%
      e_graph(
        # layout = 'force',
        roam = T,
        draggable = T,
        symbolKeepAspect = T,
        focusNodeAdjacency = T
      ) %>%
      e_graph_nodes(
        node,
        names = regionId, size = size, category = 性別,
        value = label # ,
        # symbol = symbolIcon
      ) %>%
      e_graph_edges(edge, target = 罹患者id2, source = 罹患者id1) %>%
      e_labels(formatter = htmlwidgets::JS(paste0('
    function(params) {
      if (params.value) {
        const text = params.value.split("|")
        const id = text[0].split("-")
        const status = text[8] == "死亡" ? "{death|†}" : ""
        const minDate = Date.parse("', input$clusterDateRange[1], '")
        const maxDate = Date.parse("', input$clusterDateRange[2], '")
        const thisDate = Date.parse(text[1])
        const labelBox = (thisDate >= minDate && thisDate <= maxDate)
                         ? "inDateRange" : "outDateRange"
        return(`${status}{${labelBox}|${id[0].substring(0,1)}${id[1]}}`)
      }
    }
  ')), rich = list(
        inDateRange = list(borderColor = "auto", borderWidth = 2, borderRadius = 2, padding = 3, fontSize = 8),
        outDateRange = list(borderColor = "transparent", borderWidth = 2, borderRadius = 2, padding = 3, fontSize = 8),
        death = list(borderColor = "auto", borderWidth = 2, borderRadius = 10, padding = 3)
      ), ) %>%
      e_tooltip(formatter = htmlwidgets::JS(paste0('
    function(params) {
      if (params.value) {
        const text = params.value.split("|")
        return(`
          ', i18n$t("番号："), '${text[0]}<br>
          ', i18n$t("公表日："), '${text[1]}<br>
          ', i18n$t("年代："), '${text[2]}<br>
          ', i18n$t("性別："), '${text[3]}
        `)
      }
    }
  '))) %>%
      # e_modularity() %>%
      e_title(
        text = paste0(i18n$t("合計："), nrow(node)),
        subtext = paste0(i18n$t("公表日："), min(as.Date(node$公表日), na.rm = T), " ~ ", max(as.Date(node$公表日), na.rm = T))
      )
  } else {
    return()
  }
})

observeEvent(input$gotoRoutePage, {
  if (input$gotoRoutePage) {
    updateTabItems(
      session = session,
      inputId = "sideBarTab",
      selected = "route"
    )
  }
})