# 実効再生産数
tabPanel(
  title = tagList(icon("chart-line"), i18n$t("実効再生産数")),
  fluidRow(
    column(
      width = 8,
      echarts4rOutput(
        outputId = "RtLine",
        height = "400px"
      ) %>%
        withSpinner(
          proxy.height = "400px"
        )
    ),
    column(
      width = 4
    )
  )
)
