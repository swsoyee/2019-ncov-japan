output$genderBar <- renderEcharts4r({
  dt <- GLOBAL_VALUE$signateDetail.ageGenderData

  dt[年代 == "", 年代 := "不明"] # TODO データ作成時処理すべき

  forPlot <- reshape(dt[, .(人数 = .N), by = c("年代", "性別")], idvar = "年代", timevar = "性別", direction = "wide")[order(年代)][, male_minus := -人数.男性]

  maleCount <- sum(forPlot$人数.男性, na.rm = T)
  femaleCount <- sum(forPlot$人数.女性, na.rm = T)
  unknownCount <- sum(forPlot$人数.不明, na.rm = T)
  totalCount <- maleCount + femaleCount + unknownCount

  forPlot %>%
    e_chart(年代) %>%
    e_bar(male_minus, stack = "1", name = "男性", itemStyle = list(color = darkNavy)) %>%
    e_bar(人数.女性, stack = "1", name = "女性", itemStyle = list(color = middleRed)) %>%
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
        return(`${params[0].value[1]}合計：${total}人 (総計の${Math.round(total/", totalCount, "*100, 4)}%)
          <hr>男性：${count}人 (${params[0].value[1]}の${Math.round(count/total*100, 4)}%)
          <br>女性：${params[1].value[0]}人 (${params[0].value[1]}の${Math.round(params[1].value[0]/total*100, 4)}%)
        `)
      }
                                          ")),
      trigger = "axis",
      axisPointer = list(type = "shadow")
    ) %>%
    e_title(
      text = paste0(
        "男性：", maleCount, "人 (", round(maleCount / totalCount * 100, 2),
        "%)、女性：", femaleCount, "人 (", round(femaleCount / totalCount * 100, 2),
        "%)\n不明：", unknownCount, "人 (", round(unknownCount / totalCount * 100, 2),
        "%)、計：", totalCount, "人"
      ),
      subtext = paste0("集計時間：", max(dt$公表日)),
      textStyle = list(fontSize = 11),
      subtextStyle = list(fontSize = 9)
    ) %>%
    e_legend(top = "15%", right = "5%", selectedMode = F, orient = "vertical") %>%
    e_grid(bottom = "0%", right = "0%", left = "0px")
})
