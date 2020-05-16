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
    ),
    column(
      width = 6,
      echarts4rOutput("prefRadar") %>% withSpinner(),
      helpText(icon("exclamation-circle"), i18n$t("検査人数、百万人あたりの検査および陽性者数の三つの指標は、毎日の増加分を直近7日の移動平均を計算した数値です。"))
    )
  )
)
