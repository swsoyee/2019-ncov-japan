source(file = "global.R",
       local = TRUE,
       encoding = "UTF-8")

shinyServer(function(input, output, session) {
  # マップ関連コンポーネント
  source(file = "Components/ComfiredMap.R",
         local = TRUE,
         encoding = "UTF-8")
  # 数値ボックスコンポーネント
  source(file = "Components/ValueBox.R",
         local = TRUE,
         encoding = "UTF-8")
  # 線形図コンポーネント
  source(file = "Components/LinePlot.R",
         local = TRUE,
         encoding = "UTF-8")
  # テーブル系コンポーネント
  source(file = "Components/SummaryTable.R",
         local = TRUE,
         encoding = "UTF-8")
})
  