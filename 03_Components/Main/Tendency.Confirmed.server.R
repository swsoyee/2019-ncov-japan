# ====UI====
output$tendencyConfirmedRegionPicker <- renderUI({
  if (input$selectTendencyConfirmedMode == "一般") {
    return(
      pickerInput(
        inputId = "regionPicker",
        label = i18n$t("地域選択"),
        choices = regionName,
        selected = defaultSelectedRegionName,
        options = list(
          `actions-box` = TRUE,
          size = 10,
          `deselect-all-text` = i18n$t("クリア"),
          `select-all-text` = i18n$t("全部"),
          `selected-text-format` = i18n$t("三件以上選択されました"),
          `live-search` = T
        ),
        multiple = T,
        width = "100%"
      )
    )
  } else if (input$selectTendencyConfirmedMode == "両対数") {
    return(tagList(
      column(
        width = 8,
        sliderInput(
          inputId = "twoSideNSpan",
          label = i18n$t("時間間隔設定"),
          min = 1,
          max = 10,
          value = 7,
          ticks = F,
          step = 1,
          post = i18n$t("日")
        )
      ),
      column(
        width = 4,
        tags$b(i18n$t("軸設定")),
        switchInput(
          inputId = "twoSideXType",
          label = i18n$t("横軸"),
          offStatus = "danger",
          offLabel = i18n$t("一般"),
          onStatus = "danger",
          onLabel = i18n$t("対数"),
          value = T,
          size = "small",
          width = "200px",
          labelWidth = "150px",
          handleWidth = "150px",
          inline = T
        )
      )
    ))
  }
})

# ====DATA====
confirmedDataByDate <- reactive({
  dt <- data.table(byDate)
  dt$都道府県 <- rowSums(byDate[, c(2:48)])
  if (!is.null(input$regionPicker)) {
    dt <- dt[, c("date", input$regionPicker), with = F]
    # dt <- dt[, c('date', '都道府県', 'チャーター便', '検疫職員')] # TEST
    dt$total <- cumsum(rowSums(dt[, 2:ncol(dt)]))
    dt[, difference := total - shift(total)]
    setnafill(dt, fill = 0)
    dt
  } else {
    dt[, 1, with = F] # 日付のカラムだけを返す
  }
})

# ====新規感染者推移図（片対数）====
output$oneSideLogConfirmed <- renderEcharts4r({
  dt <- mapData[count > 10]
  dt[, index := 1:.N, by = ja]

  prefOver10 <- unique(dt[count > 10]$ja)
  dt <- dt[ja %in% prefOver10]

  regionCount <- dt[, .I[which.max(count)], by = ja]
  orderRegion <- dt[regionCount$V1][order(-count)]$ja
  mostNregion <- head(orderRegion, n = 7)
  regionName <- unique(dt$ja)
  unselected <- regionName[!(regionName %in% mostNregion)]
  unselected <- setNames(
    as.list(rep(F, length(unselected))),
    sapply(unselected, i18n$t)
  )
  dt[, ja := sapply(ja, i18n$t)]
  dt[order(match(ja, orderRegion))] %>%
    group_by(ja) %>%
    e_chart(index) %>%
    e_line(count, symbol = "circle", smooth = T, symbolSize = 1) %>%
    e_y_axis(
      splitLine = list(lineStyle = list(opacity = 0.2)),
      name = i18n$t("感染者数"),
      type = "log",
      nameTextStyle = list(padding = c(0, 0, 0, 40)),
      axisLabel = list(inside = T),
      axisTick = list(show = F),
      nameGap = 10
    ) %>%
    e_x_axis(
      splitLine = list(lineStyle = list(opacity = 0.2)),
      name = i18n$t("感染者が10人以上から経過した日数"),
      nameLocation = "center",
      nameGap = 25
    ) %>%
    e_tooltip(trigger = "axis") %>%
    e_grid(
      bottom = "10%",
      right = "15%",
      left = "3%"
    ) %>%
    e_title(text = i18n$t("累積感染者数推移")) %>%
    e_legend(
      type = "scroll",
      orient = "vertical",
      right = "0%",
      top = "10%",
      selected = unselected,
      selector = list(
        list(type = "all", title = i18n$t("全")),
        list(type = "inverse", title = i18n$t("逆"))
      )
    ) %>%
    e_mark_line(data = list(
      list(
        coord = c(0, 10),
        symbol = "none"
      ),
      list(
        coord = c(9.5, 10 * 2^9.5),
        symbol = "none",
        name = i18n$t("１日２倍")
      )
    )) %>%
    e_mark_line(data = list(
      list(
        coord = c(0, 10),
        symbol = "none"
      ),
      list(
        coord = c(28.5, 10 * 2^9.5),
        symbol = "none",
        name = i18n$t("３日２倍")
      )
    )) %>%
    e_mark_line(data = list(
      list(
        coord = c(0, 10),
        symbol = "none"
      ),
      list(
        coord = c(56, 10 * 2^8),
        symbol = "none",
        name = i18n$t("１週間２倍")
      )
    ))
})

# ====新規感染者推移図（一般）====
output$confirmedLine <- renderEcharts4r({
  dt <- confirmedDataByDate()

  if (ncol(dt) > 1) {
    dt[, `:=`(
      ma_3 = round(frollmean(difference, n = 3, fill = 0), 2),
      ma_5 = round(frollmean(difference, n = 5, fill = 0), 2),
      ma_7 = round(frollmean(difference, n = 7, fill = 0), 2)
    )]
    # Remove today
    dt[nrow(dt), `:=`(ma_3 = NA, ma_5 = NA, ma_7 = NA)]

    dt %>%
      e_charts(date) %>%
      e_bar(
        total,
        name = i18n$t("累積"),
        itemStyle = list(normal = list(color = lightYellow))
      ) %>%
      e_bar(
        difference,
        name = i18n$t("新規"),
        # y_index = 1,
        z = 2, barGap = "-100%",
        itemStyle = list(normal = list(color = lightRed))
      ) %>%
      e_line(ma_3, name = i18n$t("３日移動平均"), y_index = 1,
             symbol = "none", smooth = T, itemStyle = list(color = darkRed)) %>%
      e_line(ma_5, name = i18n$t("５日移動平均"), y_index = 1,
             symbol = "none", smooth = T, itemStyle = list(color = darkYellow)) %>%
      e_line(ma_7, name = i18n$t("週間移動平均"), y_index = 1,
             symbol = "none", smooth = T, itemStyle = list(color = darkNavy)) %>%
      e_grid(
        left = "3%",
        right = "15%",
        top = "18%"
      ) %>%
      e_x_axis(
        splitLine = list(
          lineStyle = list(
            opacity = 0.2
          )
        ),
        axisLabel = list(
          formatter = "{yyyy}-{MM}-{dd}"
        )
      ) %>%
      e_y_axis(
        name = i18n$t("陽性者数"),
        nameGap = 10,
        nameTextStyle = list(padding = c(0, 0, 0, 50)),
        splitLine = list(lineStyle = list(opacity = 0.2)),
        z = 999,
        axisLabel = list(inside = TRUE),
        axisTick = list(show = FALSE)
      ) %>%
      e_y_axis(
        name = i18n$t("移動平均新規数"),
        nameGap = 10,
        splitLine = list(show = FALSE),
        z = 999,
        index = 1,
        axisTick = list(show = FALSE)
      ) %>%
      e_title(
        text = i18n$t("日次新規・累積陽性者の推移"),
        subtext = i18n$t("データソース：NewsDigest"),
        sublink = "https://newsdigest.jp/pages/coronavirus/"
      ) %>%
      e_legend_unselect(
        name = i18n$t("累積")
      ) %>%
      e_legend_unselect(
        name = i18n$t("５日移動平均")
      ) %>%
      e_legend_unselect(
        name = i18n$t("３日移動平均")
      ) %>%
      e_legend(
        type = "scroll",
        orient = "vertical",
        left = "18%",
        top = "15%",
        right = "15%"
      ) %>%
      e_tooltip(trigger = "axis") %>%
      e_datazoom(
        minValueSpan = 604800000, #3600 * 24 * 1000 * 7,
        startValue = max(dt$date, na.rm = T) - 28
      )
  }
})

output$confirmedLineWrapper <- renderUI({
  if (input$selectTendencyConfirmedMode == "一般") {
    if (is.null(input$regionPicker)) {
      tags$p(i18n$t("未選択です。地域を選択してください。"))
    } else {
      echarts4rOutput("confirmedLine")
    }
  } else if (input$selectTendencyConfirmedMode == "片対数") {
    echarts4rOutput("oneSideLogConfirmed")
  } else if (input$selectTendencyConfirmedMode == "両対数") {
    echarts4rOutput("twoSideLogConfirmed")
  }
})


output$confirmedCalendar <- renderEcharts4r({
  dt <- confirmedDataByDate()
  if (length(confirmedDataByDate()) > 1) {
    maxValue <- max(dt$difference)
    dt %>%
      e_charts(date) %>%
      e_calendar(
        range = input$confirmCalendarDateRange,
        top = 25,
        left = 25,
        cellSize = 15,
        splitLine = list(show = F),
        itemStyle = list(borderWidth = 2, borderColor = "#FFFFFF"),
        dayLabel = list(nameMap = switch(
          languageSetting,
          "ja" = c("日", "月", "火", "水", "木", "金", "土"),
          "cn" = "cn",
          "en" = "en"
        )),
        monthLabel = list(nameMap = ifelse(languageSetting != "en", "cn", "en"))
      ) %>%
      e_heatmap(difference, coord_system = "calendar") %>%
      e_legend(show = T) %>%
      e_visual_map(
        top = "2%",
        show = F,
        max = maxValue,
        inRange = list(color = c("#FFFFFF", middleRed, darkRed)),
        # scale colors
      ) %>%
      e_tooltip(
        formatter = htmlwidgets::JS(sprintf(
          "
        function(params) {
          return(`${params.value[0]}<br>%s${params.value[1]}`)
        }
      ", paste0(i18n$t("新規"), " ")
        ))
      )
  } else {
    return()
  }
})

output$twoSideLogConfirmed <- renderEcharts4r({
  dt <- mapData[, diff := count - shift(count), by = ja]
  dt[is.na(dt$diff)]$diff <- 0
  # 本日のデータを除外
  dt <- dt[date != max(dt$date)]
  setorder(dt, ja, -date)

  regionCount <- dt[, .I[which.max(count)], by = ja]
  orderRegion <- dt[regionCount$V1][order(-count)]$ja
  mostNregion <- head(orderRegion, n = 7)
  regionName <- unique(dt$ja)
  unselected <- regionName[!(regionName %in% mostNregion)]
  unselected <- setNames(
    as.list(rep(F, length(unselected))),
    sapply(unselected, i18n$t)
  )
  # orderLegendList <-
  #   setNames(as.list(orderRegion), rep("name", length(orderRegion)))

  NDay <- input$twoSideNSpan
  # NDay <- 5 # TEST
  dt[, index := rep((.N %/% NDay):1, each = NDay, len = .N), by = ja]
  dt <- dt[, head(.SD, .N - .N %% NDay), by = "ja"]
  dt[, spanDiff := sum(diff), by = .(ja, index)]
  dt <- unique(dt[, .(ja, index, spanDiff)])
  dt <- dt[order(ja, index)][, spanCount := cumsum(spanDiff), by = .(ja)]
  dt[, ja := sapply(ja, i18n$t)]
  dt[spanDiff != 0][order(match(ja, orderRegion))] %>%
    group_by(ja) %>%
    # dt[ja =='東京' & diff != 0] %>% #TEST
    e_chart(spanCount) %>%
    e_line(spanDiff, symbol = "circle", smooth = T, symbolSize = 1) %>%
    e_legend(
      type = "scroll",
      orient = "vertical",
      right = "0%",
      top = "10%",
      selected = unselected,
      selector = list(
        list(type = "all", title = i18n$t("全")),
        list(type = "inverse", title = i18n$t("逆"))
      )
    ) %>%
    e_y_axis(
      splitLine = list(lineStyle = list(opacity = 0.2)),
      name = i18n$t("新規"),
      type = "log",
      nameTextStyle = list(padding = c(0, 0, 0, 40)),
      axisLabel = list(inside = T),
      axisTick = list(show = F),
      nameGap = 10
    ) %>%
    e_x_axis(
      splitLine = list(lineStyle = list(opacity = 0.2)),
      type = ifelse(input$twoSideXType, "log", "value"),
      # type = "log", # TEST
      name = i18n$t("累積"),
      nameLocation = "center",
      nameGap = 25
    ) %>%
    e_tooltip(
      trigger = "axis",
      formatter = htmlwidgets::JS(paste0(
        '
    function(params) {
      label = params.map(param => {
        return(`<b style="color:${param.color};background-color:white;border-radius:3px;padding:1px 5px 1px 5px;">${param.seriesName}</b>：', 
        i18n$t("累積感染者数："),
        '${param.value[0]}', i18n$t("名"), " ", i18n$t("期間中新規"), '${param.value[1]}', i18n$t("名"), '`)
      }).join("<br>")
      return(label)
    }
  '
      ))
    ) %>%
    e_mark_point(data = list(
      type = "max",
      symbol = "diamond",
      symbolSize = 8,
      valueDim = "x",
      label = list(show = F, offset = c(0, 15)) # TODO 都道府県の名前を表示
    )) %>%
    e_grid(
      bottom = "10%",
      right = "15%",
      left = "3%"
    ) %>%
    e_title(text = i18n$t("各都道府県の累積・新規感染者数推移"))
})
