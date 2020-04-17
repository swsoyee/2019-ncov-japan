source(
       file = "global.R",
       local = TRUE,
       encoding = "UTF-8"
)

shinyServer(function(input, output, session) {
       source(file = paste0(COMPONENT_PATH, "Main/NewsList.server.R"), local = T, encoding = "UTF-8")
       source(file = paste0(COMPONENT_PATH, "Main/Tendency.Discharged.server.R"), local = T, encoding = "UTF-8")
       source(file = paste0(COMPONENT_PATH, "Main/Tendency.Test.server.R"), local = T, encoding = "UTF-8")
       source(file = paste0(COMPONENT_PATH, "Main/Tendency.Confirmed.server.R"), local = T, encoding = "UTF-8")
       source(file = paste0(COMPONENT_PATH, "Academic/onset2ConfirmedMap.server.R"), local = T, encoding = "UTF-8")
       # マップ関連コンポーネント
       source(
              file = paste0(COMPONENT_PATH, "Main/ConfirmedMap.server.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # 数値ボックスコンポーネント
       source(
              file = paste0(COMPONENT_PATH, "ValueBox.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # 線形図コンポーネント
       source(
              file = paste0(COMPONENT_PATH, "LinePlot.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # テーブル系コンポーネント
       source(
              file = paste0(COMPONENT_PATH, "Main/SummaryTable.server.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # BarChartコンポーネント
       source(
              file = paste0(COMPONENT_PATH, "BarChart.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # ネットワーク系コンポーネント
       source(
              file = paste0(COMPONENT_PATH, "Network.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # カレンダー系コンポーネント
       source(
              file = paste0(COMPONENT_PATH, "Calendar.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # Sankey系コンポーネント
       source(
              file = paste0(COMPONENT_PATH, "Sankey.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # 歳代、年齢コンポーネント
       source(
              file = paste0(COMPONENT_PATH, "Main/ComfirmedPyramid.server.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # 感染ルート
       source(
              file = paste0(COMPONENT_PATH, "PlotInfectedRoute.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # Sparkline
       source(
              file = paste0(COMPONENT_PATH, "Sparkline.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # 青森県
       source(
              file = paste0(PAGE_PATH, "Pref/Utils.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # 北海道
       source(
              file = paste0(PAGE_PATH, "Pref/Hokkaido-Server.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # 青森県
       source(
              file = paste0(PAGE_PATH, "Pref/Aomori-Server.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # 岩手県
       source(
              file = paste0(PAGE_PATH, "Pref/Iwate-Server.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # 宮城県
       source(
              file = paste0(PAGE_PATH, "Pref/Miyagi-Server.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # 茨城県
       source(
              file = paste0(PAGE_PATH, "Pref/Ibaraki-Server.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # 神奈川県
       source(
              file = paste0(PAGE_PATH, "Pref/Kanagawa-Server.R"),
              local = TRUE,
              encoding = "UTF-8"
       )
       # TODO 追加修正待ち
       observeEvent(input$language, {
              if (input$language == "cn") {
                     langCode <- "cn"
              } else {
                     langCode <- "ja"
              }
       })

       observeEvent(input$switchCaseMap, {
              updateTabItems(session, "sideBarTab", "caseMap")
       })
})