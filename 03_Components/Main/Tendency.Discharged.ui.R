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
          width = 6,
          switchInput(
            inputId = "showShipInDischarge",
            label = icon("ship"),
            offLabel = icon("eye-slash"),
            onLabel = icon("eye"),
            value = F,
            inline = T
          ),
          switchInput(
            inputId = "showFlightInDischarge",
            label = icon("plane"),
            offLabel = icon("eye-slash"),
            onLabel = icon("eye"),
            value = T,
            inline = T
          )
        )
      ),
      echarts4rOutput("recoveredLine") %>% withSpinner()
    ),
    column(
      width = 4,
      tagList(
        tags$br(),
        uiOutput("dischargeSummary"),
        tags$b(i18n$t("退院者内訳")),
        echarts4rOutput("curedBar", height = "20px") %>% withSpinner(),
        uiOutput("todayCured"),
        tags$hr(),
        tags$b(i18n$t("退院者数（日次）"))
      ),
      echarts4rOutput("curedCalendar", height = "130px") %>% withSpinner()
    )
  )
)