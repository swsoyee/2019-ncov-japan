source(
  file = "global.R",
  local = T,
  encoding = "UTF-8"
)

shinyUI(
  dashboardPagePlus(
    skin = "red",
    title = i18n$t("新　型　コ　ロ　ナ　ウ　イ　ル　ス　感　染　速　報"),
    header = dashboardHeaderPlus(
      title = paste0("🦠　", i18n$t("新　型　コ　ロ　ナ　ウ　イ　ル　ス　感　染　速　報")),
      titleWidth = 600,
      enable_rightsidebar = F
    ),
    # TODO 言語設定の追加
    sidebar = dashboardSidebar(sidebarMenu(
      id = "sideBarTab",
      menuItem(
        i18n$t("感染速報"),
        tabName = "japan",
        icon = icon("tachometer-alt"),
        badgeLabel = i18n$t("実況中"),
        badgeColor = "red"
      ),
      menuItem(
        i18n$t("感染ルート"),
        tabName = "route",
        icon = icon("project-diagram"),
        badgeLabel = i18n$t("開発中"),
        badgeColor = "black"
      ),
      menuItem(
        i18n$t("自治体状況"),
        tabName = "prefStatus",
        icon = icon("city"),
        menuSubItem(
          text = i18n$t("北海道"),
          tabName = "hokkaido"#,
          # icon = icon("fish")
        ),
        menuSubItem(
          text = i18n$t("青森県"),
          tabName = "aomori"#,
          # icon = icon("apple-alt")
        ),
        menuSubItem(
          text = i18n$t("岩手県"),
          tabName = "iwate" # ,
          # icon = icon('apple-alt')
        ),
        menuSubItem(
          text = i18n$t("宮城県"),
          tabName = "miyagi" # ,
          # icon = icon('apple-alt')
        ),
        menuSubItem(
          text = i18n$t("茨城県"),
          tabName = "ibaraki" # ,
          # icon = icon('apple-alt')
        ),
        # menuSubItem(
        #   text = i18n$t("神奈川県"),
        #   tabName = "kanagawa" # ,
        #   # icon = icon('apple-alt')
        # ),
        menuSubItem(
          text = i18n$t("福岡県"),
          tabName = "fukuoka" # ,
          # icon = icon('apple-alt')
        )
      ),
      menuItem(
        i18n$t("事例マップ"),
        tabName = "caseMap",
        icon = icon("map-marked-alt"),
        badgeLabel = i18n$t("破棄"),
        badgeColor = "black"
      ),
      # menuItem(
      #   "ECMOnet",
      #   tabName = "ecmo",
      #   icon = icon("hospital")
      # ),
      menuItem(
        i18n$t("状況分析"),
        tabName = "academic",
        icon = icon("eye"),
        badgeLabel = "V 0.1",
        badgeColor = "black"
      ),
      menuItem(
        # Google
        i18n$t("自粛効果"),
        tabName = "google",
        icon = icon("google"),
        badgeLabel = "V 0.1",
        badgeColor = "black"
      ),
      menuItem(
        # Google
        "World",
        tabName = "world",
        icon = icon("globe"),
        badgeLabel = "V 0.1",
        badgeColor = "black"
      ),
      menuItem(
        i18n$t("サイトについて"),
        tabName = "about",
        icon = icon("readme"),
        badgeLabel = i18n$t("開発中"),
        badgeColor = "black"
      )
    )),
    dashboardBody(
      tags$head(
        tags$link(rel = "icon", href = "favicon.ico"),
        tags$meta(name = "twitter:card", content = "summary_large_image"),
        # tags$meta(property = 'og:url', content = 'https://covid-2019.live/'),
        tags$meta(property = "og:title", content = "🦠新型コロナウイルス感染速報"),
        tags$meta(property = "og:description", content = "日本における新型コロナウイルスの最新感染・罹患情報をいち早く速報・まとめるサイトです。"),
        tags$meta(property = "og:image", content = "https://repository-images.githubusercontent.com/237152814/77329f80-917c-11ea-958c-731c8433c504")
      ),
      tabItems(
        tabItem(
          tabName = "japan",
          source(
            file = paste0(PAGE_PATH, "Main/Main.ui.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        tabItem(
          tabName = "route",
          source(
            file = paste0(PAGE_PATH, "Route.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        tabItem(
          tabName = "hokkaido",
          source(
            file = paste0(PAGE_PATH, "Pref/Hokkaido-UI.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        tabItem(
          tabName = "aomori",
          source(
            file = paste0(PAGE_PATH, "Pref/Aomori-UI.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        tabItem(
          tabName = "iwate",
          source(
            file = paste0(PAGE_PATH, "Pref/Iwate-UI.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        tabItem(
          tabName = "miyagi",
          source(
            file = paste0(PAGE_PATH, "Pref/Miyagi-UI.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        tabItem(
          tabName = "ibaraki",
          source(
            file = paste0(PAGE_PATH, "Pref/Ibaraki-UI.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        tabItem(
          tabName = "kanagawa",
          source(
            file = paste0(PAGE_PATH, "Pref/Kanagawa-UI.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        tabItem(
          tabName = "fukuoka",
          source(
            file = paste0(PAGE_PATH, "Pref/Fukuoka-UI.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        tabItem(
          tabName = "caseMap",
          source(
            file = paste0(PAGE_PATH, "CaseMap.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        # tabItem(
        #   tabName = "ecmo",
        #   source(
        #     file = paste0(PAGE_PATH, "/ECMO/ECMO.ui.R"),
        #     local = T,
        #     encoding = "UTF-8"
        #   )$value
        # ),
        tabItem(
          tabName = "academic",
          source(
            file = paste0(PAGE_PATH, "/Academic/Academic.ui.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        tabItem(
          tabName = "google",
          source(
            file = paste0(PAGE_PATH, "/Google/PrefMobility.ui.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        tabItem(
          tabName = "world",
          source(
            file = paste0(PAGE_PATH, "/World/World.ui.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        tabItem(
          tabName = "about",
          fluidRow(
            column(
              width = 12,
              boxPlus(
                width = 12,
                collapsible = F,
                fluidRow(
                  column(
                    width = 12,
                    tagList(
                      includeMarkdown(paste0("README", ifelse(languageSetting == "ja", "", paste0(".", languageSetting)), ".md"))
                    )
                  )
                )
              )
            )
          )
        )
      )
    ),
    footer = dashboardFooter(
      left_text = tagList(userPost(
        id = 1,
        src = "profile.png",
        author = tagList(
          tags$small("Developed by"),
          "Su Wei"
        ),
        collapsible = F,
        description = "Front-End Engineer | ex-Bioinformatician"
      )),
      right_text = tagList(
        tags$div(
          style = "font-size:22px;letter-spacing: .3rem;",
          tags$a(href = "https://github.com/swsoyee/2019-ncov-japan", icon("github")),
          tags$a(href = "https://twitter.com/swsoyee", icon("twitter")),
          tags$a(href = "https://www.linkedin.com/in/infinityloop/", icon("linkedin"))
        )
      )
    )
  )
)
