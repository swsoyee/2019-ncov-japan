tabPanel(
  title = i18n$t("コールセンターの対応"),
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
        tags$b(i18n$t("これまでの主な相談内容")),
        tags$li(i18n$t("現在の症状に対する不安")),
        tags$li(i18n$t("予防法、消毒、対処法等医療に関する一般的事項")),
        tags$li(i18n$t("政府の対策についてのご意見")),
        tags$li(i18n$t("渡航に関する相談")),
        tags$li(i18n$t("国内発症例の詳細な行動履歴について")),
        tags$li(i18n$t("その他")),
        tags$br(),
        tags$a(
          href = "https://www.mhlw.go.jp/content/10906000/000601711.pdf",
          icon("link"),
          i18n$t("厚生労働省コールセンターの対応状況等について")
        ),
        tags$hr(),
        tags$b(i18n$t("相談を受けた件数（日次）"))
      ),
      echarts4rOutput("callCenterCanlendar", height = "130px") %>% withSpinner()
    )
  )
)