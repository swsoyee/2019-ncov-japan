output$network <- renderEcharts4r({
  data <- networkData()
  
  e_charts() %>%
    e_graph() %>%
    e_graph_nodes(data$node,
                  names = id,
                  value = label,
                  size = effectSize) %>%
    e_graph_edges(data$edge, target = target, source = source) %>%
    e_modularity() %>%
    e_labels() %>%
    e_tooltip(
      formatter = htmlwidgets::JS('function(params) {
        if (["クルーズ船", "卓球スクール", "ライブハウス", "スポーツジム", "展示会"].includes(params.name)) {
          return("")
        }
        const label = params.value.split("#")
        return("<b>" + params.name + "番患者</b><br><br>年齢：" +
          label[0] + "<br>性別：" + label[1] + "<br>居住地：" + 
          label[2] + "<br><br>" + label[3])
      }')
    )
})

networkData <- reactive({
  # クラスタラベル
  clusterLabel <- c('クルーズ船', '卓球スクール', 'ライブハウス', 'スポーツジム', '展示会')
  # ノット作成
  confirmedNodes <-
    detail[, c('id',
               'age',
               'gender',
               'residence',
               'relatedConfirmed',
               'subgroup')] # ノット
  confirmedNodes$gender <- as.character(confirmedNodes$gender)
  confirmedNodes$effectSize <-
    sapply(confirmedNodes$relatedConfirmed, function(x) {
      count <- length(strsplit(x, ',')[[1]])
      K <- 8
      size <- K * count
      if (size > 32) {
        size <- 32 + count
      }
      size
    })
  # エッジ作成
  confirmedEdges <- data.frame('source' = 0, 'target' = 0) # エッジ初期化
  for (i in 1:nrow(confirmedNodes)) {
    relation <-
      strsplit(confirmedNodes$relatedConfirmed[i], ',')[[1]] # 複数関連者対応
    # クラスター対応
    if (relation[1] %in% clusterLabel) {
      confirmedEdges <-
        rbind(confirmedEdges, c(confirmedNodes[i]$id, relation[1]), stringsAsFactors = F)
    } else if (relation[1] == 0 ||
        suppressWarnings(is.na(as.numeric(relation)))) {
      # 関連者なしの場合、エッジを自分から自分へに設定する
      item <- c(confirmedNodes[i]$id, confirmedNodes[i]$id)
      confirmedEdges <-
        rbind(confirmedEdges, item, stringsAsFactors = F)
    } else if (length(relation) > 1) {
      for (j in 1:length(relation)) {
        # 最初に確認された患者をソース源にする
        id <- confirmedNodes[i]$id
        item <- if (id < as.numeric(relation[j]))
          c(id, relation[j])
        else
          c(relation[j], confirmedNodes[i]$id)
        confirmedEdges <-
          rbind(confirmedEdges, item, stringsAsFactors = F)
      }
    } else {
      item <- c(confirmedNodes[i]$id, relation)
      confirmedEdges <-
        rbind(confirmedEdges, item, stringsAsFactors = F)
    }
  }
  confirmedEdges <- data.table(confirmedEdges)
  
  # 離散のポイントを非表示するか
  if (input$hideSingle) {
    filterResult <-
      confirmedEdges[confirmedEdges$source != confirmedEdges$target]
    inSource <-
      sapply(as.character(confirmedNodes$id), function(x) {
        x %in% filterResult$source
      })
    inTarget <-
      sapply(confirmedNodes$id, function(x) {
        x %in% filterResult$target
      })
    confirmedNodes <-
      confirmedNodes[rowSums(data.frame(inSource, inTarget)) > 0,]
  }
  confirmedNodes$id <- as.character(confirmedNodes$id)
  confirmedNodes$label <- paste(sep = "#", 
                                confirmedNodes$age, 
                                confirmedNodes$gender, 
                                confirmedNodes$residence,
                                confirmedNodes$subgroup)
  
  # クラスタ対応
  for (x in clusterLabel) {
    confirmedNodes <- rbind(confirmedNodes, list('id' = x, 'label' = x, 'effectSize' = 15), fill = T)
  }
  # data <- list(node = confirmedNodes, edge = confirmedEdges)
  return(list(node = confirmedNodes, edge = confirmedEdges))
})

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
      e_tooltip(formatter = htmlwidgets::JS('
    function(params) {
      if (params.value) {
        const text = params.value.split("|")
        return(`
          番号：${text[0]}<br>
          公表日：${text[1]}<br>
          年代：${text[2]}<br>
          性別：${text[3]}<br>
          職業：${text[4]}<br><hr>
          症状・経過:<br><small>${text[5]}</small><br><hr>
          行動歴:<br><small>${text[6]}</small><br>
          <a href="${text[7]}">情報源</a>
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
