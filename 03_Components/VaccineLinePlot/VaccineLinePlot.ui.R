tabPanel(
  title = tagList(
    "ワクチンの接種",
    boxLabel("New", status = "warning")
  ),
  icon = icon("syringe"),
  value = "vaccine",
  fluidRow(
    column(
      width = 8,
      tags$br(),
      echarts4rOutput("vaccineLine") %>% withSpinner()
    ),
    column(
      width = 4,
      tags$br(),
      tags$b("注意事項"),
      tags$li("土日祝日の数については、次の平日に合わせて計上しています。")
    )
  )
)
