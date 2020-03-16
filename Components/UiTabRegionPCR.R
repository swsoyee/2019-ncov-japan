tabPanel(
  title = tagList(
    icon('vials'), 
    'PCR検査状況'
  ),
  fluidRow(
    column(
      width = 8,
      tags$br(),
      tags$a(
        icon('database'), 
        'データ提供：@kenmo_economics', 
        href = 'https://twitter.com/kenmo_economics'
      ),
      tags$p('発表なしの日の検査数を0扱いしています（補間法のオプションを追加する予定あり）。また、個別の市のデータは県に含まれていないので、ご注意してください。データに関する問い合わせは@kenmo_economicsまで。'),
      echarts4rOutput('regionPCR') %>% withSpinner()
    ),
    column(
      width = 4,
      tags$br(),
      selectInput(
        inputId = 'selectSingleRegionPCR', 
        label = '地域選択', 
        choices = unique(provincePCR$県名)
      ),
      echarts4rOutput('singleRegionPCR')
    )
  )
)
