tabPanel(
  title = tagList(
    icon("globe-asia"),
    # 感染状況マップ
    lang[[langCode]][109]
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
            onLabel = "シンプル",
            offLabel = "詳細",
            label = "表示モード", inline = T,
            size = "small", width = "300px", labelWidth = "200px", handleWidth = "100px"
          ),
          dropdownButton(
            # 表示設定
            tags$h4(lang[[langCode]][110]),
            materialSwitch(
              inputId = "showPopupOnMap",
              # 日次増加数のポップアップ
              label = lang[[langCode]][111],
              status = "danger",
              value = T
            ),
            materialSwitch(
              inputId = "replyMapLoop",
              # ループ再生
              label = lang[[langCode]][112],
              status = "danger",
              value = T
            ),
            dateRangeInput(
              inputId = "mapDateRange",
              # 表示日付
              label = lang[[langCode]][113],
              start = byDate$date[nrow(byDate) - 15],
              end = byDate$date[nrow(byDate)],
              min = byDate$date[1],
              max = byDate$date[nrow(byDate)],
              separator = " ~ ",
              language = "ja"
            ),
            sliderInput(
              inputId = "mapFrameSpeed",
              # 再生速度（秒/日）
              label = lang[[langCode]][114],
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
            # 表示設定
            tooltip = tooltipOptions(title = lang[[langCode]][110])
          ),
          style = "margin-top:10px;"
        )
        # column(
        #   width = 6,
        #   # actionButton(inputId = 'switchCaseMap', label = '事例マップへ')
        # )
      )),
      uiOutput("comfirmedMapWrapper") %>% withSpinner(proxy.height = "500px"),
      # TODO もし全部の都道府県に感染者報告がある場合、こちらのバーを再検討する
      progressBar(
        id = "hasConfirmedRegionBar",
        value = 47 - length(regionZero),
        total = 47,
        # 感染者報告あり
        title = tagList(
          icon("exclamation-triangle"),
          lang[[langCode]][115]
        ),
        striped = T,
        status = "danger",
        display_pct = T
      ),
      tagList(icon("shield-alt"), tags$b(lang[[langCode]][97])),
      uiOutput("saveArea"),
    ),
    column(
      width = 7,
      boxPad(
        switchInput(
          inputId = "switchTableVersion",
          value = F,
          onLabel = "シンプル",
          offLabel = "詳細",
          label = "表示モード",
          size = "small", width = "300px", labelWidth = "200px", handleWidth = "100px"
        ),
        # dataTableOutput('summaryByRegion') %>% withSpinner() # 重いのでデフォルトはシンプルバージョンに変更
        uiOutput("summaryTable") %>% withSpinner()
      )
    ),
  )
)