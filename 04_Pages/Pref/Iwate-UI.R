fluidPage(
  fluidRow(
    column(
      width = 6, style = "padding:0px;"
    ),
    column(
      width = 6,
      uiOutput("IwateValueBoxes") %>% withSpinner(proxy.height = "200px")
    )
  ),
  fluidRow(
    box(
      width = 12,
      closable = F,
      title = tagList(icon("chart-line"), sprintf(i18n$t("%sの発生状況"), i18n$t("岩手県"))),
      fluidRow(
        column(
          width = 6,
          echarts4rOutput("IwateContact") %>% withSpinner()
        ),
        column(
          width = 6,
          echarts4rOutput("IwateSummary") %>% withSpinner()
        )
      ),
      footer = tags$small(icon("lightbulb"), i18n$t("凡例クリックすると表示・非表示の切替ができます。"))
    )
  ),
  fluidRow(
    box(
      width = 12,
      closable = F,
      collapsed = T,
      collapsible = T,
      enable_label = T,
      label_text = tagList(i18n$t("もっと見る"), icon("hand-point-right")),
      label_status = "warning",
      # title = tagList(icon('map-marked-alt'), '道内の感染者'),
      fluidRow(
        column(
          width = 8,
          # leafletOutput('hokkaidoConfirmedMap', height = '500px') %>% withSpinner(),
          # dataTableOutput('hokkaidoPatientTable') %>% withSpinner(),
        ),
        column(
          width = 4,
          # uiOutput('hokkaidoProfile') %>% withSpinner()
        )
      ) # ,
      # fluidRow(
      #   column(
      #     width = 8,
      #     dataTableOutput('hokkaidoPatientTable') %>% withSpinner(),
      #   )
      # )
    )
  )
)
