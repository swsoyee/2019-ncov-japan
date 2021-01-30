fluidRow(
  column(
    width = 12,
    box(
      width = 12,
      collapsible = F,
      fluidRow(
        column(
          width = 12,
          tagList(
            includeMarkdown(
              paste0(
                "README",
                ifelse(languageSetting == "ja", "", paste0(".", languageSetting)),
                ".md"
              )
            )
          )
        )
      )
    )
  )
)
