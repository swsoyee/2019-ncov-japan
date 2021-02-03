fluidRow(
  box(
    title = tagList(
      icon("table"),
      i18n$t("各都道府県の状況")
    ), 
    width = 12, 
    sidebar = boxSidebar(
      id = "tableOfEachPrefecturesBoxSidebar",
      width = 25,
      materialSwitch(
        inputId = "tableGrouping",
        label = tagList(icon("object-group"), i18n$t("グルーピング表示")),
        status = "danger",
        value = TRUE
      )
    ),
    dataTableOutput("TableOfEachPrefectures") %>% withSpinner()
  )
)
