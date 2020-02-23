fluidRow(
  column(
    width = 8,
    leafletOutput('caseMap', height = '600px') %>% withSpinner()
  ),
  column(width = 4, dataTableOutput('detail') %>% withSpinner())
)
