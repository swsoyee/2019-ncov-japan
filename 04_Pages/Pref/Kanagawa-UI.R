fluidPage(
  fluidRow(
    column(width = 6, style='padding:0px;'),
    column(width = 6,
           uiOutput('kanagawaValueBoxes') %>% withSpinner(proxy.height = '200px')
    )
  ),
  fluidRow(
    box(
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
      footer = tags$small(icon('lightbulb'), i18n$t("凡例クリックすると表示・非表示の切替ができます。"))
    )
  ),
  fluidRow(
    box(
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