# ====感染確認情報====
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
      dom = 'tp',
      scrollY = '360px'
    ),
    rownames = F,
    colnames = lang[[langCode]][14], # 感染確認情報
    escape = F
  )
})

output$detail <- renderDataTable({
  datatable(detail,
            colnames = lang[[langCode]][37:48],
            rownames = NULL,
            caption = 'データの正確性を確保するため、厚生労働省の報道発表資料のみ参照するので、遅れがあります（土日更新しない模様）。',
            filter = 'top',
            escape = 11,
            selection = 'none',
            options = list(
              scrollCollapse = T,
              scrollX = T,
              autoWidth = T,
              columnDefs = list(
                list(width = '40px', targets = c(0, 1, 3, 4)),
                list(width = '60px', targets = c(2, 6, 7)),
                list(width = '80px', targets = c(8)),
                list(width = '100px', targets = c(5, 9, 10)),
                list(width = '630px', targets = 11)
              )
            )) %>%
    formatStyle(
      'observationStaus',
      target = 'row',
      background = styleEqual('終了', '#CCCCCC'),
    )
})
