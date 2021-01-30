fluidRow(
  column(
    width = 12,
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
