source(file = 'global.R',
       local = T,
       encoding = 'UTF-8')

shinyUI(
  dashboardPagePlus(
    skin = "red",
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
        badgeColor = 'red'
      ),
      menuItem(
        # 感染ルート
        '感染ルート',
        tabName = 'route',
        icon = icon('project-diagram'),
        badgeLabel = '開発中',
        badgeColor = 'black'
      ),
      menuItem(
        # 自治体状況
        '自治体状況',
        tabName = 'prefStatus',
        icon = icon('city'),
        menuSubItem(
          text = '北海道', 
          tabName = 'hokkaido',
          icon = icon('fish')
        ),
        menuSubItem(
          text = '青森県', 
          tabName = 'aomori',
          icon = icon('apple-alt')
        ),
        menuSubItem(
          text = '岩手県', 
          tabName = 'iwate'#,
          # icon = icon('apple-alt')
        ),
        menuSubItem(
          text = '宮城県', 
          tabName = 'miyagi'#,
          # icon = icon('apple-alt')
        ),
        menuSubItem(
          text = '茨城県', 
          tabName = 'ibaraki'#,
          # icon = icon('apple-alt')
        ),
        menuSubItem(
          text = '神奈川県', 
          tabName = 'kanagawa'#,
          # icon = icon('apple-alt')
        )
      ),
      menuItem(
        # 事例マップ
        lang[[langCode]][33],
        tabName = 'caseMap',
        icon = icon('map-marked-alt'),
        badgeLabel = '破棄中',
        badgeColor = 'black'
      ),
      menuItem(
        # 状況分析
        '状況分析',
        tabName = 'academic',
        icon = icon('eye'),
        badgeLabel = '追加中',
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
      tags$head(
        tags$link(rel = "icon", href = "favicon.ico"),
        tags$meta(name = 'twitter:card', content = 'summary_large_image'),
        # tags$meta(property = 'og:url', content = 'https://covid-2019.live/'),
        tags$meta(property = 'og:title', content = '🦠新型コロナウイルス感染速報'),
        tags$meta(property = 'og:description', content = '日本における新型コロナウイルスの最新感染・罹患情報をいち早く速報・まとめるサイトです。'),
        tags$meta(property = 'og:image', content = 'https://repository-images.githubusercontent.com/237152814/47b7c400-753a-11ea-8de6-8364c08e37c9')
        ),
      tabItems(
      tabItem(tabName = 'japan',
              source(
                file = paste0(PAGE_PATH, 'Main/Main.ui.R'),
                local = T,
                encoding = 'UTF-8'
              )$value),
      tabItem(tabName = 'route',
              source(
                file = paste0(PAGE_PATH, 'Route.R'),
                local = T,
                encoding = 'UTF-8'
              )$value),
      tabItem(tabName = 'hokkaido',
              source(
                file = paste0(PAGE_PATH, 'Pref/Hokkaido-UI.R'),
                local = T,
                encoding = 'UTF-8'
              )$value),
      tabItem(tabName = 'aomori',
              source(
                file = paste0(PAGE_PATH, 'Pref/Aomori-UI.R'),
                local = T,
                encoding = 'UTF-8'
              )$value),
      tabItem(tabName = 'iwate',
              source(
                file = paste0(PAGE_PATH, 'Pref/Iwate-UI.R'),
                local = T,
                encoding = 'UTF-8'
              )$value),
      tabItem(tabName = 'miyagi',
              source(
                file = paste0(PAGE_PATH, 'Pref/Miyagi-UI.R'),
                local = T,
                encoding = 'UTF-8'
              )$value),
      tabItem(tabName = 'ibaraki',
              source(
                file = paste0(PAGE_PATH, 'Pref/Ibaraki-UI.R'),
                local = T,
                encoding = 'UTF-8'
              )$value),
      tabItem(tabName = 'kanagawa',
              source(
                file = paste0(PAGE_PATH, 'Pref/Kanagawa-UI.R'),
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
              source(
                file = paste0(PAGE_PATH, '/Academic/Academic.ui.R'),
                local = T,
                encoding = 'UTF-8'
              )$value),
      tabItem(tabName = 'about',
              fluidRow(column(width = 12,tagList(includeMarkdown('www/about.md'))))
              )
    ))
  )
)
