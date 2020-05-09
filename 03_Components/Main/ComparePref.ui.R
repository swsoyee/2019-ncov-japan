tabPanel(
  title = tagList(icon("chart-bar"), i18n$t("多次元比較")),
  fluidRow(
    column(
      width = 6,
      pickerInput(
        inputId = "comparePref",
        label = "",
        choices = regionName[!regionName %in% c("都道府県", "チャーター便", "検疫職員", "クルーズ船", "伊客船")],
        options = list(
          `live-search` = TRUE
        )
      ),
      echarts4rOutput("comparePrefP1", height = "200px"),
      echarts4rOutput("comparePrefP2", height = "200px"),
      echarts4rOutput("comparePrefP3", height = "200px")
    )
  )
)
