tabPanel(
  title = tagList(
    icon("globe-asia"),
    i18n$t("感染状況マップ")
  ),
  fluidRow(
    column(
      width = 5,
      tags$div(
        fluidRow(
          column(
            width = 6,
            switchInput(
              inputId = "switchMapVersion",
              value = T,
              onLabel = i18n$t("シンプル"),
              onStatus = "danger",
              offStatus = "danger",
              offLabel = i18n$t("詳細"),
              label = i18n$t("表示モード"),
              inline = T,
              size = "small",
              width = "300px",
              labelWidth = "200px",
              handleWidth = "100px"
            ),
          ),
          column(
            width = 6,
            uiOutput("echartsMapPlaySetting")
          ),
        ),
        style = "margin-top:10px;"
      ),
      uiOutput("comfirmedMapWrapper") %>% withSpinner(proxy.height = "550px"),
      uiOutput("selectMapBottomButton"),
      # TODO もし全部の都道府県に感染者報告がある場合、こちらのバーを再検討する
      progressBar(
        id = "activePatients",
        value = TOTAL_JAPAN - DEATH_JAPAN - 40 - sum(mhlwSummary[日付 == max(日付)]$退院者),
        total = TOTAL_JAPAN - DEATH_JAPAN - 40,
        title = tagList(
          icon("procedures"),
          i18n$t("現在患者数")
        ),
        striped = T,
        status = "danger",
        display_pct = T
      ),
      bsTooltip(
        id = "activePatients",
        placement = "top",
        title = i18n$t("分母には死亡者、チャーター便で帰国したクルーズ船の乗客40名は含まれていません。")
      ),
      tagList(icon("shield-alt"), tags$b(i18n$t("感染者なし"))),
      uiOutput("saveArea"),
    ),
    column(
      width = 7,
      boxPad(
        fluidRow(
          column(
            width = 11,
            radioGroupButtons(
              inputId = "switchTableVersion",
              label = NULL,
              justified = T,
              choiceNames = c(
                paste(icon("procedures"), i18n$t("感染")),
                paste(icon("vials"), i18n$t("検査")),
                paste(icon("hospital"), i18n$t("回復・死亡"))
              ),
              choiceValues = c("confirmed", "test", "discharged"),
              status = "danger"
            )
          ),
          column(
            width = 1,
            tags$span(
              dropdownButton(
                tags$h4(icon("eye"), i18n$t("表示設定")),
                tags$hr(),
                materialSwitch(
                  inputId = "tableShowSetting",
                  label = tagList(icon("object-group"), i18n$t("グルーピング表示")),
                  status = "danger",
                  value = T
                ),
                circle = F,
                right = T,
                inline = T,
                status = "danger",
                icon = icon("gear"),
                size = "sm",
                width = "300px",
                tooltip = tooltipOptions(title = i18n$t("表示設定"), placement = "top")
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
