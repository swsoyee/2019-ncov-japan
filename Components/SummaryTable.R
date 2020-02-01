output$totalConfirmedByProvince <- renderDataTable({
  total <- rowSums(db[, 2:ncol(db)])
  tableDt <- data.table('行政区域' = db$name, # 行政区域
                        # 確認数
                        '確認数' = total)
  # displayData <- tableDt[確認数 > 0][order(-確認数)]
  displayData <- tableDt[order(-確認数)]
  datatable(
    displayData,
    rownames = FALSE,
    options = list(
      dom = 't',
      scrollY = '455px',
      scrollCollapse = T,
      paging = F
    )
  ) %>%
    formatStyle(
      c('確認数'),
      background = styleColorBar(range(tableDt[, '確認数']), 'lightblue'),
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
      scrollCollapse = T,
      scrollY = '440px'
    ),
    rownames = FALSE,
    colnames = lang[[langCode]][14],
    # 最新情報
    escape = FALSE
  )
})
