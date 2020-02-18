fluidPage(
  fluidRow(
    widgetUserBox(
      title = lang[[langCode]][17],
      # 新型コロナウイルス
      subtitle = lang[[langCode]][18],
      # 2019 nCoV
      width = 12,
      type = 2,
      src = 'https://raw.githubusercontent.com/swsoyee/2019-ncov-japan/master/www/ncov.jpeg',
      color = "purple",
      lang[[langCode]][19],
      # 発熱や上気道症状を引き起こすウイルス...
      footer = tags$a(href = lang[[langCode]][21], # https://www.mhlw.go.jp/stf/...
                      paste0(lang[[langCode]][20], # 出典
                             ':', lang[[langCode]][22], # コロナウイルスはどのようなウイルスですか？
                             '（', lang[[langCode]][5], # 厚生労働省
                             '）'))
    )
  ),
  fluidRow(
    valueBoxOutput(width = 2, "totalConfirmed"),
    valueBoxOutput(width = 2, "flightConfirmed"),
    valueBoxOutput(width = 2, "shipConfirmed"),
    # valueBoxOutput(width = 3, "totalSuspicious"),
    valueBoxOutput(width = 3, "totalRecovered"),
    valueBoxOutput(width = 3, "totalDeath")
  ),
  fluidRow(uiOutput('compareWithYesterday')),
  fluidRow(
    box(
      width = 8,
      title = paste(lang[[langCode]][2], '(', UPDATE_DATETIME, ')'),
      uiOutput('mapWrapper') %>% withSpinner(),
      footer = lang[[langCode]][12],
      #   tags$button(
      #     id = "normalMapButton",
      #     type = "button",
      #     class = "btn action-button btn-primary",
      #     HTML('<i class="icon-star"></i>', lang[[langCode]][15])
      #   ),
      # tags$button(
      #   id = "blockMapButton",
      #   type = "button",
      #   class = "btn action-button btn-primary",
      #   HTML('<i class="icon-star"></i>', lang[[langCode]][16])
      # ),
      # tags$a(href = 'https://www.mhlw.go.jp/index.html',
      #        paste(lang[[langCode]][5]), # 厚生労働省
      #        '(',
      #        UPDATE_TIME,
      #        ')')
      # )
    ),
    box(
      width = 4,
      dataTableOutput('totalConfirmedByProvince') %>% withSpinner()
    )
  ),
  fluidRow(column(
    width = 8,
    box(
      width = 12,
      title = lang[[langCode]][3],
      # 確認累積数
      plotlyOutput("confirmedAccumulation") %>% withSpinner(),
      # 無症状病原体保有者を含む
      footer = paste('（＊）', lang[[langCode]][12])
    ),
    box(
      title = lang[[langCode]][53],
      width = 12,
      plotlyOutput('recoveredAccumulation') %>% withSpinner()
    )
  ),
  column(
    width = 4,
    box(width = 12,
        dataTableOutput('news') %>% withSpinner()),
  )),
  fluidRow(
    box(
      title = lang[[langCode]][52],
      # 確認詳細
      width = 12,
      fluidRow(column(
        width = 3,
        plotlyOutput("detailSummaryByGenderAndAge", height = '200px') %>% withSpinner()
      )),
      tags$hr(),
      fluidRow(column(
        width = 12,
        dataTableOutput('detail') %>% withSpinner()
      )),
      tags$li(
        '  旧No.39の患者の「周囲の患者の発生」セル内容につきまして、記述によるとNo.38の妻であるではないかと思うので、「No.29」から「No.38」に修正しました。'
      ),
      tags$li(
        '  旧No.44の患者の「周囲の患者の発生」セル内容につきまして、正しい数値は「No.43」と思うので、修正しました。'
      ),
      footer = tags$a(href = 'https://www.mhlw.go.jp/stf/newpage_09571.html',
                      '新型コロナウイルス感染症の現在の状況と厚生労働省の対応について（令和２年２月17日版）より')
    )
  )
)
