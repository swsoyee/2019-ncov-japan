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
      tags$p("今までに接種が行われた新型コロナワクチンの接種回数や施設数などの情報をお届けします。"),
      fluidRow(
        column(width = 6, uiOutput("vaccineTotal")),
        column(width = 6, uiOutput("vaccineFacility"))
      ),
      uiOutput("vaccineProgress"),
      tags$b("注意事項"),
      tags$li("土日祝日の数については、次の平日に合わせて計上しています。"),
      tags$li("各施設が17時時点の実績をワクチン接種円滑化システム（V-SYS）を通して報告したものを集計しています。"),
      tags$li("施設数は当該日付までに接種実績のある施設数です。")
    )
  )
)
