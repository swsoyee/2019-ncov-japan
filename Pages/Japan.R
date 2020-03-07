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
      value = sum(PCR_WITHIN$final, PCR_FLIGHT$final, PCR_SHIP$final), # 開発待ち
      subtitle = paste0(lang[[langCode]][90], ' (+', sum(PCR_WITHIN$diff, PCR_FLIGHT$diff, PCR_SHIP$diff), ')'),
      icon = icon('vials'),
      color = "yellow"
    ),
    valueBox(
      width = 3,
      value = TOTAL_JAPAN,
      subtitle = paste0(lang[[langCode]][60], ' (+', TOTAL_JAPAN_DIFF, ')'),
      icon = icon('procedures'),
      color = "red"
    ),
    valueBox(
      width = 3,
      value = DISCHARGE_TOTAL, 
      subtitle = paste0(lang[[langCode]][6],
                        ' (+', 
                        SYMPTOM_DISCHARGE_FLIGHT$diff + 
                          SYMPTOM_DISCHARGE_WITHIN$diff + 
                          SYMPTOMLESS_DISCHARGE_FLIGHT$diff + 
                          SYMPTOMLESS_DISCHARGE_WITHIN$diff +
                          DISCHARGE_SHIP$diff, ')'),
      icon = icon('thumbs-up'),
      color = "green"
    ),
    valueBox(
      width = 3,
      value = DEATH_JAPAN, 
      subtitle = paste0(lang[[langCode]][7], ' (+', DEATH_JAPAN_DIFF, ')'),
      icon = icon('bible'),
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
              title = lang[[langCode]][3], icon = icon('procedures'),
              value = 'confirmed',
              fluidRow(column(11.9, offset = 0.1,
                tags$br(),
                pickerInput(
                  inputId = 'regionPicker', 
                  label = lang[[langCode]][93], # 地域選択
                  choices = regionName, 
                  selected = defaultSelectedRegionName,
                  options = list(
                    `actions-box` = TRUE, 
                    size = 10,
                    `deselect-all-text` = lang[[langCode]][91], # クリア
                    `select-all-text` = lang[[langCode]][92], # 全部
                    `selected-text-format` = lang[[langCode]][94] # 三件以上選択されました
                  ), 
                  multiple = T, width = '70%', inline = T
                )
              )),
              uiOutput('confirmedLineWrapper') %>% withSpinner()
              ),
            tabPanel(
              # PCR検査数推移
              title = 'PCR検査数推移', icon = icon('vials'),
              value = 'pcr',
              fluidRow(
                column(width = 12,
                       tags$br(),
                       tags$p('開発バージョンです。最終版ではありません')
                )
              ),
              echarts4rOutput('pcrLine') %>% withSpinner()
            ),
            tabPanel(
              # 退院者推移
              title = lang[[langCode]][89], icon = icon('thumbs-up'),
              value = 'discharged',
              fluidRow(
                column(width = 12,
                  tags$br(),
                  tags$p('開発バージョンです。最終版ではありません')
                )
              ),
              echarts4rOutput('recoveredLine') %>% withSpinner()
            )
          )
        ),
        column(
          width = 4,
          tags$b(paste0('感染者なしの地域：', length(regionZero), ' (', round(length(regionZero)/47 * 100, 2), '%)')),
          uiOutput('saveArea'),
          tags$br(),
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
            number = SYMPTOM_DISCHARGE_WITHIN$diff + 
              SYMPTOMLESS_DISCHARGE_WITHIN$diff + 
              SYMPTOM_DISCHARGE_FLIGHT$diff + 
              SYMPTOMLESS_DISCHARGE_FLIGHT$diff,
            number_color = 'green',
            number_icon = getChangeIcon(SYMPTOM_DISCHARGE_WITHIN$diff + 
                                          SYMPTOMLESS_DISCHARGE_WITHIN$diff + 
                                          SYMPTOM_DISCHARGE_FLIGHT$diff + 
                                          SYMPTOMLESS_DISCHARGE_FLIGHT$diff),
            header = SYMPTOM_DISCHARGE_WITHIN$final + 
              SYMPTOMLESS_DISCHARGE_WITHIN$final +
              SYMPTOM_DISCHARGE_FLIGHT$final + 
              SYMPTOMLESS_DISCHARGE_FLIGHT$final,
            text = lang[[langCode]][4]
          )
        ),
        column(
          width = 2,
          # クルーズ船
          descriptionBlock(
            number = DISCHARGE_SHIP$diff,
            number_color = 'green',
            number_icon = getChangeIcon(DISCHARGE_SHIP$diff),
            header = DISCHARGE_SHIP$final,
            text = lang[[langCode]][35],
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
      title = tagList(icon('map'), lang[[langCode]][2]),
      closable = F,
      collapsible = T,
      width = 8,
      tabsetPanel(
        tabPanel(
          title = 'マップ',
          fluidRow(
            column(
              width = 6,
              # plotOutput('map', height = '370px') %>% withSpinner(),
              echarts4rOutput('echartsMap')  %>% withSpinner(),
              actionButton(inputId = 'switchCaseMap', label = '事例マップへ'),
            ),
            column(
              width = 6,
              boxPad(
                echarts4rOutput('totalConfirmedByRegionPlot')  %>% withSpinner()
              )
            ),
          )
        ),
        tabPanel(
          title = '時系列棒グラフ',
          echarts4rOutput('regionTimeSeries') %>% withSpinner()
        )
      ),
      footer = tags$small(paste(
        lang[[langCode]][62], UPDATE_DATETIME, '開発＆調整中'
      ))
    ),
    boxPlus(title = tagList(icon('venus-mars'), '歳代・性別'),
            width = 4,
            echarts4rOutput('genderBar'),
            closable = F,
            footer = tags$small('厚生労働省の報道発表のデータに基づいてプロットしたグラフです。多少数値の遅れがあります。')
    )
  ),
  fluidRow(
    boxPlus(title = tagList(icon('connectdevelop'), '感染経路ネットワーク'),
            width = 8,
            closable = F,
            # collapsed = T,
            echarts4rOutput('network') %>% withSpinner(),
            enable_sidebar = T,
            sidebar_start_open = F,
            sidebar_content = tagList(
              checkboxInput('hideSingle', '離散を非表示', T)
            ),
            footer = tags$small('※開発バージョンです。最終版ではありません')),
    boxPlus(width = 4, dataTableOutput('news') %>% withSpinner())
  ),
  fluidRow(
    boxPlus(title = '病気進行',
            width = 8,
            closable = F,
            # collapsed = T,
            echarts4rOutput('processSankey') %>% withSpinner(),
            footer = tags$small('※開発バージョンです。最終版ではありません')
            )
  )
)
