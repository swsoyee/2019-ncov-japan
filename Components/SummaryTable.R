output$confirmedByProvince <- renderDataTable({
  total <- colSums(byDate[, 2:ncol(byDate)])
  tableDt <- data.table(region = names(total), count = total)
  
  if (is.null(input$showOtherRegion)) {
    tableDt <- tableDt[!(region %in% lang[[langCode]][35:36])]
  } else {
    if (!('showShip' %in% input$showOtherRegion)) {
      tableDt <- tableDt[region != lang[[langCode]][35]] # クルーズ船
    }
    if (!('showFlight' %in% input$showOtherRegion)) {
      tableDt <- tableDt[region != lang[[langCode]][36]] # チャーター便
    }
  }
  displayData <- tableDt[count > 0][order(-count)]
  colnames(displayData) <- c(lang[[langCode]][13], # 確認場所
                             lang[[langCode]][9]) # 確認数
  
  datatable(
    displayData,
    rownames = F,
    selection = 'none',
    options = list(
      dom = 't',
      scrollY = '367px',
      scrollCollapse = T,
      paging = F
    )
  ) %>%
    formatStyle(
      # 確認数
      c(lang[[langCode]][9]),
      background = styleColorBar(range(tableDt[, count]), GLOABLE_MAIN_COLOR_RGBA),
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
      scrollY = '925px'
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
