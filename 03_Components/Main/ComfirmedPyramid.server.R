output$genderBar <- renderEcharts4r({
  dt <- ConfirmedPyramidData(positiveDetail)
  maleCount <- sum(dt$count.男性)
  femaleCount <- sum(dt$count.女性)
  totalCount <- maleCount + femaleCount
  dt[, count.男性 := -count.男性]
  dt %>%
    e_chart(年齢) %>%
    e_bar(count.男性, stack = "1", name = "男性", itemStyle = list(color = darkNavy)) %>%
    e_bar(count.女性, stack = "1", name = "女性", itemStyle = list(color = middleRed)) %>%
    e_x_axis(axisTick = list(show = F)) %>%
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
        "%), 女性：", femaleCount, "人 (", round(femaleCount / totalCount * 100, 2),
        "%), 計：", totalCount, "人"
      ),
      textStyle = list(fontSize = 11),
      subtext = "性別、年齢不明および発表なしの感染者が含まれていませんのでご注意ください。",
      subtextStyle = list(fontSize = 9)
    ) %>%
    e_legend(top = "15%", right = "5%", selectedMode = F, orient = "vertical") %>%
    e_grid(bottom = "0%", right = "0%", left = "18%")
})