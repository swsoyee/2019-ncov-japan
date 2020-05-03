output$genderBar <- renderEcharts4r({
  if (!is.null(input$ageGenderOptionRegion) & !is.null(input$ageGenderOptionDateRange)) {
    dt <- GLOBAL_VALUE$signateDetail.ageGenderData
    updateDay <- max(dt$公表日, na.rm = T)
    dt[年代 == "", 年代 := "不明"] # TODO データ作成時処理すべき
    # 性別・年代マスター作成
    genderAgeMaster <- data.table(
      年代 = rep(c("不明", "00代", "> 90代", paste0(seq(1:8), "0代")), 3),
      性別 = c(rep("男性", 11), rep("女性", 11), rep("不明", 11))
    )

    if (input$ageGenderOptionRegion != "全国") {
      dt <- dt[受診都道府県 %in% input$ageGenderOptionRegion]
    }
    dt <- dt[公表日 >= input$ageGenderOptionDateRange[1] & 公表日 <= input$ageGenderOptionDateRange[2]]

    dt <- merge(genderAgeMaster, dt[, .(人数 = .N), by = c("年代", "性別")], all.x = T)
    dt[is.na(人数), 人数 := 0]
    forPlot <- reshape(dt, idvar = "年代", timevar = "性別", direction = "wide")[order(年代)][, male_minus := -人数.男性]

    maleCount <- sum(forPlot$人数.男性, na.rm = T)
    femaleCount <- sum(forPlot$人数.女性, na.rm = T)
    unknownCount <- sum(forPlot$人数.不明, na.rm = T)
    totalCount <- maleCount + femaleCount + unknownCount

    forPlot$年代 <- suppressWarnings(i18n$t(forPlot$年代))
    forPlot %>%
      e_chart(年代) %>%
      e_bar(male_minus, stack = "1", name = i18n$t("男性"), itemStyle = list(color = darkNavy)) %>%
      e_bar(人数.女性, stack = "1", name = i18n$t("女性"), itemStyle = list(color = middleRed)) %>%
      e_x_axis(axisTick = list(show = F), axisLabel = list(inside = T)) %>%
      e_labels(position = "inside", formatter = htmlwidgets::JS("
      function(params) {
        let count = params.value[0]
        if(count < 0) {
          count = -count
        }
        return(count)
      }
    ")) %>%
      e_y_axis(show = F) %>%
      e_flip_coords() %>%
      e_tooltip(
        formatter = htmlwidgets::JS(paste0("
      function(params) {
        let count = params[0].value[0]
        if(count < 0) {
          count = -count
        }
        const total = Number(count) + Number(params[1].value[0])
        return(`${params[0].value[1]} ", i18n$t("合計："), "${total} (", i18n$t("総計の"), "${Math.round(total/", totalCount, "*100, 4)}%)
          <hr>", i18n$t("男性："), "${count} (${params[0].value[1]}", i18n$t("の"), "${Math.round(count/total*100, 4)}%)
          <br>", i18n$t("女性："), "${params[1].value[0]} (${params[0].value[1]}", i18n$t("の"), "${Math.round(params[1].value[0]/total*100, 4)}%)
        `)
      }
                                          ")),
        trigger = "axis",
        axisPointer = list(type = "shadow")
      ) %>%
      e_title(
        text = sprintf(
          i18n$t("男性：%s人 (%s%%)、女性：%s人 (%s%%)\n不明：%s人 (%s%%)、計：%s人"),
          maleCount, round(maleCount / totalCount * 100, 2), femaleCount, round(femaleCount / totalCount * 100, 2),
          unknownCount, round(unknownCount / totalCount * 100, 2), totalCount
        ),
        subtext = paste0(i18n$t("集計時間："), updateDay),
        textStyle = list(fontSize = 11),
        subtextStyle = list(fontSize = 9)
      ) %>%
      e_legend(top = "15%", right = "5%", selectedMode = F, orient = "vertical") %>%
      e_grid(bottom = "0%", right = "0%", left = "0px")
  }
})

output$ageGenderOption <- renderUI({
  region <- unique(GLOBAL_VALUE$signateDetail.ageGenderData$受診都道府県)

  tagList(
    pickerInput(
      inputId = "ageGenderOptionRegion",
      label = i18n$t("都道府県"),
      choices = c("全国", region)
    ),
    dateRangeInput(
      "ageGenderOptionDateRange",
      label = i18n$t("公表日"),
      start = min(GLOBAL_VALUE$signateDetail.ageGenderData$公表日, na.rm = T),
      end = Sys.Date(),
      min = min(GLOBAL_VALUE$signateDetail.ageGenderData$公表日, na.rm = T),
      max = Sys.Date(),
      separator = " - ",
      format = i18n$t("yyyy年m月d日"),
      language = i18n$translation_language
    )
  )
})
