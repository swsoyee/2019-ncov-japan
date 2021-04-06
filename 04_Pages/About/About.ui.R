fluidRow(
  column(
    width = 12,
    box(
      title = i18n$t("プロジェクトメンバー"),
      icon = icon("users"),
      width = 6,
      userList(
        UserListItemWrappter(
          image = "Icon/wei_su.jpg",
          href = "https://twitter.com/swsoyee",
          icon = "twitter",
          title = "Wei_Su",
          subtitle = i18n$t("設立者・開発")
        ),
        UserListItemWrappter(
          image = "Icon/w2.png",
          href = "https://github.com/Bob-FU",
          icon = "github",
          title = "Bob-Fu",
          subtitle = i18n$t("インフラ")
        ),
        UserListItemWrappter(
          image = "Icon/zoie.jpg",
          href = "https://twitter.com/zoiesywong",
          icon = "twitter",
          title = "Zoie, PhD",
          subtitle = i18n$t("学術指導")
        ),
        UserListItemWrappter(
          image = "Icon/kato.jpg",
          href = "https://github.com/emc-kk",
          icon = "github",
          title = "emckk",
          subtitle = i18n$t("データ")
        )
      )
    ),
    # box(
    #   title = i18n$t("プロジェクトスポンサー"),
    #   icon = icon("hand-holding-usd"),
    #   width = 6, 
    #   label = tags$a(
    #     href = "https://github.com/sponsors/swsoyee", 
    #     suppressWarnings(boxLabel(
    #       text = tagList(
    #         icon("heart"),
    #         "Sponsor"
    #       ), 
    #       status = "danger"
    #     )
    #   )),
    #   userList(
    #     UserListItemWrappter(
    #       image = "Icon/yukinobu_nishio.jpg",
    #       href = "https://twitter.com/yukinobunishio",
    #       icon = "twitter",
    #       title = "YukinobuNISHIO",
    #       subtitle = sprintf("~ %s", as.Date("20210106", format = "%Y%m%d"))
    #     ),
    #     UserListItemWrappter(
    #       image = "Icon/uryu_shinya.jpg",
    #       href = "https://twitter.com/u_ribo",
    #       icon = "twitter",
    #       title = "Uryu Shinya",
    #       subtitle = sprintf("~ %s", as.Date("20201102", format = "%Y%m%d"))
    #     ),
    #     UserListItemWrappter(
    #       image = "Icon/marchhare31.png",
    #       href = "https://github.com/marchhare31",
    #       icon = "github",
    #       title = "marchhare31",
    #       subtitle = sprintf("~ %s", as.Date("20201103", format = "%Y%m%d"))
    #     ),
    #     UserListItemWrappter(
    #       image = "Icon/anonymous.jpeg",
    #       title = "Anonymous",
    #       subtitle = sprintf("~ %s", as.Date("20201102", format = "%Y%m%d"))
    #     )
    #   )
    # ),
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
