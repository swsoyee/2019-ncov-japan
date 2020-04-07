fluidPage(
  fluidRow(
    column(width = 6, style='padding:0px;',
           widgetUserBox(
             title = '神奈川県', 
             subtitle = '関東', 
             width = 12,
             type = 2, 
             color = 'aqua-active',
             collapsible = F,
             paste0('こちらは神奈川県の発生状況をまとめたページです。', 
                    '神奈川県のまとめより早く状況を把握できますが、',
                    '道の集計時間は厚労省との発表時間も完全に一致していないため、', 
                    'ライムラグによる数値の違いが生じる可能性もありますので、予めご注意してください。',
                    'また、速報では陰性から再び陽性になった人は再計算しないので、自治体の発表の陽性者数と数値が異なる場合があります。'
             ),
             footer = tagList(
               tags$small(icon('database'),
                          tags$a(href = 'https://www.pref.kanagawa.jp/osirase/1369/',
                                 '新型コロナウイルス感染症対策サイト'),
                          icon('database'),
                          tags$a(href = 'https://signate.jp/competitions/260/discussions', 
                                 'SIGNATE - COVID-19 Chanllenge')
               )
             )
           )
    ),
    column(width = 6,
           # uiOutput('hokkaidoValueBoxes') %>% withSpinner()
    )
  ),
  fluidRow(
    boxPlus(
      width = 12, 
      title = tagList(icon('chart-line'), '神奈川県の発生状況'),
      closable = F,
      fluidRow(
        column(
          width = 6,
          echarts4rOutput('kanagawaContact') %>% withSpinner()
        ),
        column(
          width = 6,
          echarts4rOutput('kanagawaPatientSummary') %>% withSpinner()
        )
      ),
      footer = tags$small(icon('lightbulb'), '凡例クリックすると表示・非表示の切替ができます。')
    )
  ),
  fluidRow(
    boxPlus(
      width = 12,
      closable = F, 
      collapsed = T, 
      collapsible = T,
      enable_label = T, 
      label_text = tagList('クリックして', icon('hand-point-right')), 
      label_status = 'warning',
      title = tagList(icon('map-marked-alt'), '県内の感染者')
      # fluidRow(
      #   column(
      #     width = 8,
      #     leafletOutput('hokkaidoConfirmedMap', height = '500px') %>% withSpinner(),
      #     dataTableOutput('hokkaidoPatientTable') %>% withSpinner(),
      #   ),
      #   column(
      #     width = 4,
      #     uiOutput('hokkaidoProfile') %>% withSpinner()
      #   )
      # )# ,
      # fluidRow(
      #   column(
      #     width = 8,
      #     dataTableOutput('hokkaidoPatientTable') %>% withSpinner(),
      #   )
      # )
    )
  )
)