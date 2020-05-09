tabPanel(
  title = tagList(icon("chart-bar"), "多次元比較"),
  fluidRow(
    column(
      width = 6,
      pickerInput(
        inputId = "comparePref",
        label = "",
        choices = colnames(byDate)[2:48],
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
