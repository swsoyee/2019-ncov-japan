output$totalConfirmedByProvince <- renderDataTable({
  total <- rowSums(db[, 2:ncol(db)])
  tableDt <- data.table('行政区域' = db$name, # 行政区域
                        # 確認数
                        '確認数' = total)
  # displayData <- tableDt[確認数 > 0][order(-確認数)]
  displayData <- tableDt[order(-確認数)]
  datatable(
    displayData,
    rownames = F,
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

output$detail <- renderDataTable({
  datatable(detail,
            colnames = lang[[langCode]][37:48],
            filter = 'top',
            escape = 12,
            options = list(
              scrollCollapse = T,
              scrollX = T,
              autoWidth = T,
              columnDefs = list(
                list(width = '10px', targets = 0), 
                list(width = '40px', targets = c(1, 2, 4, 5)), 
                list(width = '60px', targets = c(3, 7, 8, 11)),
                list(width = '80px', targets = 9),
                list(width = '100px', targets = c(6, 10)),
                list(width = '250px', targets = 12)
              )
            ))
})
