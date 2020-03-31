fluidPage(fluidRow(column(
  width = 12,
  boxPlus(
    width = 12,
    title = tagList(icon('connectdevelop'), 'クラスターネットワーク'),
    footer = tags$small(icon('database'), 
                     'データ提供：', 
                     tags$a(href = 'https://signate.jp/competitions/260/discussions', 'SIGNATE - COVID-19 Chanllenge')
                     ),
    fluidRow(column(
      width = 8,
      fluidRow(column(
        width = 12,
        pickerInput(
          inputId = 'clusterRegionPicker',
          # 地域選択
          label = lang[[langCode]][93],
          choices = provinceSelector,
          selected = 23,
          options = list(
            `actions-box` = TRUE,
            size = 10,
            # クリア
            `deselect-all-text` = lang[[langCode]][91],
            # 全部
            `select-all-text` = lang[[langCode]][92],
            # 三件以上選択されました
            `selected-text-format` = lang[[langCode]][94],
            `max-options` = 5
          ),
          multiple = T,
          inline = T
        )
      )),
      fluidRow(column(
        width = 12,
        uiOutput('clusterNetworkWrapper') %>% withSpinner()
      ))
    ),
    column(
      width = 4,
      uiOutput('profile'),
      tags$h5('注意事項'),
      tags$small(
        tags$li(paste0('当クラスターネットワークは、株式会社SIGNATEが提供したデータセットおよびリンク情報',
                    '（SIGNATE COVID-19 Dataset）をそのまま可視化したものです。',
                    '感染者数が急速に拡大していて、公表されている情報も限られているため、',
                    'クラスターネットワークの正確性の保障は一切ないので、予めご了承ください。',
                    'あくまで参考用です。'
                    )),
      tags$li('データセット自身の問題で、ある患者は、多数の患者とリンクがあるとしても、クラスターの中心とはいえませんのでご了承ください。'),
      tags$li(
        paste0('本分析に用いたデータセット（SIGNATE COVID-19 Dataset）は、現在、収集途中のものであり、データの正確性を保証するものではありません。',
        'また、本データセットは基本的に厚労省・自治体等の報道における症例データに基づいて作成されており、', '
        各種機関が発表している統計データと一致しないことがあります。予めご了承ください。')),
      tags$li('更新頻度は二三日一回となります。データセットに貢献したい有志はぜひ下記のリンク先でデータの追加や訂正をしてください。'),
      tags$a(href = 'https://signate.jp/competitions/260/discussions', 'SIGNATE - COVID-19 Chanllenge')
      )
    )
    )
  )
)),
fluidRow(column(
  width = 12,
  boxPlus(
    width = 8,
    title = tagList(icon('project-diagram'), '感染経路'),
    enable_label = T,
    collapsible = T,
    label_text = paste('集計時間：', max(
      as.Date(positiveDetail$発表日, '%m月%d日'), na.rm = T
    )),
    closable = F,
    footer = tags$small(
      icon('database'),
      'データ提供：',
      tags$a(icon('twitter'), '@kenmo_economics',
             href = 'https://twitter.com/kenmo_economics'),
      ' 不定期更新。また最新のデータの整理について時間がかかり、直近数日の各都道府県の感染者数と一致しない場合がありますので、予めご了承下さい。'
    ),
    fluidRow(column(
      width = 12,
      pickerInput(
        inputId = 'infectedRouteByRegionPicker',
        # 地域選択
        label = lang[[langCode]][93],
        choices = selectProvinceOption,
        selected = '東京都',
        options = list(
          `actions-box` = TRUE,
          size = 10,
          # クリア
          `deselect-all-text` = lang[[langCode]][91],
          # 全部
          `select-all-text` = lang[[langCode]][92],
          # 三件以上選択されました
          `selected-text-format` = lang[[langCode]][94]
        ),
        multiple = T,
        inline = T
      )
    )),
    echarts4rOutput('infectedRouteByRegion') %>% withSpinner()
  )
)))