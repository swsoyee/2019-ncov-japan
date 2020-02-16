source(file = 'global.R',
       local = T,
       encoding = 'UTF-8')

shinyUI(
  dashboardPagePlus(
    skin = "purple",
    header = dashboardHeaderPlus(
      title = paste0('🦠', lang[[langCode]][1]),
      titleWidth = 350,
      enable_rightsidebar = F
    ),
    # TODO 言語設定の追加
    sidebar = dashboardSidebar(sidebarMenu(
      menuItem(
        lang[[langCode]][32],
        # 日本
        tabName = 'japan',
        badgeLabel = UPDATE_DATE,
        badgeColor = 'purple',
        icon = tags$i('🇯🇵')
      ),
      menuItem(
        lang[[langCode]][34],
        # 中国
        tabName = 'china',
        badgeLabel = '開発中',
        badgeColor = 'black',
        icon = tags$i('🇨🇳')
      ),
      menuItem(
        lang[[langCode]][33],
        # 世界
        tabName = 'world',
        badgeLabel = '開発中',
        badgeColor = 'black',
        icon = tags$i('🗺️')
      )
    )),
    # TODO 追加修正待ち
    # rightsidebar = rightSidebar(
    #   background = "dark",
    #   selectInput(inputId = 'language',
    #               label = lang[[langCode]][24], # 言語
    #               choices = languageSet)
    # ),
    dashboardBody(tabItems(
      tabItem(tabName = 'japan',
              source(
                file = paste0(PAGE_PATH, 'Japan.R'),
                local = T,
                encoding = 'UTF-8'
              )$value),
      tabItem(tabName = 'china',
              box(title = '準備中', width = 12)),
      tabItem(tabName = 'world',
              box(title = '準備中', width = 12))

    ))
  )
)
