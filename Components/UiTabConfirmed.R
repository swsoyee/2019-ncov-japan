tabPanel(
  # 感染者数の推移
  title = lang[[langCode]][3], 
  icon = icon('procedures'),
  value = 'confirmed',
  fluidRow(
    column(
      width = 8,
      fluidRow(
        tags$br(),
        pickerInput(
          inputId = 'regionPicker',
          # 地域選択
          label = lang[[langCode]][93],
          choices = regionName,
          selected = defaultSelectedRegionName,
          options = list(
            `actions-box` = TRUE,
            size = 10,
            # クリア
            `deselect-all-text` = lang[[langCode]][91],
            # 全部
            `select-all-text` = lang[[langCode]][92],
            # 三件以上選択されました
            `selected-text-format` = lang[[langCode]][94] 
          ),
          multiple = T,
          width = '70%',
          inline = T
        )
      ),
      uiOutput('confirmedLineWrapper') %>% withSpinner()
    ),
    column(
      width = 4,
      tags$br(),
      tags$b(paste0(
        lang[[langCode]][97], length(regionZero), ' (', round(length(regionZero) /
                                                                47 * 100, 2), '%)'
      )),
      uiOutput('saveArea'),
      tags$br(),
      tags$b('感染者'),
      echarts4rOutput('confirmedBar', height = '20px') %>% withSpinner(),
      uiOutput('todayConfirmed'),
      tags$br(),
      tags$b('死亡者'),
      echarts4rOutput('deathBar', height = '20px') %>% withSpinner(),
      uiOutput('todayDeath'),
      tags$hr(),
      tags$b('感染者確認数（日次）'),
      uiOutput('renderCalendar')
    )
  )
)
