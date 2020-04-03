source(file = "global.R",
       local = TRUE,
       encoding = "UTF-8")

shinyServer(function(input, output, session) {
  # マップ関連コンポーネント
  source(file = paste0(COMPONENT_PATH, 'ComfiredMap.R'),
         local = TRUE,
         encoding = "UTF-8")
  # 数値ボックスコンポーネント
  source(file = paste0(COMPONENT_PATH, 'ValueBox.R'),
         local = TRUE,
         encoding = "UTF-8")
  # 線形図コンポーネント
  source(file = paste0(COMPONENT_PATH, 'LinePlot.R'),
         local = TRUE,
         encoding = "UTF-8")
  # 扇形図コンポーネント
  source(file = paste0(COMPONENT_PATH, 'pieChart.R'),
         local = TRUE,
         encoding = "UTF-8")
  # テーブル系コンポーネント
  source(file = paste0(COMPONENT_PATH, 'SummaryTable.R'),
         local = TRUE,
         encoding = "UTF-8")
  # BarChartコンポーネント
  source(file = paste0(COMPONENT_PATH, 'BarChart.R'),
         local = TRUE,
         encoding = "UTF-8")
  # ネットワーク系コンポーネント
  source(file = paste0(COMPONENT_PATH, 'Network.R'),
         local = TRUE,
         encoding = "UTF-8")
  # カレンダー系コンポーネント
  source(file = paste0(COMPONENT_PATH, 'Calendar.R'),
         local = TRUE,
         encoding = "UTF-8")
  # Sankey系コンポーネント
  source(file = paste0(COMPONENT_PATH, 'Sankey.R'),
         local = TRUE,
         encoding = "UTF-8")
  # 歳代、年齢コンポーネント
  source(file = paste0(COMPONENT_PATH, 'GenderAgeBar.R'),
         local = TRUE,
         encoding = "UTF-8")
  # 感染ルート
  source(file = paste0(COMPONENT_PATH, 'PlotInfectedRoute.R'),
         local = TRUE,
         encoding = "UTF-8")
  # Sparkline
  source(file = paste0(COMPONENT_PATH, 'Sparkline.R'),
         local = TRUE,
         encoding = "UTF-8")
  # TODO 追加修正待ち
  observeEvent(input$language, {
    if(input$language == 'cn') {
      langCode <- 'cn'
    } else {
      langCode <- 'ja'
    }
  })
  
  observeEvent(input$switchCaseMap, {
    updateTabItems(session, 'sideBarTab', 'caseMap')
  })
})
