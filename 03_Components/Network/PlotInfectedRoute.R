observeEvent(input$sideBarTab, {
  if (input$sideBarTab == "route" && is.null(GLOBAL_VALUE$positiveDetail)) {
    # 詳細データけんもねずみ
    GLOBAL_VALUE$positiveDetail <- fread(paste0(DATA_PATH, "positiveDetail.csv"))
  }
})

output$infectedRouteRegionSelector <- renderUI({
  pickerInput(
    inputId = "infectedRouteByRegionPicker",
    label = i18n$t("地域選択"),
    choices = GenerateSelectProvinceOption(GLOBAL_VALUE$positiveDetail, "都道府県", languageSetting),
    selected = "東京都",
    options = list(
      `actions-box` = TRUE,
      size = 10,
      `deselect-all-text` = i18n$t("クリア"),
      `select-all-text` = i18n$t("全部"),
      `selected-text-format` = i18n$t("三件以上選択されました")
    ),
    multiple = T,
    inline = T
  )
})

infectedRouteByRegionData <- reactive({
  positiveDetail <- GLOBAL_VALUE$positiveDetail
  positiveDetail[`渡航・接触歴` %in% c("", "未"), `渡航・接触歴` := i18n$t("不明")]
  dt <- positiveDetail[!is.na(発表日), .(count = .N), by = .(都道府県, 発表日, `渡航・接触歴`)]
  # input <- list(infectedRouteByRegionPicker = c('東京都', '神奈川県')) # TEST
  dt[都道府県 %in% input$infectedRouteByRegionPicker,
         .(announceDate = as.Date(発表日, "%Y-%m-%d"), V1 = sum(count)), by = c("発表日", "渡航・接触歴")]
})

output$infectedRouteByRegion <- renderEcharts4r({
  dt <- infectedRouteByRegionData()
  if (nrow(dt) > 0) {
    dt[!is.na(announceDate)] %>%
      group_by(`渡航・接触歴`) %>%
      e_chart(announceDate) %>%
      e_bar(V1, stack = 1) %>%
      e_x_axis(splitLine = list(show = F)) %>%
      e_y_axis(
        splitLine = list(show = F),
        max = max(dt[, sum(V1), by = announceDate][[2]], na.rm = T)
      ) %>%
      e_tooltip(trigger = "axis") %>%
      e_legend(
        type = "scroll",
        orient = "vertical",
        left = "18%",
        top = "15%",
        right = "15%"
      ) %>%
      e_grid(left = "5%", right = "5%") %>%
      e_title(
        subtext = i18n$t("データソース：@kenmo_economics\n※5月9日以後のデータは収集されないため、グラフの更新も中止となります。"),
        sublink = "https://twitter.com/kenmo_economics"
      )
  }
})
