fluidRow(
  boxPlus(
    width = 12,
    closable = F,
    title = tagList(icon("globe"), "World Map"),
    fluidRow(
      column(
        width = 8,
        uiOutput("worldConfirmedDateSelector"),
        echarts4rOutput("worldConfirmed", height = "600px") %>% withSpinner()
        ),
      column(
        width = 4,
        echarts4rOutput("countryLine") %>% withSpinner()
      )
    )
  )
)
