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
}, server = T)

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
}, server = T)

output$summaryByRegion <- renderDataTable({
  # setcolorder(mergeDt, c('region', 'count', 'untilToday', 'today', 'diff', 'values'))
  # dt <- mergeDt[count > 0] # TEST
  dt <- totalConfirmedByRegionData()[count > 0]
  columnName <- c('today', 'death')
  dt[, (columnName) := replace(.SD, .SD == 0, NA), .SDcols = columnName]
  dt[, zeroContinuousDay := replace(.SD, .SD <= 0, NA), .SDcols = 'zeroContinuousDay']
  # dt[, today := as.character(today)]
  # dt[!is.na(today), today := paste('+', today)]
  
  breaks <- seq(0, max(dt$today, na.rm = T), 2)
  colors <- colorRampPalette(c(lightRed, darkRed))(length(breaks) + 1)
  
  upMark <- as.character(icon('caret-up'))
  
  datatable(
    data = dt[, c(1, 4, 3, 6:ncol(dt)), with = F],
    colnames = c('都道府県', 'PCR陽性数', '新規', '新規推移', '死亡', '新規なし継続日数'),
    escape = F,
    plugins = 'natural',
    extensions = c('Responsive'),
    options = list(
      paging = F,
      dom = 't',
      scrollY = '590px',
      scrollX = T,
      columnDefs = list(
        list(
          className = 'dt-center', 
          targets = c(1, 3, 5)
        ),
        list(
          type = 'natural',
          targets = 2
        )
      ),
      fnDrawCallback = htmlwidgets::JS('
      function() {
        HTMLWidgets.staticRender();
      }
    ')
    )
  ) %>% 
    spk_add_deps() %>%
    formatStyle(
      columns = 'totalToday',
      background = htmlwidgets::JS(
        paste0("'linear-gradient(-90deg, transparent ' + (", 
          max(dt$count), "- value.split('<r ')[0])/", max(dt$count), 
          " * 100 + '%, #DD4B39 ' + (", 
          max(dt$count), "- value.split('<r ')[0])/", max(dt$count), 
          " * 100 + '% ' + (", max(dt$count), "- value.split('<r ')[0] + Number(value.split('<r ')[1]))/", max(dt$count),
          " * 100 + '%, #F56954 ' + (", 
          max(dt$count), "- value.split('<r ')[0] + Number(value.split('<r ')[1]))/", max(dt$count), " * 100 + '%)'")
      ),
      backgroundSize = '100% 80%',
      backgroundRepeat = 'no-repeat',
      backgroundPosition = 'center') %>%
    formatCurrency(
      columns = 'today',
      currency = paste(as.character(icon('caret-up')), ' '),
      digits = 0) %>%
    formatStyle(
      columns = 'today', 
      color = styleInterval(breaks, colors),
      fontWeight = 'bold',
      backgroundSize = '80% 80%',
      backgroundPosition = 'center'
    ) %>%
    formatStyle(
      columns = 'death',
      background = styleColorBar(c(0, max(dt$death, na.rm = T)), lightNavy),
      backgroundSize = '98% 80%',
      backgroundRepeat = 'no-repeat',
      backgroundPosition = 'center') %>%
    formatStyle(
      columns = 'zeroContinuousDay',
      background = styleColorBar(c(0, max(dt$zeroContinuousDay, na.rm = T)), lightBlue, angle = -90),
      backgroundSize = '98% 80%',
      backgroundRepeat = 'no-repeat',
      backgroundPosition = 'center') # %>%
    # formatStyle(
    #   columns = 'zeroContinuousDay', 
    #   backgroundColor = styleInterval(breaks, colors)
    #   )
})
