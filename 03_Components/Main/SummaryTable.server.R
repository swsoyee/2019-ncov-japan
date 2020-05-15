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
  if (input$switchTableVersion == "confirmed") {
    output$summaryTable <- renderUI({
      tagList(
        dataTableOutput("confirmedByPrefTable"),
        helpText(
          icon("street-view"),
          i18n$t("感染密度 (km)：何km四方の土地（可住地面積）に感染者が１人いるかという指標である。")
        )
      )
    })
  } else if (input$switchTableVersion == "discharged") {
    output$summaryTable <- renderUI({
      dataTableOutput("dischargeAndDeathByPrefTable")
    })
  } else if (input$switchTableVersion == "test") {
    output$summaryTable <- renderUI({
      tagList(
        dataTableOutput("testByPrefTable"),
        helpText(
          icon("calculator"), "1. ",
          i18n$t("日均：日次検査人数を週間平均を計算した直近１週間の数値である。")
        ),
        helpText(
          icon("exclamation-circle"), "2. ",
          i18n$t("マイナスの値について：こちらの数値は全て厚労省が毎日発表されている数値である。厚労省の発表基準変更（5月8日）たったり、自治体からの報告と齟齬があったりする時、データの不整合性が生じるが、当サイトは修正せずそのまま厚労省が発表した数値を可視化しております。")
        ),
        accordion(
          accordionItem(
            id = 1,
            title = i18n$t("1. 3月下旬〜5月8日までの集計について"),
            tags$ol(
              tags$li(
                icon("vial"),
                i18n$t(
                  "検査人数：複数の検体を重複してカウントしていた期間については検査人数の合計に含まれていない。陽性者数の検査人数に対する比率についても、重複が排除された期間のみの比率を表している。なお、千葉県においては3/20までに1716件の検査が、神奈川県においては3/22までにクルーズ船を含む2835件の検査が、大阪府においては3/20までに2350件の検査が行われた。千葉県は3/21より、神奈川県は3/23より、大阪府は3/21より検査人数を計上している。"
                )
              ),
              tags$li(
                icon("user-plus"),
                i18n$t(
                  "陽性率：陽性者数の検査人数に対する比率は、千葉県、神奈川県及び大阪府において、複数の検体を重複してカウントしていた期間の陽性者数を除いて算出している。"
                )
              ),
              tags$li(
                icon("landmark"),
                i18n$t(
                  "東京都の検査実施人数には、医療機関による保険適用での検査人数、チャーター機帰国者、クルーズ船乗客等は含まれていない。"
                )
              )
            )
          ),
          accordionItem(
            id = 2,
            title = i18n$t("2. 5月9日からの集計について"),
            tags$ol(
              tags$li(
                icon(""),
                i18n$t("PCR検査実施人数は、一部自治体について件数を計上しているため、実際の人数より過大である。")
              )
            )
          )
        )
      )
    })
  }
})

# 退院・死亡表====
output$dischargeAndDeathByPrefTable <- renderDataTable({
  dt <- totalConfirmedByRegionData() # [count > 0]
  # dt <- dt[count > 0]
  columnName <- c("death", "perMillionDeath")
  dt[, (columnName) := replace(.SD, .SD == 0, NA), .SDcols = columnName]
  
  dt[, zeroContinuousDay := replace(.SD, .SD <= 0, NA), .SDcols = 'zeroContinuousDay']
  breaksZero <-
    seq(0, max(ifelse(is.na(dt$zeroContinuousDay), 0, dt$zeroContinuousDay), na.rm = T), 5)
  colorsZero <-
    colorRampPalette(c(lightBlue, darkBlue))(length(breaksZero) + 1)

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
  breaksPerMillion <-
    seq(0, max(ifelse(
      is.na(dt$perMillionDeath), 0, dt$perMillionDeath
    ), na.rm = T))
  colorsPerMillion <-
    colorRampPalette(c("#FFFFFF", "#6B7989"))(length(breaksPerMillion) + 1)

  datatable(
    data = dt[, c(1, 8, 12, 7, 9, 14, 15, 10), with = F][order(-totalDischarged)],
    colnames = c(
      i18n$t("自治体"),
      i18n$t("内訳"),
      i18n$t("回復"),
      i18n$t("回復推移"),
      i18n$t("死亡"),
      i18n$t("百万人あたり"),
      i18n$t("カテゴリ"),
      i18n$t("0新規日数")
    ),
    caption = "",
    escape = F,
    plugins = "natural",
    # extensions = c("Responsive"),
    extensions = "RowGroup",
    callback = htmlwidgets::JS(paste0(
      "
      table.rowGroup().",
      ifelse(input$tableShowSetting, "enable()", "disable()"),
      ".draw();
    "
    )),
    options = list(
      paging = F,
      rowGroup = list(dataSrc = 7),
      fixedHeader = T,
      dom = "t",
      scrollY = "540px",
      scrollX = T,
      columnDefs = list(
        list(
          className = "dt-left",
          width = "80px",
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
          className = "dt-center",
          width = "18%",
          targets = c(6, 8)
        ),
        list(
          visible = F,
          targets = 7
        ),
        list(
          width = "15%",
          targets = 4
        ),
        list(
          render = JS(
            "
             function(data, type, row, meta) {
                const split = data.split('|');
                return split[1];
            }"
          ),
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
    ) %>%
    formatStyle(
      columns = "perMillionDeath",
      backgroundColor = styleInterval(breaksPerMillion, colorsPerMillion),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = 'zeroContinuousDay',
      color = styleInterval(breaksZero, colorsZero),
      fontWeight = "bold"
    )
})

# TODO データ読み込み専用のところに移動
totalConfirmedByRegionData <- reactive({
  dt <-
    fread(paste0(
      DATA_PATH,
      paste0("Generated/resultSummaryTable.", languageSetting, ".csv")
    ), sep = "@")
  dt
})

# 感染表====
output$confirmedByPrefTable <- renderDataTable({
  # 感染情報だけを表示
  # dt <- dt[count > 0] # TEST
  dt <- totalConfirmedByRegionData() # [count > 0]
  # ０の値を非表示するため、NAに設定るす
  columnName <- c("today", "doubleTimeDay")
  dt[, (columnName) := replace(.SD, .SD == 0, NA), .SDcols = columnName]

  breaks <-
    seq(0, max(ifelse(is.na(dt$today), 0, dt$today), na.rm = T))
  colors <-
    colorRampPalette(c(lightRed, darkRed))(length(breaks) + 1)

  breaksDoubleTimeDay <-
    seq(0, max(unlist(ifelse(
      is.na(dt$doubleTimeDay), 0, dt$doubleTimeDay
    )), na.rm = T))
  colorsDoubleTimeDay <-
    colorRampPalette(c(darkRed, lightYellow))(length(breaksDoubleTimeDay) + 1)

  breaksPerMillion <-
    seq(0, max(ifelse(is.na(dt$perMillion), 0, dt$perMillion), na.rm = T))
  colorsPerMillion <-
    colorRampPalette(c("#FFFFFF", darkRed))(length(breaksPerMillion) + 1)

  breaksPerArea <-
    seq(0, ceiling(max(dt$perArea[!is.infinite(dt$perArea)], na.rm = T)))
  colorsPerArea <-
    colorRampPalette(c(darkYellow, "#FFFFFF"))(length(breaksPerArea) + 1)
  datatable(
    data = dt[, c(1, 3, 4, 6, 11, 13, 15, 16), with = F][order(-today, -totalToday)],
    colnames = c(
      i18n$t("自治体"),
      i18n$t("新規"),
      i18n$t("感染者数"),
      i18n$t("感染推移"),
      i18n$t("倍加日数"),
      i18n$t("百万人あたり"),
      i18n$t("カテゴリ"),
      i18n$t("感染密度(km)")
    ),
    escape = F,
    # caption = i18n$t("感染密度 (km)：何km四方の土地（可住地面積）に感染者が１人いるかという指標である。"),
    # extensions = c("Responsive"),
    extensions = "RowGroup",
    callback = htmlwidgets::JS(paste0(
      "
      table.rowGroup().",
      ifelse(input$tableShowSetting, "enable()", "disable()"),
      ".draw();
    "
    )),
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
          targets = c(3, 4)
        ),
        list(
          className = "dt-left",
          width = "80px",
          targets = 1
        ),
        list(
          className = "dt-center",
          width = "13%",
          targets = c(5, 6, 8)
        ),
        list(
          width = "30px",
          className = "dt-right",
          targets = 2
        ),
        list(
          visible = F,
          targets = 7
        ),
        list(
          render = JS(
            "
             function(data, type, row, meta) {
                const split = data.split('|');
                return split[1];
            }"
          ),
          targets = 1
        ),
        list(
          render = JS(
            "
             function(data, type, row, meta) {
                const split = data.split('|');
                return Number(split[1]).toLocaleString();;
            }"
          ),
          targets = 3
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
    ) %>%
    formatStyle(
      columns = "perArea",
      backgroundColor = styleInterval(breaksPerArea, colorsPerArea),
      fontWeight = "bold"
    )
})

# 検査表====
output$testByPrefTable <- renderDataTable({
  # dt <- mergeDt # TEST
  dt <- totalConfirmedByRegionData() # [count > 0]
  # ０の値を非表示するため、NAに設定るす
  columnName <- c("前日比")
  dt[, (columnName) := replace(.SD, .SD == 0, NA), .SDcols = columnName]

  breaksPerM <-
    seq(0, max(ifelse(is.na(dt$百万人あたり), 0, dt$百万人あたり), na.rm = T), by = 1000)
  colorsPerM <-
    colorRampPalette(c("#FFFFFF", middleYellow))(length(breaksPerM) + 1)

  breaksDaily <-
    seq(0, max(ifelse(is.na(dt$週間平均移動), 0, dt$週間平均移動), na.rm = T), by = 50)
  colorsDaily <-
    colorRampPalette(c(lightYellow, darkYellow))(length(breaksDaily) + 1)

  breaksNew <-
    seq(0, max(ifelse(is.na(dt$前日比), 0, dt$前日比), na.rm = T), by = 50)
  colorsNew <-
    colorRampPalette(c(lightYellow, darkYellow))(length(breaksNew) + 1)

  breaksPositiveRate <-
    seq(0, max(ifelse(is.na(dt$陽性率), 0, dt$陽性率), na.rm = T))
  colorsPositiveRate <-
    colorRampPalette(c(lightRed, darkRed))(length(breaksPositiveRate) + 1)

  datatable(
    data = dt[, .(region, 検査人数, 検査数推移, 前日比, 週間平均移動, 百万人あたり, 陽性率推移, 陽性率, group)][order(-前日比, -検査人数)],
    colnames = c(
      i18n$t("自治体"),
      i18n$t("検査人数"),
      i18n$t("検査推移"),
      i18n$t("前日比"),
      i18n$t("日均"),
      i18n$t("百万人あたり"),
      i18n$t("陽性率推移"),
      i18n$t("陽性率"),
      i18n$t("カテゴリ")
    ),
    escape = F,
    # extensions = c("Responsive"),
    extensions = "RowGroup",
    callback = htmlwidgets::JS(paste0(
      "
      table.rowGroup().",
      ifelse(input$tableShowSetting, "enable()", "disable()"),
      ".draw();
    "
    )),
    options = list(
      paging = F,
      rowGroup = list(dataSrc = 9),
      dom = "t",
      scrollY = "540px",
      scrollX = T,
      columnDefs = list(
        list(
          className = "dt-center",
          width = "13%",
          # targets = i18n$t("百万人あたり"))
          targets = 6
        ),
        list(
          width = "45px",
          className = "dt-right",
          # targets = i18n$t("前日比")
          targets = 4
        ),
        list(
          width = "30px",
          className = "dt-right",
          # targets = i18n$t("日均")
          targets = 5
        ),
        list(
          className = "dt-left",
          width = "80px",
          # targets = i18n$t("自治体")
          targets = 1
        ),
        list(
          className = "dt-center",
          width = "13%",
          # targets = c(i18n$t("検査人数"), i18n$t("検査推移"), i18n$t("陽性率推移"))
          targets = c(2, 3, 7)
        ),
        list(
          visible = F,
          targets = 9
        ),
        list(
          render = JS(
            "
             function(data, type, row, meta) {
                const split = data.split('|');
                return split[1];
            }"
          ),
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
    formatCurrency(
      columns = "検査人数", 
      currency = "",
      digits = 0
    ) %>%
    formatStyle(
      columns = "検査人数",
      background = styleColorBar(c(0, max(dt$検査人数, na.rm = T)), middleYellow, angle = -90),
      backgroundSize = "98% 80%",
      backgroundRepeat = "no-repeat",
      backgroundPosition = "center"
    ) %>%
    formatCurrency(
      columns = "前日比",
      currency = paste(as.character(icon("caret-up")), " "),
      digits = 0
    ) %>%
    formatString(
      columns = "陽性率",
      suffix = "%"
    ) %>%
    formatStyle(
      columns = "陽性率",
      color = styleInterval(breaksPositiveRate, colorsPositiveRate),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "百万人あたり",
      backgroundColor = styleInterval(breaksPerM, colorsPerM),
      fontWeight = "bold"
    ) %>%
    formatCurrency(
      columns = "百万人あたり", 
      currency = "",
      digits = 0
    ) %>%
    formatStyle(
      columns = "週間平均移動",
      color = styleInterval(breaksDaily, colorsDaily),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "前日比",
      color = styleInterval(breaksNew, colorsNew),
      fontWeight = "bold"
    )
})
