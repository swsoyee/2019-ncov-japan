fluidPage(
  Component.Notification(
    context = paste0(
      "当サイト使っているサーバーの性能が限られているため、一部のキャッシュをブラウザーに保存しております。",
      "画面表示がおかしくなったり、数値が更新されていない場合はリロードまたはキャッシュをクリアして再度アクセスしてください。"
    )
  ),
  # メイン部分、Valueboxを含むなど
  source(
    file = paste0(COMPONENT_PATH, "/Main/FirstRow.ui.R"),
    local = T,
    encoding = "UTF-8"
  )$value,
  fluidRow(
    boxPlus(
      title = tagList(
        icon("map-marked-alt"),
        "各都道府県の状況"
      ),
      closable = F,
      collapsible = T,
      width = 12,
      tabsetPanel(
        # 感染マップ、都道府県の情況のテーブル
        source(
          file = paste0(COMPONENT_PATH, "/Main/ConfirmedMap.ui.R"),
          local = T,
          encoding = "UTF-8"
        )$value,
        # 各都道府県のPCR検査数
        source(
          file = paste0(COMPONENT_PATH, "UiTabRegionPCR.R"),
          local = T,
          encoding = "UTF-8"
        )$value,
        # （破棄予定）
        tabPanel(
          title = tagList(icon("chart-bar"), "時系列棒グラフ"),
          echarts4rOutput("regionTimeSeries") %>% withSpinner()
        )
      ),
      tags$hr(),
      # 各カテゴリの合計と増加分表示の説明ブロック
      source(
        file = paste0(COMPONENT_PATH, "Main/DescriptionValue.ui.R"),
        local = T,
        encoding = "UTF-8"
      )$value,
      footer = tags$small(paste(
        lang[[langCode]][62], UPDATE_DATETIME, "開発＆調整中"
      ))
    ),
  ),
  fluidRow(
    Component.Tendency()
  ),
  fluidRow(
    Component.ComfirmedPyramid(),
    Component.SymptomsProgression()
  ),
  fluidRow(
    Component.NewsList(),
    Button.clusterTab(),
  )
)