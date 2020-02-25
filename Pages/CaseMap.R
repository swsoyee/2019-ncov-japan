fluidRow(
  column(
    width = 12,
    leafletOutput('caseMap', height = '604px') %>% withSpinner(),
    tags$hr(),
    progressBar(id = 'caseProgress', 
                # 事例記録数 (更新中)
                title = paste(lang[[langCode]][69], ' (', lang[[langCode]][70], ')'),
                value = length(activity), 
                total = TOTAL_WITHIN)
  ),
  # column(width = 4, dataTableOutput('detail') %>% withSpinner(),
  #        progressBar(id = 'detailProgress', 
  #                    # 事例記録数 (更新中)
  #                    title = paste(lang[[langCode]][69], ' (', lang[[langCode]][70], ')'),
  #                    value = nrow(detail), 
  #                    total = TOTAL_WITHIN))
)
