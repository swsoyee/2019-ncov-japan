fluidPage(
  boxPlus(
    width = 8, 
    closable = F,
    title = tagList(icon("globe"), "World Map"),
    echarts4rOutput("worldConfirmed", height = "600px") %>% withSpinner()
  )
)
