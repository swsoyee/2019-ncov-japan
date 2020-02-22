fluidPage(
  fluidRow(leafletOutput('caseMap') %>% withSpinner())
)