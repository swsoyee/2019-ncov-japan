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

output$clusterProfileSearchBox <- renderUI({
  node <- clusterData()$node
  if (!is.null(node) && nrow(clusterData()$node) > 0) {
    choicesLabel <- paste0(node$受診都道府県, node$都道府県別罹患者No, '（', node$年代, node$性別, '）')
    choices <- node$罹患者id
    names(choices) <- choicesLabel
    selectizeInput(
      label = tagList(icon('search'), '感染者検索'), 
      choices = choices, 
      inputId = 'searchProfileInCluster')
  }
})

observeEvent(input$clusterNetwork_clicked_data, {
  updateSelectizeInput(
    session = session,
    inputId = 'searchProfileInCluster',
    selected = input$clusterNetwork_clicked_data$name
    )
})

output$profile <- renderUI({
  if (!is.null(input$searchProfileInCluster) && !is.null(clusterData()$node) && nrow(clusterData()$node) > 0) {
    # 検索ボックスで検索する場合
    patientInfo <- clusterData()$node[罹患者id == input$searchProfileInCluster]
    
    # フォーカス感染者
    echarts4rProxy('clusterNetwork') %>% 
      e_focus_adjacency_p(seriesIndex = 0, 
                          index = clusterData()$node[罹患者id == input$searchProfileInCluster, which = T] - 1
                          )
    if (length(patientInfo$label) > 0) {
      profile <- unlist(strsplit(patientInfo$label, '\\|')[[1]])
  
      age <- ifelse(profile[3] != '', profile[3], '未知')
      confirmedDate <- ifelse(profile[2] != '', profile[2], '調査中')
      job <- ifelse(profile[5] != '', profile[5], '非公表')
      gender <- tagList(icon('venus-mars'), profile[4])
      if (profile[4] == '男性') {
        gender <- tagList(icon('mars'), profile[4])
      } else if (profile[4] == '女性') {
        gender <- tagList(icon('venus'), profile[4])
      }
      
      # リンク分割
      outerLinks <- strsplit(profile[8], split = ';')[[1]]
      outerLinkTags <- tagList(lapply(1:length(outerLinks), function(i){
        tags$a(href = outerLinks[i], icon('link'), '外部リンク', style = 'float: right!important;')
      }))
      # 行動歴
      activityLog <- ifelse(profile[7] == '', '詳細なし', profile[7])
      # ステータス
      statusBadge <- ''
      if (profile[9] == '罹患中') {
        statusBadge <- dashboardLabel(profile[9], status = 'warning')
      } else if (profile[9] == '回復') {
        statusBadge <- dashboardLabel(profile[9], status = 'success')
      } else if (profile[9] == '死亡') {
        statusBadge <- dashboardLabel(profile[9], status = 'primary')
      } else {
        statusBadge <- dashboardLabel(profile[9], status = 'info')
      }
      
      boxPlus(
        title = tagList(icon('id-card'), '公開された感染者情報'),
        width = 12, 
        closable = F,
        boxProfile(
          title = profile[1],
          subtitle = tagList(gender, statusBadge),
          boxProfileItemList(
            bordered = TRUE,
            boxProfileItem(title = tagList(icon('user-clock'), '年代'),
                           description = age),
            boxProfileItem(title = tagList(icon('bullhorn'), '公表日'),
                           description = confirmedDate),
            boxProfileItem(title = tagList(icon('user-tie'), '職業'),
                           description = job),
            boxProfileItem(title = tagList(icon('home'), '居住地'),
                           description = profile[10]),
            boxProfileItem(
              title = tagList(icon('external-link-alt'), '情報源'),
              description = outerLinkTags
            ),
          )
        ),
        footer = tagList(
          tags$b(icon('handshake'), '濃厚接触者状況'),
          tags$p(tags$small(HTML(profile[11]))),
          tags$hr(),
          tags$b(icon('procedures'), '症状・経過'),
          tags$p(tags$small(HTML(profile[6]))),
          tags$hr(),
          tags$b(icon('walking'), '行動歴'),
          tags$p(tags$small(HTML(activityLog)))
        )
      )
    }
  } else {
    boxPlus(
      title = tagList(icon('id-card'), '公開された感染者情報'),
      width = 12, 
      closable = F,
      '左側の感染者アイコンをクリックすると詳細情報が表示されます。'
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
        names = regionId, size = size,
        value = label, symbol = symbolIcon) %>%
      e_graph_edges(edge, target = 罹患者id2, source = 罹患者id1) %>%
      e_labels(formatter = htmlwidgets::JS('
    function(params) {
      if (params.value) {
        return(params.value.split("|")[0])
      }
    }
  ')) %>%
      e_tooltip(formatter = htmlwidgets::JS('
    function(params) {
      if (params.value) {
        const text = params.value.split("|")
        return(`
          番号：${text[0]}<br>
          公表日：${text[1]}<br>
          年代：${text[2]}<br>
          性別：${text[3]}
        `)
      }
    }
  ')) %>%
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
