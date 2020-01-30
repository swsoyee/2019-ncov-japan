source(file = "global.R",
       local = TRUE,
       encoding = "UTF-8")

shinyUI(dashboardPage(
  dashboardHeader(title = "2019-nCov 日本"),
  dashboardSidebar(disable = T),
  dashboardBody(fluidPage(fluidRow(
    box(
      width = 12,
      status = "primary",
      title = "新型コロナウイルス感染症マップ",
      plotOutput("map"),
      footer = "ソース：厚生労働省（2020-01-30 00:00）"
    ),
    box(
      width = 12,
      status = "info",
      title = "感染症の累積数",
      plotlyOutput("confirmedAccumulation"),
      footer = "ソース：厚生労働省（2020-01-30 00:00）"
    )
  )))
))