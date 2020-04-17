fluidRow(
  boxPlus(
    title = "マップから見る発生・対応状況",
    width = 12,
    closable = F,
    # 凡例クリックすると表示・非表示の切替ができます。
    footer = tags$small(icon("lightbulb"), lang[[langCode]][128]),
    fluidRow(
      column(
        width = 6,
        echarts4rOutput("onSet2ConfirmedMap", height = "500px") %>% withSpinner()
      )
    )
  )
)