fluidPage(
  fluidRow(
    widgetUserBox(
      title = lang[[langCode]][17],
      # 新型コロナウイルス
      subtitle = lang[[langCode]][18],
      # 2019 nCoV
      width = 12,
      type = NULL,
      src = 'ncov.jpeg',
      color = "purple",
      collapsible = F,
      background = T,
      backgroundUrl = 'ncov_back.jpg',
      # tags$p(dashboardLabel(status = 'danger',  # APIアクセスできなかった
      #                       style = 'square', 
      #                       paste(sep = ' | ', lang[[langCode]][71], # ページ閲覧数
      #                             statics$result$totals$pageviews$all)
      #                       ),
      #        dashboardLabel(status = 'success',
      #                       style = 'square',
      #                       paste(sep = ' | ', lang[[langCode]][72], # 閲覧者数
      #                             statics$result$totals$uniques)
      #        )
      #        ),
      tags$p(tags$img(src = 'https://img.shields.io/badge/dynamic/json?url=https://stg.covid-2019.live/ncov-static/stats.json&label=%E9%96%B2%E8%A6%A7%E6%95%B0&query=$.result.totals.pageviews.all&color=orange&style=flat-square')),
      tags$p(lang[[langCode]][19]),
      # 発熱や上気道症状を引き起こすウイルス...
      tags$a(href = lang[[langCode]][21], # https://www.mhlw.go.jp/stf/...
             paste0(lang[[langCode]][20], # 出典
                    '：', lang[[langCode]][22], # コロナウイルスはどのようなウイルスですか？
                    '（', lang[[langCode]][5], # 厚生労働省
                    '）、 ')),
      tags$a(href = lang[[langCode]][59], # https://phil.cdc.gov/Details.aspx?pid=2871
             # 背景画像
             lang[[langCode]][58]),
      footer_padding = F
    )
  ),
  fluidRow(
    # 日本領土内のPCR陽性確認数の表示ボックス
    valueBox(
      width = 4,
      value = paste0(TOTAL_JAPAN, ' (+', TOTAL_JAPAN_DIFF, ')'),
      subtitle = lang[[langCode]][60],
      icon = icon('sad-tear'),
      color = "red"
    ),
    valueBox(
      width = 4,
      value = paste0(CURED_WITHIN, ' (+', CURED_WITHIN_DIFF, ')'),
      subtitle = lang[[langCode]][6],
      icon = icon('grin-squint'),
      color = "green"
    ),
    valueBox(
      width = 4,
      value = paste0(DEATH_JAPAN, ' (+', DEATH_JAPAN_DIFF, ')'),
      subtitle = lang[[langCode]][7],
      icon = icon('dizzy'),
      color = "navy"
    )
  ),
  fluidRow(
    boxPlus(
      width = 4,
      fluidRow(
        column(
          width = 4,
          # 国内事例
          descriptionBlock(
            number = TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF,
            number_color = 'red',
            number_icon = getChangeIcon(TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF),
            header = TOTAL_DOMESITC + TOTAL_OFFICER,
            text = lang[[langCode]][4]
          )
        ),
        column(
          width = 4,
          # チャーター便
          descriptionBlock(
            number = TOTAL_FLIGHT_DIFF,
            number_color = 'red',
            number_icon = getChangeIcon(TOTAL_FLIGHT_DIFF),
            header = TOTAL_FLIGHT,
            text = lang[[langCode]][36]
          )
        ),
        column(
          width = 4,
          # クルーズ船
          descriptionBlock(
            number = TOTAL_SHIP_DIFF,
            number_color = 'red',
            number_icon = getChangeIcon(TOTAL_SHIP_DIFF),
            header = TOTAL_SHIP,
            text = lang[[langCode]][35],
            right_border = F
          )
        )
      ),
      footer = tagList(fluidRow(
        column(
          width = 6,
          plotlyOutput('confirmedPie', height = '150px') %>% withSpinner()
        ),
        column(width = 6,
               tags$h4(paste0(UPDATE_DATE, lang[[langCode]][64])),
               uiOutput('todayConfirmed'))
      ),
      tags$small(paste(
        lang[[langCode]][62], UPDATE_DATETIME
      )))
    ),
    boxPlus(
      width = 4,
      fluidRow(
        column(
          width = 6,
          # 国内事例
          descriptionBlock(
            number = CURED_DOMESTIC_DIFF,
            number_color = 'green',
            number_icon = getChangeIcon(CURED_DOMESTIC_DIFF),
            header = CURED_DOMESTIC,
            text = lang[[langCode]][4]
          )
        ),
        column(
          width = 6,
          # チャーター便
          descriptionBlock(
            number = CURED_FLIGHT_DIFF,
            number_color = 'green',
            number_icon = getChangeIcon(CURED_FLIGHT_DIFF),
            header = CURED_FLIGHT,
            text = lang[[langCode]][36],
            right_border = F
          )
        )
      ),
      footer = tagList(fluidRow(
        column(
          width = 6,
          plotlyOutput('curedPie', height = '150px') %>% withSpinner()
        ),
        column(width = 6,
               tags$h4('準備中'))
      ),
      tags$small(
        paste(lang[[langCode]][62], RECOVERED_FILE_UPDATE_DATETIME)
      ))
    ),
    boxPlus(
      width = 4,
      fluidRow(
        column(
          width = 6,
          # 国内事例
          descriptionBlock(
            number = DEATH_DOMESITC_DIFF + DEATH_OFFICER_DIFF,
            number_color = 'black',
            number_icon = getChangeIcon(DEATH_DOMESITC_DIFF + DEATH_OFFICER_DIFF),
            header = DEATH_DOMESITC + DEATH_OFFICER,
            text = lang[[langCode]][4]
          )
        ),
        column(
          width = 6,
          # クルーズ船
          descriptionBlock(
            number = DEATH_SHIP_DIFF,
            number_color = 'black',
            number_icon = getChangeIcon(DEATH_SHIP_DIFF),
            header = DEATH_SHIP,
            text = lang[[langCode]][35],
            right_border = F
          )
        )
      ),
      footer = tagList(fluidRow(
        column(
          width = 6,
          plotlyOutput('deathPie', height = '150px') %>% withSpinner()
        ),
        column(width = 6,
               tags$h4(paste0(DEATH_UPDATE_DATE, lang[[langCode]][64])),
               uiOutput('todayDeath')
               )
      ),
      tags$small(
        paste(lang[[langCode]][62], DEATH_FILE_UPDATE_DATETIME)
      ))
    )
  ),
  fluidRow(
    boxPlus(
      width = 4,
      title = tagList(icon('map'), lang[[langCode]][2]),
      plotOutput('map', height = '370px') %>% withSpinner(),
      actionBttn(inputId = 'switchCaseMap', label = '事例マップへ',
                 block = T, size ='sm'),
      closable = F,
      footer = tags$small(paste(
        lang[[langCode]][62], UPDATE_DATETIME
      ))
    ),
    box(
      width = 4,
      checkboxGroupButtons(
        inputId = "showOtherRegion",
        label = lang[[langCode]][54],
        choices = showOption,
        justified = TRUE,
        status = "primary",
        checkIcon = list(
          yes = icon("ok", lib = "glyphicon"),
          no = icon("remove", lib = "glyphicon")
        )
      ),
      dataTableOutput('confirmedByProvince') %>% withSpinner(),
    ),
    box(width = 4, dataTableOutput('news') %>% withSpinner())
  ),
  fluidRow(
    tabBox(
      width = 6,
      # 感染者数の推移
      title = tagList(icon('chart-line'), lang[[langCode]][3]),
      # 国内事例
      tabPanel(title = lang[[langCode]][4], icon = icon('home'),
               plotlyOutput('domesticLine') %>% withSpinner()),
      # クルーズ船
      tabPanel(title = lang[[langCode]][35], icon = icon('ship'),
               plotlyOutput('shipLine') %>% withSpinner())
    ),
    box(
      title = lang[[langCode]][53],
      width = 6,
      plotlyOutput('recoveredAccumulation') %>% withSpinner()
    )
  ),
  fluidRow(
    boxPlus(title = '感染経路ネットワーク',
            width = 12,
            closable = F,
            # collapsed = T,
            echarts4rOutput('network'),
            footer = '※開発バージョンです。最終版ではありません')
    )
)
