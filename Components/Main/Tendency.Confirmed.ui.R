tabPanel(
  # 感染者数の推移
  title = lang[[langCode]][3],
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
            label = "表示モード",
            choices = c("一般", "片対数", "両対数"),
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
      tags$b("感染者"),
      echarts4rOutput("confirmedBar", height = "20px") %>% withSpinner(),
      uiOutput("todayConfirmed"),
      tags$br(),
      tags$b("死亡者"),
      echarts4rOutput("deathBar", height = "20px") %>% withSpinner(),
      uiOutput("todayDeath"),
      tags$hr(),
      tags$b("感染者確認数（日次）"),
      uiOutput("renderCalendar")
    )
  )
)