source(file = 'global.R',
       local = T,
       encoding = 'UTF-8')

shinyUI(dashboardPagePlus(
  skin = "purple",
  header = dashboardHeaderPlus(title = lang[[langCode]][1], 
                               titleWidth = 350,
                               enable_rightsidebar = F), # TODO 言語設定の追加
  sidebar = dashboardSidebar(disable = F),
  # TODO 追加修正待ち
  # rightsidebar = rightSidebar(
  #   background = "dark",
  #   selectInput(inputId = 'language',
  #               label = lang[[langCode]][24], # 言語
  #               choices = languageSet)
  # ),
  dashboardBody(
    source(file = paste0(PAGE_PATH, 'Japan.R'),
           local = T,
           encoding = 'UTF-8')
  )
))
