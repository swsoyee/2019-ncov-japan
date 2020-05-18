fluidPage(
  fluidRow(
    boxPlus(
      width = 12,
      closable = T,
      enable_label = T,
      label_text = "New",
      label_status = "warning",
      solidHeader = T,
      status = "warning",
      title = tagList(icon("bullhorn"), i18n$t("お知らせ")),
      collapsible = T,
      collapsed = T,
      tags$small(
        paste0(
          "SIGNATE様のデータ構造が変更するため、新仕様の対応するまで少し時間がかかり、",
          "データ更新はしばらく中止致します。対応が完了次第アップデータ致します。"
        )
      )
    )
  ),
  fluidRow(
    boxPlus(
      width = 12,
      closable = F,
      enable_label = T,
      collapsible = T,
      label_status = "warning",
      label_text = "Beta 0.2",
      title = tagList(icon("connectdevelop"), i18n$t("クラスターネットワーク")),
      footer = tags$small(
        icon("database"),
        i18n$t("データ提供："),
        tags$a(href = "https://signate.jp/competitions/260/discussions", "SIGNATE - COVID-19 Chanllenge")
      ),
      fluidRow(
        column(
          width = 8,
          fluidRow(
            column(
              width = 6,
              pickerInput(
                inputId = "clusterRegionPicker",
                label = "",
                choices = provinceSelector,
                selected = 1,
                options = list(
                  `actions-box` = TRUE,
                  size = 10,
                  `deselect-all-text` = i18n$t("クリア"),
                  `select-all-text` = i18n$t("全部"),
                  `selected-text-format` = i18n$t("三件以上選択されました"),
                  `max-options` = 5
                ),
                multiple = T,
                inline = T
              )
            ),
            column(
              width = 4,
              uiOutput("clusterDateRangeSelector")
            )
          ),
          fluidRow(
            column(
              width = 12,
              uiOutput("clusterNetworkWrapper") %>% withSpinner(),
              tags$hr(),
              tags$li(i18n$t("番号の枠：選択された公表日範囲内の事例。")),
              tags$li(i18n$t("†マーク：死亡者。")),
              tags$br(),
              accordion(
                accordionItem(
                  id = 1,
                  title = i18n$t("1. クラスターネットワークについて"),
                  tags$small(
                    tags$li(
                      paste0(
                        "当クラスターネットワークは、株式会社SIGNATEが提供したデータセットおよびリンク情報",
                        "（SIGNATE COVID-19 Dataset）をそのまま可視化したものです。",
                        "感染者数が急速に拡大していて、公表されている情報も限られているため、",
                        "クラスターネットワークの正確性の保障は一切ないので、予めご了承ください。",
                        "あくまで参考用です。"
                      )
                    ),
                    tags$li(
                      "データセット自身の問題で、ある患者は、多数の患者とリンクがあるとしても、クラスターの中心とはいえませんのでご了承ください。"
                    ),
                  )
                ),
                accordionItem(
                  id = 2,
                  title = i18n$t("2. データセットについて"),
                  tags$small(
                    paste0(
                      "本分析に用いたデータセット（SIGNATE COVID-19 Dataset）は、現在、収集途中のものであり、データの正確性を保証するものではありません。",
                      "また、本データセットは基本的に厚労省・自治体等の報道における症例データに基づいて作成されており、",
                      "各種機関が発表している統計データと一致しないことがあります。予めご了承ください。"
                    )
                  )
                ),
                accordionItem(
                  id = 3,
                  title = i18n$t("3. 更新について"),
                  tags$small(
                    "更新頻度は二三日一回となります。データセットに貢献したい有志はぜひ下記のリンク先でデータの追加や訂正をしてください。",
                    tags$a(
                      href = "https://signate.jp/competitions/260/discussions",
                      icon("external-link-alt"),
                      "SIGNATE - COVID-19 Chanllenge"
                    )
                  )
                )
              )
              # )
            )
          )
        ),
        column(
          width = 4,
          uiOutput("clusterProfileSearchBox"),
          uiOutput("profile")
        )
      )
    )
  ),
  fluidRow(
    boxPlus(
      width = 8,
      title = tagList(icon("project-diagram"), i18n$t("感染経路")),
      enable_label = T,
      collapsible = T,
      closable = F,
      fluidRow(column(
        width = 12,
        uiOutput("infectedRouteRegionSelector")
      )),
      echarts4rOutput("infectedRouteByRegion") %>% withSpinner()
    )
  )
)
