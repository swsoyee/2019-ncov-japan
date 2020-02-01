source(file = "global.R",
       local = TRUE,
       encoding = "UTF-8")

shinyUI(dashboardPage(
  skin = "purple",
  dashboardHeader(title = lang[[langCode]][1], titleWidth = 450),
  # 2019-nCov 日本
  dashboardSidebar(disable = T),
  dashboardBody(fluidPage(
    fluidRow(
      valueBoxOutput(width = 3, "totalConfirmed"),
      valueBoxOutput(width = 3, "totalSuspicious"),
      valueBoxOutput(width = 3, "totalRecovered"),
      valueBoxOutput(width = 3, "totalDeath")
    ),
    fluidRow(
      box(
        width = 8,
        title = lang[[langCode]][2],
        uiOutput('mapWrapper'),
        footer = tagList(
          tags$button(
            id = "normalMapButton",
            type = "button",
            class = "btn action-button btn-primary",
            HTML('<i class="icon-star"></i>標準')
          ),
          tags$button(
            id = "blockMapButton",
            type = "button",
            class = "btn action-button btn-primary",
            HTML('<i class="icon-star"></i>ブロック')
          ) #,
          # tags$a(align = 'right', href = 'https://www.mhlw.go.jp/index.html', paste(lang[[langCode]][5]), # 厚生労働省
          #        '(',
          #        UPDATE_TIME,
          #        ')')
        )
      ),
      box(width = 4,
          dataTableOutput('totalConfirmedByProvince')),
      box(
        width = 8,
        title = lang[[langCode]][3],
        # 確認累積数
        plotlyOutput("confirmedAccumulation"),
        # 無症状病原体保有者を含む
        footer = paste('*', lang[[langCode]][12])
      ),
      box(width = 4,
          dataTableOutput('news'))
    )
  ))
))
