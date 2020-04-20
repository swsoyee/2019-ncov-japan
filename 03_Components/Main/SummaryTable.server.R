# TODO こちらのページの内容ではないから別のところに移動すべき、厚労省もまとめてくれないので、削除するのもあり
output$detail <- renderDataTable({
  datatable(
    detail,
    colnames = lang[[langCode]][37:48],
    rownames = NULL,
    caption = "データの正確性を確保するため、厚生労働省の報道発表資料のみ参照するので、遅れがあります（土日更新しない模様）。",
    filter = "top",
    escape = 11,
    selection = "none",
    options = list(
      scrollCollapse = T,
      scrollX = T,
      autoWidth = T,
      columnDefs = list(
        list(width = "40px", targets = c(0, 1, 3, 4)),
        list(width = "60px", targets = c(2, 6, 7)),
        list(width = "80px", targets = c(8)),
        list(width = "100px", targets = c(5, 9, 10)),
        list(width = "630px", targets = 11)
      )
    )
  ) %>%
    formatStyle("observationStaus",
      target = "row",
      background = styleEqual("終了", "#CCCCCC"),
    )
})

# ==== シンプルバージョンのテーブル表示==== (サイトが重い時に追加用)
observeEvent(input$switchTableVersion, {
  if (input$switchTableVersion) {
    output$summaryTable <- renderUI({
      dataTableOutput("confirmedByPrefTable")
    })
  } else {
    output$summaryTable <- renderUI({
      dataTableOutput("dischargeAndDeathByPrefTable")
    })
  }
})

output$dischargeAndDeathByPrefTable <- renderDataTable({
  dt <- totalConfirmedByRegionData()[count > 0]
  # dt <- dt[count > 0]
  columnName <- c("death")
  dt[, (columnName) := replace(.SD, .SD == 0, NA), .SDcols = columnName]

  breaksDeath <-
    seq(0, max(ifelse(is.na(dt$death), 0, dt$death), na.rm = T), 2)
  colorsDeath <-
    colorRampPalette(c(lightNavy, darkNavy))(length(breaksDeath) + 1)

  breaksDischarged <-
    seq(0, max(ifelse(
      is.na(dt$totalDischarged), 0, dt$totalDischarged
    ), na.rm = T), 2)
  colorsDischarged <-
    colorRampPalette(c(lightGreen, darkGreen))(length(breaksDischarged) + 1)

  datatable(
    data = dt[, c(1, 8, 12, 7, 9, 14), with = F],
    colnames = c("自治体", "内訳", "退院", "退院推移", "死亡", "カテゴリ"),
    caption = "最適の見せ方を探しているため、見た目が時々変わります。予めご了承ください。",
    escape = F,
    plugins = "natural",
    # extensions = c("Responsive"),
    extensions = 'RowGroup',
    callback = htmlwidgets::JS(paste0("
      table.rowGroup().", ifelse(input$tableShowSetting, "enable()", "disable()"), ".draw();
    ")),
    options = list(
      paging = F,
      rowGroup = list(dataSrc = 6),
      fixedHeader = T,
      dom = "t",
      scrollY = "540px",
      scrollX = T,
      columnDefs = list(
        list(
          className = "dt-left",
          width = "50px",
          targets = 1
        ),
        list(
          className = "dt-center",
          targets = 2:5
        ),
        list(
          width = "30px",
          targets = c(2, 3, 5)
        ),
        list(
          visible = F,
          targets = 6
        ),
        list(
          width = "15%",
          targets = 4
        ),
        list(
          render = JS("
             function(data, type, row, meta) {
                const split = data.split('|');
                return split[1];
            }"),
          targets = 1
        )
      ),
      fnDrawCallback = htmlwidgets::JS("
      function() {
        HTMLWidgets.staticRender();
      }
    ")
    )
  ) %>%
    spk_add_deps() %>%
    # formatCurrency(
    #   columns = "today",
    #   currency = paste(as.character(icon("caret-up")), " "),
    #   digits = 0
    # ) %>%s
    formatStyle(
      columns = "totalDischarged",
      color = styleInterval(breaksDischarged, colorsDischarged),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "death",
      color = styleInterval(breaksDeath, colorsDeath),
      fontWeight = "bold"
    )
})

# TODO データ読み込み専用のところに移動
totalConfirmedByRegionData <- reactive({
  dt <- fread(paste0(DATA_PATH, "resultSummaryTable.csv"), sep = "@")
  dt
})

output$summaryByRegion <- renderDataTable({
  # setcolorder(mergeDt, c('region', 'count', 'untilToday', 'today', 'diff', 'values'))
  # dt <- mergeDt[count > 0] # TEST
  dt <- totalConfirmedByRegionData()[count > 0]
  # ０の値を非表示するため、NAに設定るす
  columnName <- c("today", "death")
  dt[, (columnName) := replace(.SD, .SD == 0, NA), .SDcols = columnName]
  # TODO 感染拡大が終息する後からカラム復活、今は表示する必要はない
  # dt[, zeroContinuousDay := replace(.SD, .SD <= 0, NA), .SDcols = 'zeroContinuousDay']

  breaks <-
    seq(0, max(ifelse(is.na(dt$today), 0, dt$today), na.rm = T), 2)
  colors <-
    colorRampPalette(c(lightRed, darkRed))(length(breaks) + 1)

  breaksDeath <-
    seq(0, max(ifelse(is.na(dt$death), 0, dt$death), na.rm = T), 2)
  colorsDeath <-
    colorRampPalette(c("white", lightNavy))(length(breaksDeath) + 1)

  datatable(
    data = dt[, c(1, 3, 4, 6:9, 14), with = F],
    colnames = c("自治体", "新規", "感染者数", "新規感染", "新規退院", "内訳", "死亡", "カテゴリ"),
    caption = "最適の見せ方を探しているため、見た目が時々変わります。予めご了承ください。",
    escape = F,
    # extensions = c("Responsive"),
    extensions = 'RowGroup',
    callback = htmlwidgets::JS(paste0("
      table.rowGroup().", ifelse(input$tableShowSetting, "enable()", "disable()"), ".draw();
    ")),
    options = list(
      paging = F,
      rowGroup = list(dataSrc = 8),
      dom = "t",
      fixedHeader = T,
      scrollY = "540px",
      scrollX = T,
      columnDefs = list(
        list(
          className = "dt-left",
          width = "50px",
          targets = 1
        ),
        list(
          className = "dt-center",
          width = "15%",
          targets = 3:5
        ),
        list(
          className = "dt-center",
          width = "10%",
          targets = 6:7
        ),
        list(
          className = "dt-center",
          width = "30px",
          targets = 2
        ),
        list(
          visible = F,
          targets = 8
        ),
        list(
          render = JS("
             function(data, type, row, meta) {
                const split = data.split('|');
                return split[1];
            }"),
          targets = c(1, 3)
        )
      ),
      fnDrawCallback = htmlwidgets::JS("
      function() {
        HTMLWidgets.staticRender();
      }
    ")
    )
  ) %>%
    spk_add_deps() %>%
    formatStyle(
      columns = "totalToday",
      background = htmlwidgets::JS(
        paste0(
          "'linear-gradient(-90deg, transparent ' + (",
          max(dt$count),
          "- value.split('|')[1])/",
          max(dt$count),
          " * 100 + '%, #DD4B39 ' + (",
          max(dt$count),
          "- value.split('|')[1])/",
          max(dt$count),
          " * 100 + '% ' + (",
          max(dt$count),
          "- value.split('|')[1] + Number(value.split('|')[2]))/",
          max(dt$count),
          " * 100 + '%, #F56954 ' + (",
          max(dt$count),
          "- value.split('|')[1] + Number(value.split('|')[2]))/",
          max(dt$count),
          " * 100 + '%)'"
        )
      ),
      backgroundSize = "100% 80%",
      backgroundRepeat = "no-repeat",
      backgroundPosition = "center"
    ) %>%
    formatCurrency(
      columns = "today",
      currency = paste(as.character(icon("caret-up")), " "),
      digits = 0
    ) %>%
    formatStyle(
      columns = "today",
      color = styleInterval(breaks, colors),
      fontWeight = "bold",
      backgroundSize = "80% 80%",
      backgroundPosition = "center"
    ) %>%
    formatStyle(
      columns = "death",
      backgroundColor = styleInterval(breaksDeath, colorsDeath),
      fontWeight = "bold",
      backgroundPosition = "center"
    ) # %>%
  # formatStyle(
  #   columns = 'zeroContinuousDay',
  #   background = styleColorBar(c(0, max(dt$zeroContinuousDay, na.rm = T)), lightBlue, angle = -90),
  #   backgroundSize = '98% 80%',
  #   backgroundRepeat = 'no-repeat',
  #   backgroundPosition = 'center')
})

output$confirmedByPrefTable <- renderDataTable({
  # 感染情報だけを表示
  # dt <- dt[count > 0] # TEST
  dt <- totalConfirmedByRegionData()[count > 0]
  # ０の値を非表示するため、NAに設定るす
  columnName <- c("today", "doubleTimeDay")
  dt[, (columnName) := replace(.SD, .SD == 0, NA), .SDcols = columnName]

  breaks <-
    seq(0, max(ifelse(is.na(dt$today), 0, dt$today), na.rm = T))
  colors <-
    colorRampPalette(c(lightRed, darkRed))(length(breaks) + 1)

  breaksDoubleTimeDay <-
    seq(0, max(ifelse(
      is.na(dt$doubleTimeDay), 0, dt$doubleTimeDay
    ), na.rm = T))
  colorsDoubleTimeDay <-
    colorRampPalette(c(darkRed, lightYellow))(length(breaksDoubleTimeDay) + 1)

  breaksPerMillion <-
    seq(0, max(ifelse(is.na(dt$perMillion), 0, dt$perMillion), na.rm = T))
  colorsPerMillion <-
    colorRampPalette(c("#FFFFFF", darkRed))(length(breaksPerMillion) + 1)

  datatable(
    data = dt[, c(1, 3, 4, 6, 11, 13, 14), with = F],
    colnames = c("自治体", "新規", "感染者数", "感染推移", "倍増日数", "百万人当たり", "カテゴリ"),
    escape = F,
    caption = "最適の見せ方を探しているため、見た目が時々変わります。予めご了承ください。",
    # extensions = c("Responsive"),
    extensions = 'RowGroup',
    callback = htmlwidgets::JS(paste0("
      table.rowGroup().", ifelse(input$tableShowSetting, "enable()", "disable()"), ".draw();
    ")),
    options = list(
      paging = F,
      rowGroup = list(dataSrc = 7),
      dom = "t",
      scrollY = "540px",
      scrollX = T,
      columnDefs = list(
        list(
          className = "dt-center",
          width = "15%",
          targets = c(3, 4, 5)
        ),
        list(
          className = "dt-left",
          width = "50px",
          targets = 1
        ),
        list(
          className = "dt-center",
          width = "20%",
          targets = c(4, 6)
        ),
        list(
          width = "30px",
          className = "dt-left",
          targets = 2
        ),
        list(
          visible = F,
          targets = 7
        ),
        list(
          render = JS("
             function(data, type, row, meta) {
                const split = data.split('|');
                return split[1];
            }"),
          targets = c(1, 3)
        )
      ),
      fnDrawCallback = htmlwidgets::JS("
      function() {
        HTMLWidgets.staticRender();
      }
    ")
    )
  ) %>%
    spk_add_deps() %>%
    formatStyle(
      columns = "totalToday",
      background = htmlwidgets::JS(
        paste0(
          "'linear-gradient(-90deg, transparent ' + (",
          max(dt$count),
          "- value.split('|')[1])/",
          max(dt$count),
          " * 100 + '%, #DD4B39 ' + (",
          max(dt$count),
          "- value.split('|')[1])/",
          max(dt$count),
          " * 100 + '% ' + (",
          max(dt$count),
          "- value.split('|')[1] + Number(value.split('|')[2]))/",
          max(dt$count),
          " * 100 + '%, #F56954 ' + (",
          max(dt$count),
          "- value.split('|')[1] + Number(value.split('|')[2]))/",
          max(dt$count),
          " * 100 + '%)'"
        )
      ),
      backgroundSize = "100% 80%",
      backgroundRepeat = "no-repeat",
      backgroundPosition = "center"
    ) %>%
    formatCurrency(
      columns = "today",
      currency = paste(as.character(icon("caret-up")), " "),
      digits = 0
    ) %>%
    formatStyle(
      columns = "today",
      color = styleInterval(breaks, colors),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "doubleTimeDay",
      color = styleInterval(breaksDoubleTimeDay, colorsDoubleTimeDay),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "perMillion",
      backgroundColor = styleInterval(breaksPerMillion, colorsPerMillion),
      fontWeight = "bold"
    )
})
