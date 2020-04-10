fluidPage(
  fluidRow(
    column(width = 6, style='padding:0px;',
           widgetUserBox(
             title = '北海道', 
             subtitle = '北海道', 
             width = 12,
             src = 'Pref/hokkaido.png', 
             type = 2, 
             color = 'aqua-active',
             collapsible = F,
             paste0('こちらは北海道の発生状況をまとめたページです。', 
                    '厚労省のまとめより早く状況を把握できますが、',
                    '道の集計時間は厚労省との発表時間も完全に一致していないため、', 
                    'ライムラグによる数値の違いが生じる可能性もありますので、予めご注意してください。',
                    'また、速報では陰性から再び陽性になった人は再計算しないので、自治体の発表の陽性者数と数値が異なる場合があります。'
                    ),
             footer = tagList(
               tags$small(icon('database'),
                          tags$a(href = 'https://www.harp.lg.jp/opendata/dataset/1369.html',
                                 '新型コロナウイルス感染症に関するデータ【北海道】'),
                          icon('database'),
                          tags$a(href = 'https://signate.jp/competitions/260/discussions', 
                                 'SIGNATE - COVID-19 Chanllenge')
                          )
             )
           )
    ),
    column(width = 6,
      uiOutput('hokkaidoValueBoxes') %>% withSpinner(proxy.height = '200px')
    )
  ),
  fluidRow(
      boxPlus(
        width = 12, 
        title = tagList(icon('chart-line'), '北海道の発生状況'),
        closable = F,
        fluidRow(
          column(
            width = 6,
            echarts4rOutput('hokkaidoSummaryGraph') %>% withSpinner()
          ),
          column(
            width = 6,
            echarts4rOutput('hokkaidoStackGraph') %>% withSpinner()
          )
        ),
        footer = tags$small(icon('lightbulb'), '凡例クリックすると表示・非表示の切替ができます。')
      )
  ),
  # SIGNATE 問題修復まで非表示
  # fluidRow(
  #   boxPlus(
  #     width = 12,
  #     closable = F, 
  #     collapsed = T, 
  #     collapsible = T,
  #     enable_label = T, 
  #     label_text = tagList('クリックして', icon('hand-point-right')), 
  #     label_status = 'warning',
  #     title = tagList(icon('map-marked-alt'), '道内の感染者'),
  #     fluidRow(
  #       column(
  #         width = 8,
  #         leafletOutput('hokkaidoConfirmedMap', height = '500px') %>% withSpinner(),
  #         dataTableOutput('hokkaidoPatientTable') %>% withSpinner(),
  #       ),
  #       column(
  #         width = 4,
  #         uiOutput('hokkaidoProfile') %>% withSpinner()
  #       )
  #     )# ,
  #     # fluidRow(
  #     #   column(
  #     #     width = 8,
  #     #     dataTableOutput('hokkaidoPatientTable') %>% withSpinner(),
  #     #   )
  #     # )
  #   )
  # )
)