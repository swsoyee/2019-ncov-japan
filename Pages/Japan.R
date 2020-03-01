fluidPage(
  # fluidRow(
  #   box(width = 12,
  #       solidHeader = T,
  #       status = 'info',
  #       title = tagList(icon('info'), '通知'),
  #       collapsible = T,
  #       collapsed = T, 
  #       tags$small(
  #         paste0(
  #           '機能開発もデータの収集も全部ひとりで担当をしているので、',
  #           '患者さんの行動歴や厚生労働省が発表しているデータの整理を協力できる有志がございましたら是非Pull Requestを：'
  #         ),
  #         tags$a(href = 'https://github.com/swsoyee/2019-ncov-japan', 'Github'),
  #         '。一人でメンテナンスすることはやはり限度があります。データの更新だけで精一杯であり、機能開発はなかなか着手できませんでした。'
  #       ))
  # ),
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
      # 発熱や上気道症状を引き起こすウイルス...
      tags$p(lang[[langCode]][19]),
      tags$a(href = lang[[langCode]][21], # https://www.mhlw.go.jp/stf/...
             paste0(lang[[langCode]][20], # 出典
                    '：', lang[[langCode]][22], # コロナウイルスはどのようなウイルスですか？
                    '（', lang[[langCode]][5], # 厚生労働省
                    '）、 ')),
      tags$a(href = lang[[langCode]][59], # https://phil.cdc.gov/Details.aspx?pid=2871
             # 背景画像
             lang[[langCode]][58]),
      tags$br(),
      actionButton(inputId = 'twitterShare',
                   label = 'Twiiter',
                   icon = icon('twitter'),
                   onclick = sprintf("window.open('%s')", twitterUrl)
      ),
      actionButton(inputId = 'github',
                   label = 'Github',
                   icon = icon('github'),
                   onclick = sprintf("window.open('%s')", 'https://github.com/swsoyee/2019-ncov-japan')
                   ),
      footer_padding = F
    )
  ),
  # バリューボックス
  fluidRow(
    valueBox(
      width = 3,
      value = 4061 + 2209,
      subtitle = lang[[langCode]][90],
      icon = icon('vials'),
      color = "yellow"
    ),
    valueBox(
      width = 3,
      value = paste0(TOTAL_JAPAN, ' (+', TOTAL_JAPAN_DIFF, ')'),
      subtitle = lang[[langCode]][60],
      icon = icon('procedures'),
      color = "red"
    ),
    valueBox(
      width = 3,
      value = paste0(CURED_WITHIN, ' (+', CURED_WITHIN_DIFF, ')'),
      subtitle = lang[[langCode]][6],
      icon = icon('heart'),
      color = "green"
    ),
    valueBox(
      width = 3,
      value = paste0(DEATH_JAPAN, ' (+', DEATH_JAPAN_DIFF, ')'),
      subtitle = lang[[langCode]][7],
      icon = icon('cross'),
      color = "navy"
    )
  ),
  fluidRow(
    boxPlus(
      # 国内状況推移
      title = tagList(icon('chart-line'), lang[[langCode]][88]),
      closable = F,
      collapsible = T,
      width = 12,
      fluidRow(
        column(
          width = 8,
          tabsetPanel(
            id = 'linePlot',
            tabPanel(
              # 感染者数の推移
              title = lang[[langCode]][3], 
              value = 'confirmed',
              fluidRow(column(11.9, offset = 0.1,
                tags$br(),
                pickerInput(
                  inputId = 'regionPicker', 
                  label = '地域選択', 
                  choices = regionName, 
                  selected = c('国内', lang[[langCode]][36], '検疫職員'),
                  options = list(
                    `actions-box` = TRUE, 
                    size = 10,
                    `selected-text-format` = "count > 3"
                  ), 
                  multiple = T, width = '70%', inline = T
                )
              )),
              uiOutput('confirmedLineWrapper') %>% withSpinner()
              ),
            tabPanel(
              # 退院者推移
              title = lang[[langCode]][89],
              value = 'cured',
              fluidRow(
                column(width = 12,
                  tags$br(),
                  tags$p('開発バージョンです。最終版ではありません')
                )
              ),
              echarts4rOutput('recoveredLine') %>% withSpinner(),
            )
          )
        ),
        column(
          width = 4,
          tags$b('感染者'),
          echarts4rOutput('confirmedBar', height = '20px') %>% withSpinner(),
          uiOutput('todayConfirmed'),
          tags$br(),
          tags$b('退院者'),
          echarts4rOutput('curedBar', height = '20px') %>% withSpinner(),
          uiOutput('todayCured'),
          tags$br(),
          tags$b('死亡者'),
          echarts4rOutput('deathBar', height = '20px') %>% withSpinner(),
          uiOutput('todayDeath'),
          tags$hr(),
          tags$b('新規（日次）ヒートマップ'),
          uiOutput('renderCalendar')
        )
      ),
      tags$hr(),
      fluidRow(
        column(
          width = 2,
          # 国内事例
          descriptionBlock(
            number = TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF + TOTAL_FLIGHT_DIFF,
            number_color = 'red',
            number_icon = getChangeIcon(TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF + TOTAL_FLIGHT_DIFF),
            header = TOTAL_DOMESITC + TOTAL_OFFICER + TOTAL_FLIGHT,
            text = lang[[langCode]][4]
          )
        ),
        column(
          width = 2,
          # クルーズ船
          descriptionBlock(
            number = TOTAL_SHIP_DIFF,
            number_color = 'red',
            number_icon = getChangeIcon(TOTAL_SHIP_DIFF),
            header = TOTAL_SHIP,
            text = lang[[langCode]][35],
          )
        ),
        column(
          width = 2,
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
          width = 2,
          # チャーター便
          descriptionBlock(
            number = CURED_FLIGHT_DIFF,
            number_color = 'green',
            number_icon = getChangeIcon(CURED_FLIGHT_DIFF),
            header = CURED_FLIGHT,
            text = lang[[langCode]][36],
          )
        ),
        column(
          width = 2,
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
          width = 2,
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
    )
  )),
  fluidRow(
    boxPlus(
      width = 4,
      title = tagList(icon('map'), lang[[langCode]][2]),
      plotOutput('map', height = '370px') %>% withSpinner(),
      actionBttn(inputId = 'switchCaseMap', label = '事例マップへ',
                 block = T, size ='xs', style = 'fill'),
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
      echarts4rOutput('totalConfirmedByRegionPlot')  %>% withSpinner()
    ),
    box(width = 4, dataTableOutput('news') %>% withSpinner())
  ),
  fluidRow(
    boxPlus(title = tagList(icon('connectdevelop'), '感染経路ネットワーク'),
            width = 8,
            closable = F,
            # collapsed = T,
            echarts4rOutput('network'),
            enable_sidebar = T,
            sidebar_start_open = F,
            sidebar_content = tagList(
              checkboxInput('hideSingle', '離散を非表示', T)
            ),
            footer = tags$small('※開発バージョンです。最終版ではありません')),
    boxPlus(title = tagList(icon('venus-mars'), '歳代・性別'),
            width = 4,
            echarts4rOutput('genderBar'),
            closable = F,
            footer = tags$small('厚生労働省の報道発表のデータに基づいてプロットしたグラフです。多少数値の遅れがあります。')
            )
    )
)
