source(
  file = "global.R",
  local = T,
  encoding = "UTF-8"
)

shinyUI(
  dashboardPage(
    skin = "red",
    title = i18n$t("新型コロナウイルス感染速報"),
    options = list(sidebarExpandOnHover = TRUE),
    header = dashboardHeader(
      title = paste0("🦠　", i18n$t("新型コロナウイルス感染速報")),
      titleWidth = 350,
      controlbarIcon = icon("share-alt-square"),
      leftUi = tagList(
        dropdownBlock(
          id = "language-setting",
          title = i18n$t("言語"),
          icon = icon("language"),
          actionButton(
            inputId = "japaneseVersion",
            label = "日本語",
            style = "background-color:#FFFFFF;color:#BC002D;width:100%",
            onclick = sprintf(
              "window.open('%s')",
              "https://covid-2019.live/"
            ),
            disabled = i18n$translation_language != "ja"
          ),
          actionButton(
            inputId = "chineseVersion",
            label = "中文",
            style = "background-color:#df2407;color:#ffdf00;width:100%",
            onclick = sprintf(
              "window.open('%s')",
              "https://covid-2019.live/cn"
            ),
            disabled = i18n$translation_language != "cn"
          ),
          actionButton(
            inputId = "englishVersion",
            label = "English",
            style = "background-color:#3C3B6E;color:#FFFFFF;width:100%",
            onclick = sprintf(
              "window.open('%s')",
              "https://covid-2019.live/en"
            ),
            disabled = i18n$translation_language != "en"
          )
        )
      ),
      userOutput("user")
    ),
    controlbar = dashboardControlbar(
      id = "shareInSocial",
      controlbarMenu(
        id = "shareInSocailMenu",
        controlbarItem(
          i18n$t("状況をシェア"),
          actionButton(
            inputId = "twitterShare",
            label = "Twitter",
            icon = icon("twitter"),
            style = "background-color:#1DA1F2;color:white;",
            onclick = sprintf("window.open('%s')", twitterUrl)
          )
        )
      )
    ),
    sidebar = dashboardSidebar(
      collapsed = TRUE,
      sidebarMenu(
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
          badgeLabel = "Archived",
          badgeColor = "black"
        ),
        # menuItem(
        #   i18n$t("自治体状況"),
        #   tabName = "prefStatus",
        #   icon = icon("city"),
        #   menuSubItem(
        #     text = i18n$t("北海道"),
        #     tabName = "hokkaido" # ,
        #     # icon = icon("fish")
        #   ),
        #   # menuSubItem(
        #   #   text = i18n$t("青森県"),
        #   #   tabName = "aomori"#,
        #   #   # icon = icon("apple-alt")
        #   # ),
        #   # menuSubItem(
        #   #   text = i18n$t("岩手県"),
        #   #   tabName = "iwate" # ,
        #   #   # icon = icon('apple-alt')
        #   # ),
        #   # menuSubItem(
        #   #   text = i18n$t("宮城県"),
        #   #   tabName = "miyagi" # ,
        #   #   # icon = icon('apple-alt')
        #   # ),
        #   menuSubItem(
        #     text = i18n$t("茨城県"),
        #     tabName = "ibaraki" # ,
        #     # icon = icon('apple-alt')
        #   ),
        #   # menuSubItem(
        #   #   text = i18n$t("神奈川県"),
        #   #   tabName = "kanagawa" # ,
        #   #   # icon = icon('apple-alt')
        #   # ),
        #   menuSubItem(
        #     text = i18n$t("福岡県"),
        #     tabName = "fukuoka" # ,
        #     # icon = icon('apple-alt')
        #   )
        # ),
        menuItem(
          i18n$t("事例マップ"),
          tabName = "caseMap",
          icon = icon("map-marked-alt"),
          badgeLabel = "Archived",
          badgeColor = "black"
        ),
        # menuItem(
        #   "ECMOnet",
        #   tabName = "ecmo",
        #   icon = icon("hospital")
        # ),
        # menuItem(
        #   i18n$t("状況分析"),
        #   tabName = "academic",
        #   icon = icon("eye"),
        #   badgeLabel = "V 0.1",
        #   badgeColor = "black"
        # ),
        menuItem(
          # Google
          i18n$t("自粛効果"),
          tabName = "google",
          icon = icon("google"),
          badgeLabel = "Archived",
          badgeColor = "black"
        ),
        # menuItem(
        #   # World
        #   "World",
        #   tabName = "world",
        #   icon = icon("globe"),
        #   badgeLabel = "V 0.1",
        #   badgeColor = "black"
        # ),
        menuItem(
          i18n$t("サイトについて"),
          tabName = "about",
          icon = icon("readme"),
          badgeLabel = i18n$t("開発中"),
          badgeColor = "black"
        )
      )
    ),
    body = dashboardBody(
      tags$head(
        includeHTML(("01_Settings/google-analytics.html")),
        tags$link(rel = "icon", href = "favicon.ico"),
        tags$meta(name = "twitter:card", content = "summary_large_image"),
        # tags$meta(property = 'og:url', content = 'https://covid-2019.live/'),
        tags$meta(property = "og:title", content = "🦠新型コロナウイルス感染速報"),
        tags$meta(property = "og:description", content = "日本における新型コロナウイルスの最新感染・罹患情報をいち早く速報・まとめるサイトです。"),
        tags$meta(property = "og:image", content = "https://repository-images.githubusercontent.com/237152814/dd370680-634b-11eb-8fc9-2d3260344bdc")
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
        # tabItem(
        #   tabName = "hokkaido",
        #   source(
        #     file = paste0(PAGE_PATH, "Pref/Hokkaido-UI.R"),
        #     local = T,
        #     encoding = "UTF-8"
        #   )$value
        # ),
        # tabItem(
        #   tabName = "aomori",
        #   source(
        #     file = paste0(PAGE_PATH, "Pref/Aomori-UI.R"),
        #     local = T,
        #     encoding = "UTF-8"
        #   )$value
        # ),
        # tabItem(
        #   tabName = "iwate",
        #   source(
        #     file = paste0(PAGE_PATH, "Pref/Iwate-UI.R"),
        #     local = T,
        #     encoding = "UTF-8"
        #   )$value
        # ),
        # tabItem(
        #   tabName = "miyagi",
        #   source(
        #     file = paste0(PAGE_PATH, "Pref/Miyagi-UI.R"),
        #     local = T,
        #     encoding = "UTF-8"
        #   )$value
        # ),
        # tabItem(
        #   tabName = "ibaraki",
        #   source(
        #     file = paste0(PAGE_PATH, "Pref/Ibaraki-UI.R"),
        #     local = T,
        #     encoding = "UTF-8"
        #   )$value
        # ),
        # tabItem(
        #   tabName = "kanagawa",
        #   source(
        #     file = paste0(PAGE_PATH, "Pref/Kanagawa-UI.R"),
        #     local = T,
        #     encoding = "UTF-8"
        #   )$value
        # ),
        # tabItem(
        #   tabName = "fukuoka",
        #   source(
        #     file = paste0(PAGE_PATH, "Pref/Fukuoka-UI.R"),
        #     local = T,
        #     encoding = "UTF-8"
        #   )$value
        # ),
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
        # tabItem(
        #   tabName = "academic",
        #   source(
        #     file = paste0(PAGE_PATH, "/Academic/Academic.ui.R"),
        #     local = T,
        #     encoding = "UTF-8"
        #   )$value
        # ),
        tabItem(
          tabName = "google",
          source(
            file = paste0(PAGE_PATH, "/Google/PrefMobility.ui.R"),
            local = T,
            encoding = "UTF-8"
          )$value
        ),
        # tabItem(
        #   tabName = "world",
        #   source(
        #     file = paste0(PAGE_PATH, "/World/World.ui.R"),
        #     local = T,
        #     encoding = "UTF-8"
        #   )$value
        # ),
        tabItem(
          tabName = "about",
          source(
            file = paste0(PAGE_PATH, "/About/About.ui.R"),
            local = TRUE,
            encoding = "UTF-8"
          )$value
        )
      )
    ),
    footer = dashboardFooter(
      left = "Developed By Su Wei",
      right = "Copyright © 2020-2021, All Rights Reserved."
    )
  )
)
