output$totalConfirmedByProvince <- renderDataTable({
  total <- rowSums(db[, 2:ncol(db)])
  tableDt <- data.table('確認場所' = db$name, # 確認場所
                        # 確認数
                        '確認数' = total)
  displayData <- tableDt[確認数 > 0][order(-確認数)]
  # displayData <- tableDt[order(-確認数)]
  datatable(
    displayData,
    rownames = F,
    selection = 'none',
    options = list(
      dom = 't',
      scrollY = '455px',
      scrollCollapse = T,
      paging = F
    )
  ) %>%
    formatStyle(
      c('確認数'),
      background = styleColorBar(range(tableDt[, '確認数']), GLOABLE_MAIN_COLOR_RGBA),
      backgroundSize = '98% 88%',
      backgroundRepeat = 'no-repeat',
      backgroundPosition = 'center'
    )
})

output$news <- renderDataTable({
  newsData <-
    data.table(
      paste0(
        "<small>",
        as.POSIXct(as.character(news$date), format = "%Y%m%d"),
        "</small><br><a href='",
        news$link,
        "'>",
        news$title,
        "</a>"
      )
    )
  datatable(
    newsData[order(-V1)],
    options = list(
      dom = 't',
      pageLength = nrow(newsData),
      scrollCollapse = T,
      scrollY = '440px'
    ),
    rownames = F,
    colnames = lang[[langCode]][14], # 最新情報
    escape = F
  )
})

output$detailSummaryByGenderAndAge <- renderPlotly({
  plot_ly(
    x = detailSummary[gender == '男']$age,
    y = detailSummary[gender == '男']$count,
    type = 'bar',
    name = lang[[langCode]][49] # 男性
  ) %>%
    add_trace(x = detailSummary[gender == '女']$age,
              y = detailSummary[gender == '女']$count,
              name = lang[[langCode]][50] # 女性
              ) %>%
    layout(yaxis = list(title = lang[[langCode]][11]), # 人数
           xaxis = list(title = lang[[langCode]][51]), # 年代
           legend = list(
             orientation = 'h',
             x = 0.5,
             xanchor = 'center',
             y = 1.1
           ),
           barmode = 'stack')
})

output$detail <- renderDataTable({
  datatable(detail,
            colnames = lang[[langCode]][37:48],
            caption = 'データの正確性を確保するため、厚生労働省の報道発表資料のみ参照するので、遅れがあります（土日更新しない模様）。',
            filter = 'top',
            escape = 12,
            selection = 'none',
            options = list(
              scrollCollapse = T,
              scrollX = T,
              autoWidth = T,
              columnDefs = list(
                list(width = '5px', targets = 0), 
                list(width = '40px', targets = c(1, 2, 4, 5)), 
                list(width = '60px', targets = c(3, 7, 8)),
                list(width = '80px', targets = c(9)),
                list(width = '100px', targets = c(6, 10, 11)),
                list(width = '630px', targets = 12)
              )
            )) %>%
    formatStyle(
      'observationStaus',
      target = 'row',
      background = styleEqual('終了', '#CCCCCC'),
    )
})
