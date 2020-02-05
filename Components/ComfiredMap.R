output$map <- renderPlot({
  # 感染状況を日本標準マップで表示する画像を作成
  # Returns:
  #   basePlotObject: 標準マップ
  province <- db$name
  total <- rowSums(db[, 2:ncol(db)])
  colorFunc <-
    colorRampPalette(c("#FFFFFF", "#FFA07A", "#CD5C5C"))
  
  breaks <- c(-0.1, 0.5, 2.5, 5.5, 100)
  breaks.length <- length(breaks) - 1
  names(province) <-
    colorFunc(breaks.length)[as.numeric(cut(total, breaks = breaks))]
  plotData <- names(province)
  names(plotData) <- as.character(province)
  par(mar = c(0, 0, 0, 0))
  JapanPrefMap(col = plotData)
  legend(143, 35, c(0, 1, 2, ">2"), fill = colorFunc(breaks.length))
  p <- recordPlot()
  p
})

output$blockMap <- renderPlot({
  # 感染状況をブロックマップで表示する画像を作成
  # Returns:
  #   ggplotObject: ブロックマップ
  ggplot(province, aes(
    x = X,
    y = Y,
    width = Scale,
    height = Scale,
  )) +
    geom_tile(aes(fill = Data), color = "black") +
    geom_text(
      aes(label = Prefecture),
      size = 2.7,
      color = "black",
      family = "HiraKakuPro-W3"
    ) +
    
    # Codeをラベルとして表示する場合
    # geom_text(aes(label = Code), size = 2.7, color = "white") +
    
    coord_fixed(ratio = 1) +
    theme(
      panel.background = element_blank(),
      panel.grid = element_blank(),
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      legend.position = c(0.1, 0.8),
    ) +
    # scale_fill_viridis_c(na.value = "#FFFFFF", option = "C", begin = 0, end = 1)
    scale_fill_gradient2(
      low = '#FFFFFF',
      mid = "#FFA07A",
      high = "#CD5C5C",
      midpoint = 8,
      name = ''
    )
})

output$mapWrapper <- renderUI({
  # デフォルトで標準マップを表示する
  # Returns:
  #   outputObject: 標準マップ
  plotOutput("map")
})

observeEvent(input$normalMapButton, {
  # 標準マップに切り替わる
  # Args:
  #   input$normalMapButton: 標準ボタンのクリックステータス
  # Returns:
  #   output$mapWrapper: マップのラッパー
  output$mapWrapper <- renderUI({
    plotOutput("map")
  })
})

observeEvent(input$blockMapButton, {
  # ブロックマップに切り替わる
  # Args:
  #   input$blockMapButton: ブロックボタンのクリックステータス
  # Returns:
  #   output$mapWrapper: マップのラッパー
  output$mapWrapper <- renderUI({
    plotOutput("blockMap")
  })
})
