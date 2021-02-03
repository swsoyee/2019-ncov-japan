fluidRow(
  box(
    title = i18n$t("現在の感染状況"), 
    width = 6, 
    height = "550px", 
    icon = icon("現在の感染状況"),
    sidebar = boxSidebar(
      id = "CurrentBoxtableOfEachPrefecturesBoxSidebar",
      width = 100,
      icon = icon("info-circle"),
      i18n$t("現在の感染状況")
    ),
    echarts4rOutput("currentActive", height = "550px") %>% withSpinner(proxy.height = "550px")
  )
)