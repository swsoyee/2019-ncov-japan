fluidPage(
  Component.Notification(
    context = paste0(
      '当サイト使っているサーバーの性能が限られているため、一部のキャッシュをブラウザーに保存しております。',
      '画面表示がおかしくなったり、数値が更新されていない場合はリロードまたはキャッシュをクリアして再度アクセスしてください。'
    )
  ), 
  # メイン部分、Valueboxを含むなど
  source(
    file = paste0(COMPONENT_PATH, '/Main/FirstRow.ui.R'),
    local = T,
    encoding = 'UTF-8'
  )$value,
  fluidRow(
    boxPlus(
      title = tagList(
        icon('map-marked-alt'), 
        '各都道府県の状況'
      ),
      closable = F,
      collapsible = T,
      width = 12,
      tabsetPanel(
        # 感染マップ、都道府県の情況のテーブル
        source(
          file = paste0(COMPONENT_PATH, '/Main/ConfirmedMap.ui.R'),
          local = T,
          encoding = 'UTF-8'
        )$value,
        # 各都道府県のPCR検査数
        source(
          file = paste0(COMPONENT_PATH, 'UiTabRegionPCR.R'),
          local = T,
          encoding = 'UTF-8'
        )$value,
        # （破棄予定）
        tabPanel(
          title = tagList(icon('chart-bar'), '時系列棒グラフ'),
          echarts4rOutput('regionTimeSeries') %>% withSpinner()
        )
      ),
      tags$hr(),
      # 各カテゴリの合計と増加分表示の説明ブロック
      source(
        file = paste0(COMPONENT_PATH, 'Main/DescriptionValue.ui.R'),
        local = T,
        encoding = 'UTF-8'
      )$value,
      footer = tags$small(paste(
        lang[[langCode]][62], UPDATE_DATETIME, '開発＆調整中'
      ))
    ),
  ),
  fluidRow(
    boxPlus(
      # 国内状況推移
      title = tagList(icon('chart-line'), lang[[langCode]][88]),
      closable = F,
      collapsible = T,
      collapsed = T,
      enable_label = T, 
      label_text = tagList('クリックして', icon('hand-point-right')), 
      label_status = 'warning',
      footer = tags$small(icon('lightbulb'), '凡例クリックすると表示・非表示の切替ができます。'),
      width = 12,
      tabsetPanel(
        id = 'linePlot',
        # 感染者数の推移
        source(
          file = paste0(COMPONENT_PATH, 'UiTabConfirmed.R'),
          local = T,
          encoding = 'UTF-8'
        )$value,
        # PCR検査数推移
        source(
          file = paste0(COMPONENT_PATH, 'UiTabPCR.R'),
          local = T,
          encoding = 'UTF-8'
        )$value,
        # 退院数推移
        source(
          file = paste0(COMPONENT_PATH, 'UiTabDischarged.R'),
          local = T,
          encoding = 'UTF-8'
        )$value
        ,
        # コールセンターの対応
        source(
          file = paste0(COMPONENT_PATH, 'UiTabCallCenter.R'),
          local = T,
          encoding = 'UTF-8'
        )$value
      )
    )
  ),
  fluidRow(
    boxPlus(title = tagList(icon('venus-mars'), '歳代・性別'),
            width = 4,
            enable_label = T,
            collapsible = T,
            collapsed = T,
            label_text = paste('集計時間：', max(as.Date(positiveDetail$発表日), na.rm = T)),
            echarts4rOutput('genderBar') %>% withSpinner(),
            closable = F,
            footer = tags$small('データ提供：', 
                                tags$a(icon('twitter'), '@kenmo_economics', 
                                       href = 'https://twitter.com/kenmo_economics')
                                )
            ),
    Component.SymptomsProgression()
  ),
  fluidRow(
    Component.NewsList(),
    Button.clusterTab(),
  )
)
