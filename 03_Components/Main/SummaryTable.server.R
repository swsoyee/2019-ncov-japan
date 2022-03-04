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
          icon("exclamation-circle"),
          i18n$t("検疫職員：国職員（横浜港のクルーズ船対応）・空港検疫での判明者などを含まれています。")
        ),
        helpText(
          icon("chart-bar"),
          i18n$t("感染者数：本サイトのリアルタイム感染者数は再び陽性になった患者は新規として数えないため、一部のメディアと自治体が発表した数（延べ人数）と一致しない場合があります。")
        ),
        helpText(
          icon("procedures"),
          i18n$t("現在患者数：厚労省のデータをもとにして計算しているため、速報部分の感染者数が含まれていません。")
        ),
        helpText(
          icon("question-circle"),
          i18n$t("10万対発生数：10万人口対直近1週間の新規感染者数。記号は一日前の該当数値の比較結果を示されています。")
        ),
        helpText(
          icon("street-view"),
          i18n$t("実効再生産数：「すでに感染が広がっている状況において、1人の感染者が次に平均で何人にうつすか」を示す指標。")
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
            title = tagList(i18n$t("2. 5月9日からの集計について"), boxLabel(status = "warning", i18n$t("必読"))),
            tags$ol(
              tags$li(
                icon("exclamation-triangle"),
                i18n$t("PCR検査実施人数は、一部自治体について件数を計上しているため、実際の人数より過大である。")
              ),
              tags$li(
                icon("exclamation-triangle"),
                i18n$t("一部のデータについて、マイナスになったり大きく増減しているのは、都道府県からの報告に訂正または集計されていないデータを加わった結果になります。参考："),
                tags$a(icon("external-link-alt"), "5/13", href = "https://www.mhlw.go.jp/stf/newpage_11291.html"),
                tags$a(icon("external-link-alt"), "5/14", href = "https://www.mhlw.go.jp/stf/newpage_11311.html"),
                tags$a(icon("external-link-alt"), "5/15", href = "https://www.mhlw.go.jp/stf/newpage_11339.html"),
                tags$a(icon("external-link-alt"), "5/16", href = "https://www.mhlw.go.jp/stf/newpage_11354.html"),
                tags$a(icon("external-link-alt"), "6/18", href = "https://www.mhlw.go.jp/stf/newpage_11961.html"),
                tags$a(icon("external-link-alt"), "6/19", href = "https://www.mhlw.go.jp/stf/newpage_11993.html"),
                tags$a(icon("external-link-alt"), icon("github"), href = "https://github.com/swsoyee/2019-ncov-japan/issues/389")
              ),
              tags$li(
                icon("exclamation-triangle"),
                i18n$t("本サイトの陽性率の計算に関しては、3月下旬から5月8日までの間に厚労省が公開している陽性率と同じ計算方法で計算しています。5月8日以後基準変更などがあるため、厚労省側は公式で陽性率の発表しなくなり、自治体が公表しているデータ（陽性率など）を正しい数値であることを見做しています。本サイトは引き続き同じ計算式で厚労省が発表しているデータだけで陽性率を計算しているが、分母（検査人数）の正確さの保証はないため、陽性率の正確さに関する保証は一切ありません。正確の数値を求めている方は各自治体のページをご参考するようお願い致します。")
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
  dt[, zeroContinuousDay := replace(.SD, .SD <= 0, NA), .SDcols = "zeroContinuousDay"]

  datatable(
    dt[, .(region, detailBullet, totalDischarged, dischargeDiff, death, perMillionDeath, zeroContinuousDay, group)],
    escape = F,
    colnames = c(
      i18n$t("自治体"),
      i18n$t("内訳"),
      i18n$t("回復"),
      i18n$t("回復推移"),
      i18n$t("死亡"),
      i18n$t("百万人あたり"),
      i18n$t("0新規日数"),
      i18n$t("カテゴリ")
    ),
    plugins = "natural",
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
      rowGroup = list(dataSrc = 8),
      order = list(
        list(5, "desc")
      ),
      fixedHeader = T,
      dom = "t",
      scrollY = "540px",
      scrollX = T,
      columnDefs = list(
        list(
          className = "dt-center",
          targets = 2:7
        ),
        list(
          visible = F,
          targets = 8
        ),
        list(
          render = JS("function(data, type, row, meta) {
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
    # formatStyle(
    #   columns = "totalDischarged",
    #   color = do.call(
    #     styleInterval,
    #     generateColorStyle(data = dt$totalDischarged, colors = c(lightGreen, darkGreen), by = 100)
    #   ),
    #   fontWeight = "bold"
    # ) %>%
    formatCurrency(
      columns = "totalDischarged",
      currency = "",
      digits = 0
    ) %>%
    formatStyle(
      columns = "death",
      color = do.call(
        styleInterval,
        generateColorStyle(data = dt$death, colors = c(lightNavy, darkNavy), by = 10)
      ),
      fontWeight = "bold"
    ) %>%
    formatCurrency(
      columns = "death",
      currency = "",
      digits = 0
    ) %>%
    formatStyle(
      columns = "perMillionDeath",
      backgroundColor = do.call(
        styleInterval,
        generateColorStyle(data = dt$perMillionDeath, colors = c("#FFFFFF", "#6B7989"), by = 1)
      ),
      fontWeight = "bold"
    ) %>%
    formatCurrency(
      columns = "perMillionDeath",
      currency = "",
      digits = 0
    ) %>%
    formatStyle(
      columns = "zeroContinuousDay",
      color = do.call(
        styleInterval,
        generateColorStyle(data = dt$zeroContinuousDay, colors = c(lightBlue, darkBlue), by = 5)
      ),
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

  datatable(
    data = dt[, c(1, 3, 4, 6, 25, 11, 13, 15, 16), with = F],
    colnames = c(
      i18n$t("自治体"),
      i18n$t("新規"),
      i18n$t("感染者数"),
      i18n$t("感染推移"),
      i18n$t("現在患者数"),
      i18n$t("倍加日数"),
      i18n$t("10万対発生数※"),
      i18n$t("カテゴリ"),
      i18n$t("実効再生産数")
    ),
    escape = F,
    # extensions = c("Responsive"),
    extensions = c("RowGroup", "Buttons"),
    callback = htmlwidgets::JS(paste0(
      "
      table.rowGroup().",
      ifelse(input$tableShowSetting, "enable()", "disable()"),
      ".draw();
    "
    )),
    options = list(
      paging = F,
      rowGroup = list(dataSrc = 8),
      dom = "Bt",
      buttons = list(
        list(
          extend = "colvis",
          columns = c(4, 5, 6, 7, 9),
          text = i18n$t("カラム表示")
        )
      ),
      scrollY = "540px",
      scrollX = T,
      order = list(
        list(3, "desc")
      ),
      columnDefs = list(
        list(
          className = "dt-left",
          targets = 1
        ),
        list(
          className = "dt-center",
          targets = c(3:7, 9)
        ),
        list(
          width = "40px",
          className = "dt-right",
          targets = 2
        ),
        list(
          visible = F,
          targets = c(6, 8)
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
                return Number(split[1]).toLocaleString();
            }"
          ),
          targets = 3
        ),
        list(
          render = JS(
            "function(data, type, row, meta) {
                const split = data.split('|');
                return split[1];
            }"
          ),
          targets = c(7, 9)
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
      color = do.call(
        styleInterval,
        generateColorStyle(data = dt$today, colors = c(lightRed, darkRed), by = 5)
      ),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "active",
      color = do.call(
        styleInterval,
        generateColorStyle(data = dt$active, colors = c(lightYellow, darkRed), by = 100)
      ),
      fontWeight = "bold"
    ) %>%
    formatCurrency(
      columns = "active",
      currency = "",
      digits = 0
    ) %>%
    formatStyle(
      columns = "doubleTimeDay",
      color = do.call(
        styleInterval,
        generateColorStyle(data = dt$doubleTimeDay, colors = c(darkRed, lightYellow), by = 5)
      ),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "perHundredThousand",
      backgroundColor = htmlwidgets::JS(
        "isNaN(parseFloat(value.match(/\\|(.+?) /)[1])) ? '' : value.match(/\\|(.+?) /)[1] <= 0 ? \"rgba(0,0,0,0)\" : value.match(/\\|(.+?) /)[1] <= 5 ? \"#F3E3E1\" : value.match(/\\|(.+?) /)[1] <= 10 ? \"#E8C7C3\" : value.match(/\\|(.+?) /)[1] <= 15 ? \"#DDABA5\" : value.match(/\\|(.+?) /)[1] <= 20 ? \"#D18F87\" : value.match(/\\|(.+?) /)[1] <= 25 ? \"#C67369\" : value.match(/\\|(.+?) /)[1] <= 30 ? \"#BB574B\" : \"#B03C2D\""
      ),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "Rt",
      backgroundColor = htmlwidgets::JS(
        "isNaN(parseFloat(value.match(/\\|(.+?) /)[1])) ? '' : value.match(/\\|(.+?) /)[1] <= 0.3 ? \"rgba(0,0,0,0)\" : value.match(/\\|(.+?) /)[1] <= 0.6 ? \"#F8BF76\" : value.match(/\\|(.+?) /)[1] <= 0.9 ? \"#F39C11\" : value.match(/\\|(.+?) /)[1] < 1 ? \"#DB8B0A\" : \"#B03C2D\""
      ),
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

  datatable(
    data = dt[, .(region, 検査人数, 検査数推移, 前日比, 週間平均移動, 百万人あたり, 陽性率推移, 陽性率, group)],
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
    extensions = c("RowGroup", "Buttons"),
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
      dom = "Bt",
      buttons = list(
        list(
          extend = "colvis",
          columns = c(8),
          text = i18n$t("カラム表示")
        )
      ),
      scrollY = "540px",
      scrollX = T,
      order = list(
        list(2, "desc")
      ),
      columnDefs = list(
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
          # targets = i18n$t("自治体")
          targets = 1
        ),
        list(
          className = "dt-center",
          targets = c(2, 3, 6, 7)
        ),
        list(
          visible = F,
          targets = 8:9
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
    formatCurrency(
      columns = "週間平均移動",
      currency = "",
      digits = 0
    ) %>%
    formatString(
      columns = "陽性率",
      suffix = "%"
    ) %>%
    formatStyle(
      columns = "陽性率",
      color = do.call(
        styleInterval,
        generateColorStyle(data = dt$陽性率, colors = c(lightRed, darkRed), by = 4)
      ),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "百万人あたり",
      backgroundColor = do.call(
        styleInterval,
        generateColorStyle(data = dt$百万人あたり, colors = c("#FFFFFF", middleYellow), by = 1000)
      ),
      fontWeight = "bold"
    ) %>%
    formatCurrency(
      columns = "百万人あたり",
      currency = "",
      digits = 0
    ) %>%
    formatStyle(
      columns = "週間平均移動",
      color = do.call(
        styleInterval,
        generateColorStyle(data = dt$週間平均移動, colors = c(lightYellow, darkYellow), by = 50)
      ),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "前日比",
      color = do.call(
        styleInterval,
        generateColorStyle(data = dt$前日比, colors = c(lightYellow, darkYellow), by = 50)
      ),
      fontWeight = "bold"
    )
})
