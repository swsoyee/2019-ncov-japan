Component.NewsList <- function() {
  return(
    boxPlus(
      width = 4,
      # 情報源リンク集
      title = tagList(icon('newspaper'), lang[[langCode]][122]),
      collapsed = T,
      closable = F,
      collapsible = T,
      dataTableOutput('news') %>% withSpinner()
    )
  )
}