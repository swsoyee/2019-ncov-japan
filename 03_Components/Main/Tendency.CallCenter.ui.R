tabPanel(
  title = "コールセンターの対応",
  icon = icon("headset"),
  value = "callCenter",
  fluidRow(
    column(
      width = 8,
      echarts4rOutput("callCenter") %>% withSpinner()
    ),
    column(
      width = 4,
      tagList(
        tags$br(),
        tags$b("これまでの主な相談内容"),
        tags$li("現在の症状に対する不安"),
        tags$li("予防法、消毒、対処法等医療に関する一般的事項"),
        tags$li("政府の対策についてのご意見"),
        tags$li("渡航に関する相談"),
        tags$li("国内発症例の詳細な行動履歴について"),
        tags$li("その他"),
        tags$br(),
        tags$a(
          href = "https://www.mhlw.go.jp/content/10906000/000601711.pdf",
          icon("link"),
          "厚生労働省コールセンターの対応状況等について"
        ),
        tags$hr(),
        tags$b("相談を受けた件数（日次）")
      ),
      echarts4rOutput("callCenterCanlendar", height = "130px") %>% withSpinner()
    )
  )
)