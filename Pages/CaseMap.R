fluidPage(
  fluidRow(box(
    width = 12,
    dataTableOutput("detail") %>% withSpinner(),
    progressBar(
      id = "detailProgress",
      # 事例記録数 (更新中)
      title = paste(lang[[langCode]][69], " (", lang[[langCode]][70], ")"),
      value = nrow(detail),
      total = TOTAL_WITHIN
    )
  )),
  fluidRow(
    box(
      width = 12,
      collapsed = T,
      collapsible = T,
      leafletOutput("caseMap", height = "604px") %>% withSpinner(),
      tags$hr(),
      progressBar(
        id = "caseProgress",
        # 事例記録数 (更新中)
        title = paste(lang[[langCode]][69]),
        # , ' (', lang[[langCode]][70], ')'),
        value = length(activity),
        total = TOTAL_WITHIN
      ),
      title = "一人のメンテが大変すぎるので、更新中止となります。本当に申し訳ございません。"
    )
  )
)