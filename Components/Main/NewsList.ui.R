Component.NewsList <- function() {
  return(
    boxPlus(
      width = 4,
      title = tagList(icon('newspaper'), '情報源リンク集'),
      collapsed = T,
      closable = F,
      collapsible = T,
      dataTableOutput('news') %>% withSpinner()
    )
  )
}