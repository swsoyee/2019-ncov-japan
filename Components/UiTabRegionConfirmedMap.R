tabPanel(
  title = tagList(
    icon('globe-asia'), 
    '感染状況マップ'
  ),
  fluidRow(
    column(
      width = 5,
      fluidRow(
        column(
          width = 6,
          tags$br(),
          dropdownButton(
            tags$h4('表示設定'),
            materialSwitch(
              inputId = 'showPopupOnMap', 
              label = '日次増加数のポップアップ', 
              status = "danger", 
              value = T
            ),
            materialSwitch(
              inputId = 'replyMapLoop', 
              label = 'ループ再生', 
              status = "danger", 
              value = T
            ),
            dateRangeInput(
              inputId = 'mapDateRange',
              label = '表示日付',
              start = byDate$date[nrow(byDate) - 15], 
              end = byDate$date[nrow(byDate)],
              min = byDate$date[1],
              max = byDate$date[nrow(byDate)],
              separator = " ~ ", 
              language = 'ja'
            ),
            sliderInput(
              inputId = 'mapFrameSpeed',
              label = '再生速度（秒/日）', 
              min = 0.5,
              max = 3, 
              step = 0.1, 
              value = 0.8
            ),
            circle = F, 
            status = "danger", 
            icon = icon("gear"), 
            size = 'sm',
            width = "300px",
            tooltip = tooltipOptions(title = '表示設定')
          ),
          # column(
          #   width = 6,
          #   actionButton(inputId = 'switchCaseMap', label = '事例マップへ')
          # )
        ),
      ),
      echarts4rOutput('echartsMap', height = '500px')  %>% withSpinner(),
      progressBar(
        id = 'hasConfirmedRegionBar', 
        value = 47 - length(regionZero), 
        total = 47, 
        title = tagList(icon('exclamation-triangle'), '感染者報告あり'),
        striped = T,
        status = 'danger',
        display_pct = T
        ),
      tagList(icon('shield-alt'), tags$b(lang[[langCode]][97])),
      uiOutput('saveArea'),
    ),
    column(
      width = 7,
      boxPad(
        # echarts4rOutput('totalConfirmedByRegionPlot', height = '600px')  %>% withSpinner()
        dataTableOutput('summaryByRegion') %>% withSpinner()
      )
    ),
  )
)
