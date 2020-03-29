fluidPage(
  # fluidRow(
  #   box(width = 12,
  #       solidHeader = T,
  #       status = 'info',
  #       title = tagList(icon('info'), '通知'),
  #       collapsible = T,
  #       collapsed = T, 
  #       tags$small(
  #         paste0(
  #           '機能開発もデータの収集も全部ひとりで担当をしているので、',
  #           '患者さんの行動歴や厚生労働省が発表しているデータの整理を協力できる有志がございましたら是非Pull Requestを：'
  #         ),
  #         tags$a(href = 'https://github.com/swsoyee/2019-ncov-japan', 'Github'),
  #         '。一人でメンテナンスすることはやはり限度があります。データの更新だけで精一杯であり、機能開発はなかなか着手できませんでした。'
  #       ))
  # ),
  # メイン部分、Valueboxを含むなど
  source(
    file = paste0(COMPONENT_PATH, 'UiRowMain.R'),
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
          file = paste0(COMPONENT_PATH, 'UiTabRegionConfirmedMap.R'),
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
        file = paste0(COMPONENT_PATH, 'UiRowDescriptionValue.R'),
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
        # コールセンターの対応
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
            label_text = paste('集計時間：', max(as.Date(positiveDetail$発表日, '%m月%d日'), na.rm = T)),
            echarts4rOutput('genderBar') %>% withSpinner(),
            closable = F,
            footer = tags$small('データ提供：', 
                                tags$a(icon('twitter'), '@kenmo_economics', 
                                       href = 'https://twitter.com/kenmo_economics')
                                )
            ),
    boxPlus(title = tagList(icon('hospital'), '症状の進行'),
            width = 8,
            closable = F,
            collapsible = T, 
            collapsed = T,
            dateInput(
              inputId = 'selectProcessDay', 
              label = '日付選択', 
              min = domesticDailyReport$date[1], 
              max = domesticDailyReport$date[nrow(domesticDailyReport)], 
              value = domesticDailyReport$date[nrow(domesticDailyReport)], language = 'ja'
            ),
            tags$small(
              paste0('3月28日以後、厚労省集計方法が変更あり、',
                     '無症状患者の内訳は公表しないため、',
                     '無症状患者がどのぐらい入院しているかの情報がなくなりました。',
                     'こちらではグラフ作成するため、無症状者は一律入院必要ないという仮説を設定した上で、グラフを作りました。',
                     'よって、該当グラフはあくまで参考です。')
              ),
            echarts4rOutput('processSankey') %>% withSpinner(),
            footer = tags$small('※開発バージョンです。')
    ),
  ),
  fluidRow(
    boxPlus(width = 4,
            title = tagList(icon('newspaper'), '情報源リンク集'),
            collapsed = T, 
            collapsible = T,
            dataTableOutput('news') %>% withSpinner()),
    boxPlus(title = tagList(icon('connectdevelop'), '感染経路ネットワーク'),
            width = 8,
            closable = F,
            collapsible = T,
            collapsed = T,
            echarts4rOutput('network') %>% withSpinner(),
            enable_sidebar = T,
            sidebar_start_open = F,
            sidebar_content = tagList(
              checkboxInput('hideSingle', '離散を非表示', T)
            ),
            footer = tags$small('3月9日以後に、厚労省のページでは感染者の詳細情報についての発表は中止になり、こちらのデータ更新も止むを得ず中止になりました。'))
  )
)
