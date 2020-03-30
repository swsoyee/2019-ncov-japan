tabPanel(
  title = tagList(
    icon('vials'), 
    'PCR検査状況'
  ),
  fluidRow(
    column(
      width = 8,
      tags$br(),
      tags$small(icon('database'), 
                 'データ提供：', 
                 tags$a(href = 'https://twitter.com/kenmo_economics', icon('twitter'), '@kenmo_economics')
      ),
      tags$p('こちらは補間法を使用した後のデータになるます。また、個別の市のデータは県に含まれていないので、ご注意してください。データに関する問い合わせは@kenmo_economicsまで。'),
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
