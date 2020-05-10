tabPanel(
  title = i18n$t("退院者数の推移"),
  icon = icon("user-shield"),
  value = "discharged",
  fluidRow(
    column(
      width = 8,
      tags$br(),
      fluidRow(
        column(
          width = 6
        )
      ),
      echarts4rOutput("recoveredLine") %>% withSpinner()
    ),
    column(
      width = 4,
      tagList(
        tags$br(),
        uiOutput("dischargeSummary"),
        tags$hr(),
        tags$b(i18n$t("退院者数（日次）"))
      ),
      echarts4rOutput("curedCalendar", height = "130px") %>% withSpinner()
    )
  )
)