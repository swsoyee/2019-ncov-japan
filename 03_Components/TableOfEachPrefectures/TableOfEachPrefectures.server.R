output$TableOfEachPrefectures <- renderDataTable({
  # dt <- dt[count > 0] # TEST
  dt <- totalConfirmedByRegionData() # [count > 0]
  # ０の値を非表示するため、NAに設定るす
  columnName <- c("today", "doubleTimeDay")
  dt[, (columnName) := replace(.SD, .SD == 0, NA), .SDcols = columnName]

  displayColumn <- list(
    "region" = i18n$t("自治体"),
    "today" = i18n$t("新規"),
    "totalToday" = i18n$t("感染者数"),
    "diff" = i18n$t("感染推移"),
    "active" = i18n$t("現在患者数"),
    "doubleTimeDay" = i18n$t("倍加日数"),
    "perHundredThousand" = i18n$t("10万対発生数※"),
    "group" = i18n$t("カテゴリ"),
    "Rt" = i18n$t("実効再生産数"),
    "検査人数" = i18n$t("検査人数"),
    "前日比" = i18n$t("前日比"),
    "検査数推移" = i18n$t("検査推移"),
    "detailBullet" = i18n$t("内訳"),
    "death" = i18n$t("死亡")
  )

  datatable(
    data = dt[, names(displayColumn), with = FALSE],
    colnames = as.vector(unlist(displayColumn)),
    escape = FALSE,
    extensions = c("RowGroup", "Buttons"),
    callback = htmlwidgets::JS(paste0(
      "table.rowGroup().",
      ifelse(input$tableOfEachPrefecturesBoxSidebar, "enable()", "disable()"),
      ".draw();"
    )),
    options = list(
      paging = F,
      rowGroup = list(dataSrc = 8),
      dom = "t",
      scrollY = "540px",
      scrollX = T,
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
          width = "30px",
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
    ) %>%
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
    formatStyle(
      columns = "前日比",
      color = do.call(
        styleInterval,
        generateColorStyle(data = dt$前日比, colors = c(lightYellow, darkYellow), by = 50)
      ),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "death",
      color = do.call(
        styleInterval,
        generateColorStyle(data = dt$death, colors = c(lightNavy, darkNavy), by = 10)
      ),
      fontWeight = "bold"
    )
})
