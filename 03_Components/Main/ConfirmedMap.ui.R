tabPanel(
  title = tagList(
    icon("globe-asia"),
    i18n$t("感染状況マップ")
  ),
  fluidRow(
    column(
      width = 5,
      fluidRow(column(
        width = 6,
        tags$div(
          switchInput(
            inputId = "switchMapVersion",
            value = T,
            onLabel = i18n$t("シンプル"),
            offLabel = i18n$t("詳細"),
            label = i18n$t("表示モード"),
            inline = T,
            size = "small",
            width = "300px",
            labelWidth = "200px",
            handleWidth = "100px"
          ),
          dropdownButton(
            tags$h4(i18n$t("表示設定")),
            materialSwitch(
              inputId = "showPopupOnMap",
              label = i18n$t("日次増加数のポップアップ"),
              status = "danger",
              value = T
            ),
            materialSwitch(
              inputId = "replyMapLoop",
              label = i18n$t("ループ再生"),
              status = "danger",
              value = T
            ),
            dateRangeInput(
              inputId = "mapDateRange",
              label = i18n$t("表示日付"),
              start = byDate$date[nrow(byDate) - 15],
              end = byDate$date[nrow(byDate)],
              min = byDate$date[1],
              max = byDate$date[nrow(byDate)],
              separator = " ~ ",
              language = "ja"
            ),
            sliderInput(
              inputId = "mapFrameSpeed",
              label = i18n$t("再生速度（秒/日）"),
              min = 0.5,
              max = 3,
              step = 0.1,
              value = 0.8
            ),
            circle = F,
            inline = T,
            status = "danger",
            icon = icon("gear"),
            size = "sm",
            width = "300px",
            tooltip = tooltipOptions(title = i18n$t("表示設定"))
          ),
          style = "margin-top:10px;"
        )
      )),
      uiOutput("comfirmedMapWrapper") %>% withSpinner(proxy.height = "500px"),
      # TODO もし全部の都道府県に感染者報告がある場合、こちらのバーを再検討する
      progressBar(
        id = "hasConfirmedRegionBar",
        value = 47 - length(regionZero),
        total = 47,
        title = tagList(
          icon("exclamation-triangle"),
          i18n$t("感染者報告あり")
        ),
        striped = T,
        status = "danger",
        display_pct = T
      ),
      tagList(icon("shield-alt"), tags$b(i18n$t("感染者報告なし"))),
      uiOutput("saveArea"),
    ),
    column(
      width = 7,
      boxPad(
        fluidRow(
          column(
            width = 8,
            radioGroupButtons(
              inputId = "switchTableVersion",
              label = "", justified = T,
              choiceNames = c(
                paste(icon("procedures"), i18n$t("感染")),
                paste(icon("vials"), i18n$t("検査")),
                paste(icon("hospital"), i18n$t("退院死亡"))
              ),
              choiceValues = c("confirmed", "test", "discharged"),
              status = "danger"
            )
          ),
          column(
            width = 4,
            tags$div(
              awesomeCheckbox(
                inputId = "tableShowSetting",
                label = i18n$t("グルーピング表示"),
                status = "danger",
                value = T
              ),
              style = "float:right;"
            )
          )
        ),
        uiOutput("summaryTable") %>% withSpinner()
      )
    )
  )
)
