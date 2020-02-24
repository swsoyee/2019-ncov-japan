output$network <- renderEcharts4r({
  confirmedNodes <-
    detail[group == '国内事例', c('id',
                              'age',
                              'gender',
                              'residence',
                              'relatedConfirmed',
                              'subgroup')] # ノット
  confirmedNodes$gender <- as.character(confirmedNodes$gender)
  confirmedNodes$age <- confirmedNodes$age
  confirmedNodes$label <- paste0(
    '番号',
    confirmedNodes$id,
    '(',
    confirmedNodes$age,
    ', ',
    confirmedNodes$residence,
    '在住) | ',
    confirmedNodes$subgroup
  )
  confirmedEdges <- data.frame(character(0), character(0)) # エッジ初期化
  for (i in 1:nrow(confirmedNodes)) {
    relation <-
      strsplit(confirmedNodes$relatedConfirmed[i], ',')[[1]] # 複数関連者対応
    if (relation[1] == 0 || suppressWarnings(is.na(as.numeric(relation)))) {
      # 関連者なしの場合、エッジを自分から自分へに設定する
      confirmedEdges <-
        rbind(confirmedEdges,
              c(confirmedNodes[i]$id, confirmedNodes[i]$id))
    } else if (length(relation) > 1) {
      for (j in 1:length(relation)) {
        # 最初に確認された患者をソース源にする
        id <- confirmedNodes[i]$id
        item <- if (id < as.numeric(relation[j]))
          c(id, relation[j])
        else
          c(relation[j], confirmedNodes[i]$id)
        confirmedEdges <- rbind(confirmedEdges, item)
      }
    } else {
      confirmedEdges <-
        rbind(confirmedEdges, c(confirmedNodes[i]$id, relation))
    }
  }
  confirmedEdges <- data.frame(lapply(confirmedEdges, as.numeric))
  colnames(confirmedEdges) <- c('source', 'target')
  confirmedEdges <- data.table(confirmedEdges)
  mergeDt <-
    merge(confirmedEdges,
          confirmedNodes,
          by.x = 'source',
          by.y = 'id')
  mergeDt <-
    merge(mergeDt, confirmedNodes, by.x = 'target', by.y = 'id')
  
  e_charts() %>%
    e_graph() %>%
    e_graph_nodes(confirmedNodes,
                  names = label,
                  value = age,
                  size = age) %>%
    e_graph_edges(mergeDt, label.x, label.y) %>%
    e_modularity() %>%
    e_tooltip()
})
