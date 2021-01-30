fluidRow(
  column(
    width = 12,
    box(
      title = i18n$t("プロジェクトメンバー"),
      icon = icon("users"),
      width = 6,
      userList(
        userListItem(
          image = "Icon/wei_su.jpg",
          title = tags$a(
            href = "https://twitter.com/swsoyee",
            icon("twitter"),
            tags$b("Wei_Su")
          ),
          subtitle = i18n$t("設立者・開発")
        ),
        userListItem(
          image = "Icon/anonymous.jpeg",
          title = tags$a(
            href = "https://github.com/Bob-FU",
            icon("github"),
            tags$b("Bob-Fu")
          ),
          subtitle = i18n$t("インフラ")
        ),
        userListItem(
          image = "Icon/zoie.jpg",
          title = tags$a(
            href = "https://twitter.com/zoiesywong",
            icon("twitter"),
            tags$b("Zoie, PhD")
          ),
          subtitle = i18n$t("学術指導")
        ),
        userListItem(
          image = "Icon/emckk.png",
          title = tags$a(
            href = "https://github.com/emc-kk",
            icon("github"),
            tags$b("emckk")
          ),
          subtitle = i18n$t("データ")
        )
      )
    ),
    box(
      title = i18n$t("プロジェクトスポンサー"),
      icon = icon("hand-holding-usd"),
      width = 6,
      userList(
        userListItem(
          image = "Icon/yukinobu_nishio.jpg",
          title = tags$a(
            href = "https://twitter.com/yukinobunishio",
            icon("twitter"),
            tags$b("YukinobuNISHIO")
          ),
          subtitle = sprintf("~ %s", as.Date("20210106", format = "%Y%m%d"))
        ),
        userListItem(
          image = "Icon/uryu_shinya.jpg",
          title = tags$a(
            href = "https://twitter.com/u_ribo",
            icon("twitter"),
            tags$b("Uryu Shinya")
          ),
          subtitle = sprintf("~ %s", as.Date("20201102", format = "%Y%m%d"))
        ),
        userListItem(
          image = "Icon/marchhare31.png",
          title = tags$a(
            href = "https://github.com/marchhare31",
            icon("github"),
            tags$b("marchhare31")
          ),
          subtitle = sprintf("~ %s", as.Date("20201103", format = "%Y%m%d"))
        ),
        userListItem(
          image = "Icon/anonymous.jpeg",
          title = "Anonymous",
          subtitle = sprintf("~ %s", as.Date("20201102", format = "%Y%m%d"))
        )
      )
    ),
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
