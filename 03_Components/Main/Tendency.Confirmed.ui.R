tabPanel(
  title = i18n$t("感染者数の推移"),
  icon = icon("procedures"),
  value = "confirmed",
  fluidRow(
    column(
      width = 8,
      fluidRow(
        tags$br(),
        column(
          width = 4,
          radioGroupButtons(
            inputId = "selectTendencyConfirmedMode",
            label = i18n$t("表示モード"), 
            choiceNames = c(i18n$t("一般"), i18n$t("片対数"), i18n$t("両対数")),
            choiceValues = c("一般", "片対数", "両対数"),
            status = "danger",
          )
        ),
        column(
          width = 6,
          uiOutput("tendencyConfirmedRegionPicker")
        )
      ),
      uiOutput("confirmedLineWrapper") %>% withSpinner()
    ),
    column(
      width = 4,
      tags$br(),
      tags$b(i18n$t("感染")),
      echarts4rOutput("confirmedBar", height = "20px") %>% withSpinner(),
      uiOutput("todayConfirmed"),
      tags$br(),
      tags$b(i18n$t("死亡")),
      echarts4rOutput("deathBar", height = "20px") %>% withSpinner(),
      uiOutput("todayDeath"),
      tags$hr(),
      tags$b(i18n$t("感染新規数（日次）")),
      uiOutput("renderCalendar")
    )
  )
)