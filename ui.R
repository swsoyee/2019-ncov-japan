source(file = 'global.R',
       local = T,
       encoding = 'UTF-8')

shinyUI(
  dashboardPagePlus(
    skin = "purple",
    title = lang[[langCode]][1],
    header = dashboardHeaderPlus(
      title = paste0('🦠', lang[[langCode]][1]),
      titleWidth = 350,
      dropdownMenu(type = 'notifications',
                   headerText = '', icon = icon('user-ninja'),
                   tags$li(
                       width = 12,
                       tags$br(),
                       boxProfile(
                         src = "profile.png",
                         title = tags$a(href = 'https://github.com/swsoyee/2019-ncov-japan', 'Su Wei'),
                         subtitle = tagList('Front-End Engineer', tags$small('(Bioinformatics)'))
                      )
                   )), 
      enable_rightsidebar = F
    ),
    # TODO 言語設定の追加
    sidebar = dashboardSidebar(sidebarMenu(
      id = 'sideBarTab',
      menuItem(
        # 感染速報
        lang[[langCode]][32],
        tabName = 'japan', 
        icon = icon('tachometer-alt'),
        badgeLabel = '更新中',
        badgeColor = 'purple'
      ),
      menuItem(
        # 事例マップ
        lang[[langCode]][33],
        tabName = 'caseMap',
        icon = icon('map-marked-alt'),
        badgeLabel = '開発中',
        badgeColor = 'black'
      ),
      menuItem(
        # 学術分析
        lang[[langCode]][34],
        tabName = 'academic',
        icon = icon('graduation-cap'),
        badgeLabel = '着手中',
        badgeColor = 'black'
      ),
      menuItem(
        # アプリについて
        lang[[langCode]][67],
        tabName = 'about',
        icon = icon('readme'),
        badgeLabel = '追加中',
        badgeColor = 'black'
      )
    )),
    # TODO 追加修正待ち
    # rightsidebar = rightSidebar(
    #   background = "dark",
    #   selectInput(inputId = 'language',
    #               label = lang[[langCode]][24], # 言語
    #               choices = languageSet)
    # ),
    dashboardBody(
      tags$head(tags$link(rel = "icon", href = "favicon.ico")),
      tabItems(
      tabItem(tabName = 'japan',
              source(
                file = paste0(PAGE_PATH, 'Japan.R'),
                local = T,
                encoding = 'UTF-8'
              )$value),
      tabItem(tabName = 'caseMap',
              source(
                file = paste0(PAGE_PATH, 'CaseMap.R'),
                local = T,
                encoding = 'UTF-8'
              )$value), 
      tabItem(tabName = 'academic',
              box(title = '準備中', width = 12)),
      tabItem(tabName = 'about',
              fluidRow(column(width = 12,tagList(includeMarkdown('www/about.md'))))
              )
    ))
  )
)
