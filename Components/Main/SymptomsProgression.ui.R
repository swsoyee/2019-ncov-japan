Component.SymptomsProgression <- function() {
  boxPlus(
    title = tagList(icon('hospital'), '症状の進行'),
    width = 8,
    closable = F,
    collapsible = T,
    collapsed = T,
    dateInput(
      inputId = 'selectProcessDay',
      label = '日付選択',
      min = domesticDailyReport$date[1],
      max = domesticDailyReport$date[nrow(domesticDailyReport)],
      value = domesticDailyReport$date[nrow(domesticDailyReport)],
      language = 'ja'
    ),
    tags$small(
      paste0(
        '3月28日以後、厚労省集計方法が変更あり、',
        '無症状患者の内訳は公表しないため、',
        '無症状患者がどのぐらい入院しているかの情報がなくなりました。',
        'こちらではグラフ作成するため、無症状者は一律入院必要ないという仮説を設定した上で、グラフを作りました。',
        'よって、該当グラフはあくまで参考です。'
      )
    ),
    echarts4rOutput('processSankey') %>% withSpinner(),
    footer = tags$small('※開発バージョンです。')
  )
}
