fluidRow(
  boxPlus(
    title = 'マップから見る発生・対応状況', 
    width = 12,
    closable = F, 
    fluidRow(
      column(
        width = 6,
        echarts4rOutput('onSet2ConfirmedMap', height = '500px') %>% withSpinner()
      )
    )
  )
)