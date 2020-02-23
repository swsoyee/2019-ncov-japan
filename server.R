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
