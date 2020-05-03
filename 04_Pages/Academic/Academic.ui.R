fluidRow(
  boxPlus(
    title = "マップから見る発生・対応状況",
    width = 12,
    closable = F,
    footer = tags$small(icon("lightbulb"), i18n$t("凡例クリックすると表示・非表示の切替ができます。")),
    fluidRow(
      column(
        width = 6,
        echarts4rOutput("onset_to_confirmed_map", height = "500px") %>% withSpinner()
      )
    )
  )
)