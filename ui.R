source(file = "global.R",
       local = TRUE,
       encoding = "UTF-8")

shinyUI(dashboardPage(
  dashboardHeader(title = "2019-nCov 日本"),
  dashboardSidebar(disable = T),
  dashboardBody(fluidPage(fluidRow(
    valueBoxOutput(width = 3, "totalConfirmed"),
    valueBoxOutput(width = 3, "totalSuspicious"),
    valueBoxOutput(width = 3, "totalDeath"),
    valueBoxOutput(width = 3, "totalRecovered")
  ),fluidRow(
    box(
      width = 12,
      status = "primary",
      title = "新型コロナウイルス感染症マップ",
      plotOutput("map"),
      footer = paste(DATA_SOURCE, '(', UPDATE_TIME, ')')
    ),
    box(
      width = 12,
      status = 'info',
      title = "感染症の累積数",
      plotlyOutput("confirmedAccumulation"),
      footer = paste(DATA_SOURCE, '(', UPDATE_TIME, ')')
    )
  )))
))