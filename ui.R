source(file = "global.R",
       local = TRUE,
       encoding = "UTF-8")

shinyUI(dashboardPagePlus(
  skin = "purple",
  header = dashboardHeaderPlus(title = lang[[langCode]][1], 
                               titleWidth = 350,
                               enable_rightsidebar = F), # TODO 言語設定の追加
  sidebar = dashboardSidebar(disable = F),
  # TODO 追加修正待ち
  # rightsidebar = rightSidebar(
  #   background = "dark",
  #   selectInput(inputId = 'language',
  #               label = lang[[langCode]][24], # 言語
  #               choices = languageSet)
  # ),
  dashboardBody(fluidPage(
    fluidRow(
      widgetUserBox(
        title = lang[[langCode]][17], # 新型コロナウイルス
        subtitle = lang[[langCode]][18], # 2019 nCoV
        width = 12,
        type = 2,
        color = "purple",
        lang[[langCode]][19], # 発熱や上気道症状を引き起こすウイルス...
        footer = tags$a(href = lang[[langCode]][21], # https://www.mhlw.go.jp/stf/...
                        paste0(lang[[langCode]][20], # 出典
                               ':', lang[[langCode]][22], # コロナウイルスはどのようなウイルスですか？
                               '（', lang[[langCode]][5], # 厚生労働省
                               '）'))
      )
    ),
    fluidRow(
      valueBoxOutput(width = 3, "totalConfirmed"),
      valueBoxOutput(width = 3, "totalSuspicious"),
      valueBoxOutput(width = 3, "totalRecovered"),
      valueBoxOutput(width = 3, "totalDeath")
    ),
    fluidRow(
      uiOutput('compareWithYesterday')
    ),
    fluidRow(
      box(
        width = 8,
        title = lang[[langCode]][2],
        uiOutput('mapWrapper') %>% withSpinner(),
        footer = tagList(
          tags$button(
            id = "normalMapButton",
            type = "button",
            class = "btn action-button btn-primary",
            HTML('<i class="icon-star"></i>', lang[[langCode]][15])
          ),
          tags$button(
            id = "blockMapButton",
            type = "button",
            class = "btn action-button btn-primary",
            HTML('<i class="icon-star"></i>', lang[[langCode]][16])
          ) #,
          # tags$a(href = 'https://www.mhlw.go.jp/index.html',
          #        paste(lang[[langCode]][5]), # 厚生労働省
          #        '(',
          #        UPDATE_TIME,
          #        ')')
        )
      ),
      box(
        width = 4,
        dataTableOutput('totalConfirmedByProvince') %>% withSpinner()
      ),
      box(
        width = 8,
        title = lang[[langCode]][3],
        # 確認累積数
        plotlyOutput("confirmedAccumulation") %>% withSpinner(),
        # 無症状病原体保有者を含む
        footer = paste('（＊）', lang[[langCode]][12])
      ),
      box(width = 4,
          dataTableOutput('news') %>% withSpinner())
    ),
  ))
))
