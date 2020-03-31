observeEvent(input$sideBarTab, {
  if (input$sideBarTab == 'route') {
    GLOBAL_VALUE$signateDetail <- fread(file = paste0(DATA_PATH, 'resultSignateDetail.csv'))
    GLOBAL_VALUE$signateLink <- fread(file = paste0(DATA_PATH, 'resultSignateLink.csv'))
  }
})

clusterData <- reactive({
  # フィルター
  prefCode <- input$clusterRegionPicker
  if (length(prefCode) > 0) {
    linkFilter <- GLOBAL_VALUE$signateLink[`id1-1` %in% prefCode | `id2-1` %in% prefCode]
    idFilter <-  unique(c(linkFilter$罹患者id1, linkFilter$罹患者id2))
    signateDetailFilter <- GLOBAL_VALUE$signateDetail[罹患者id %in% idFilter | 都道府県コード %in% prefCode]
    return(list(node = signateDetailFilter, edge = linkFilter))
  } else {
    return(list(node = NULL, edge = NULL))
  }
})

output$clusterNetworkWrapper <- renderUI({
  node <- clusterData()$node
  if (is.null(node)) {
    tags$p('少なくとも一個以上の地域を選択してください。')
  } else {
    echarts4rOutput('clusterNetwork', height = '600px')
  }
})

output$profile <- renderUI({
  if (!is.null(input$clusterNetwork_clicked_data$value)) {
    profile <- unlist(strsplit(input$clusterNetwork_clicked_data$value[1], '\\|')[[1]])
    
    age <- ifelse(profile[3] != '', profile[3], '未知')
    confirmedDate <- ifelse(profile[2] != '', profile[2], '調査中')
    job <- ifelse(profile[5] != '', profile[5], '非公表')
    gender <- tagList(icon('venus-mars'), profile[4])
    if (profile[4] == '男性') {
      gender <- tagList(icon('mars'), profile[4])
    } else if (profile[4] == '女性') {
      gender <- tagList(icon('venus'), profile[4])
    }
    
    boxPlus(
      title = tagList(icon('user'), '公開された情報'), 
      width = 12,
      status = 'primary',
      boxProfile(
        title = profile[1],
        subtitle = gender,
        boxProfileItemList(
          bordered = TRUE,
          boxProfileItem(
            title = '年代',
            description = age
          ),
          boxProfileItem(
            title = '公表日',
            description = confirmedDate
          ),
          boxProfileItem(
            title = '職業',
            description = job
          ),
          boxProfileItem(
            title = '情報源',
            description = tags$a(href = profile[8], icon('link'), '外部リンク', style = 'float: right!important;')
          ),
        )
      ), 
      footer = tagList(
        tags$b('症状・経過'),
        tags$p(
          tags$small(HTML(profile[6]))
        ),
        tags$hr(),
        tags$b('行動歴'),
        tags$p(
          tags$small(HTML(profile[7]))
        )
      )
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
      e_graph(layout = 'force',
              roam = T,
              draggable = T,
              symbolKeepAspect = T,
              focusNodeAdjacency = T) %>%
      e_graph_nodes(
        node,
        names = regionId,
        value = label, symbol = symbolIcon) %>%
      e_graph_edges(edge, target = 罹患者id2, source = 罹患者id1) %>%
      e_labels(formatter = htmlwidgets::JS('
    function(params) {
      if (params.value) {
        return(params.value.split("|")[0])
      }
    }
  ')) %>%
  #     e_tooltip(formatter = htmlwidgets::JS('
  #   function(params) {
  #     if (params.value) {
  #       const text = params.value.split("|")
  #       return(`
  #         番号：${text[0]}<br>
  #         公表日：${text[1]}<br>
  #         年代：${text[2]}<br>
  #         性別：${text[3]}<br>
  #         職業：${text[4]}<br><hr>
  #         症状・経過:<br><small>${text[5]}</small><br><hr>
  #         行動歴:<br><small>${text[6]}</small><br>
  #         <a href="${text[7]}">情報源</a>
  #       `)
  #     }
  #   }
  # ')) %>%
      e_modularity()
  } else {
    return()
  }
})

observeEvent(input$gotoRoutePage, {
  if(input$gotoRoutePage) {
    updateTabItems(
      session = session, 
      inputId = 'sideBarTab', 
      selected = 'route')
  }
})
