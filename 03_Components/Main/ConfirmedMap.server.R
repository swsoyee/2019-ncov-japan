# ====感染状況を日本標準マップで表示する画像を作成====
# Returns:
#   data.table: データセット
cumSumConfirmedByDateAndRegion <- reactive({
  dt <- mapData[date >= input$mapDateRange[1] & date <= input$mapDateRange[2]]
  dt
})

output$comfirmedMapWrapper <- renderUI({
  if (input$switchMapVersion == T) {
    echarts4rOutput("echartsSimpleMap", height = "550px")
  } else {
    echarts4rOutput("echartsMap", height = "550px")
  }
})

output$echartsMapPlaySetting <- renderUI({
  if(input$switchMapVersion == F) {
    tags$span(
      dropdownButton(
        tags$h4(icon("eye"), i18n$t("表示設定")),
        tags$hr(),
        materialSwitch(
          inputId = "showPopupOnMap",
          label = i18n$t("日次増加数のポップアップ"),
          status = "danger",
          value = T
        ),
        materialSwitch(
          inputId = "replyMapLoop",
          label = i18n$t("ループ再生"),
          status = "danger",
          value = T
        ),
        dateRangeInput(
          inputId = "mapDateRange",
          label = i18n$t("表示日付"),
          start = byDate$date[nrow(byDate) - 15],
          end = byDate$date[nrow(byDate)],
          min = byDate$date[1],
          max = byDate$date[nrow(byDate)],
          separator = " ~ ",
          language = "ja"
        ),
        sliderInput(
          inputId = "mapFrameSpeed",
          label = i18n$t("再生速度（秒/日）"),
          min = 0.5,
          max = 3,
          step = 0.1,
          value = 0.8
        ),
        circle = F,
        inline = T,
        status = "danger",
        icon = icon("gear"),
        size = "sm",
        width = "300px",
        right = T,
        tooltip = tooltipOptions(title = i18n$t("表示設定"), placement = "top")
      ),
      style = "float:right;"
    )
  }
})

output$selectMapBottomButton <- renderUI({
  if (input$switchMapVersion == T) {
    radioGroupButtons(
      inputId = "selectMapBottomButton",
      label = NULL,
      justified = T,
      choiceNames = c(
        paste(icon("creative-commons-sampling-plus"), i18n$t("現在")),
        paste(icon("syringe"), i18n$t("接種")),
        paste(icon("ambulance"), i18n$t("重症"))
      ),
      choiceValues = c("active", "vaccine_ratio", "severe"),
      status = "danger"
    )
  } else {
    tags$p()
  }
})

simpleMapDataset <- reactive({
  dt <- merge(
    x = mapData[, .SD[.N], by = ja],
    y = mapData[, .SD[.N - 1], by = ja],
    by = c("ja", "full_ja", "en", "lat", "lng", "regions"), no.dups = T, sort = F
  )
  dt[mhlwSummary[日付 == max(日付)], `:=`(
    total = count.x,
    severe = i.重症者,
    active = i.陽性者 - i.退院者 - ifelse(is.na(i.死亡者), 0, i.死亡者),
    diff = (count.x - count.y)
  ), on = c(ja = "都道府県名")]
  
  # join vaccine by prefecture dataset
  elderly <- vaccine_by_region[category == "elderly"][date == max(date)]
  medical <- vaccine_by_region[category == "medical"][date == max(date)]
  vaccine <- medical[elderly, .(
    prefecture = prefecture,
    first_medical = first,
    second_medical = second,
    first_elderly = i.first,
    second_elderly = i.second,
    date_medical = date,
    date_elderly = i.date
  ), on = c(code = "code")]
  dt <- dt[vaccine, on = c(full_ja = "prefecture")]
  
  # join population
  dt <- dt[prefecture_master[, .(都道府県, population = 人口)],
    on = c(full_ja = "都道府県")
  ]
  
  # vaccine ratio
  dt[, vaccine_ratio := round((second_medical + second_elderly) / population * 100, 2)]
  
  # set NA to 0
  setnafill(dt, fill = 0, cols = "severe")
  dt
})

output$echartsSimpleMap <- renderEcharts4r({
  dt <- simpleMapDataset()
  # 本日増加分
  todayTotalIncreaseNumber <- sum(dt$diff, na.rm = T)
  subText <- i18n$t("各都道府県からの新規報告なし")
  if (todayTotalIncreaseNumber > 0) {
    subText <- paste0(
      sprintf(
        i18n$t("発表がある%s都道府県合計新規%s人, 合計%s人\n\n"),
        sum(dt$diff > 0), 
        prettyNum(todayTotalIncreaseNumber, big.mark = ","),
        prettyNum(sum(dt$count.x, na.rm = T), big.mark = ",")
      ),
      i18n$t("※こちらの合計値には空港検疫、チャーター便、\n　クルーズ関連の事例などは含まれていない。")
    )
  }
  
  dt[, translatedRegionName := convertRegionName(full_ja, languageSetting)]
  
  if (input$selectMapBottomButton %in% c("vaccine_ratio")) {
    subText <- sprintf(
      i18n$t("データ更新日：\n\n医療従事者等（%s）\n高齢者等（%s）"),
      as.Date(as.character(unique(dt$date_medical)), format = "%Y%m%d"),
      as.Date(as.character(unique(dt$date_elderly)), format = "%Y%m%d")
    )
    color_in_range <- c("#DADADA", "#3fcc8d", middleGreen, darkGreen, superDarkGreen, superDarkGreen2)
    split_list <- list(
      list(min = 45.0, label = "> 45.0 %"),
      list(min = 40.0, max = 45.0, label = "40.0 % ~ 45.0 %"),
      list(min = 35.0, max = 40.0, label = "35.0 % ~ 40.0 %"),
      list(min = 30.0, max = 35.0, label = "30.0 % ~ 35.0 %"),
      list(min = 0.0, max = 30.0, label = "0.0 % ~ 30.0 %"),
      list(value = 0)
    )
    formatter <- htmlwidgets::JS(paste0(
      "function(params) {
        if(params.value) {
          return(`<b>${params.name}</b><br>", i18n$t("２回目接種済率："), "${params.value} %`)
        } else {
          return('');
        }
      }
    "))
    title_text <- i18n$t("２回目接種済マップ")
  } else {
    color_in_range <- c("#DADADA", "#FFCEAB", "#FF9D57", "#FF781E", "#EA5432", "#C02B11", "#8C0B00", "#000000")
    split_list <- list(
      list(min = 3000, label = "> 3,000"),
      list(min = 1000, max = 3000, label = "1,000 - 3,000"),
      list(min = 500, max = 1000, label = "500 - 1,000"),
      list(min = 100, max = 500),
      list(min = 50, max = 100),
      list(min = 10, max = 50),
      list(min = 1, max = 10),
      list(value = 0)
    )
    formatter <- htmlwidgets::JS(paste0(
      "function(params) {
                if(params.value) {
                  return(`${params.name}<br>",
      switch(input$selectMapBottomButton,
        active = i18n$t("現在感染者数："),
        total = i18n$t("累積感染者数："),
        severe = i18n$t("現在重症者数：")
      ), "${params.value}`)
                } else {
                  return('');
                }
              }
            "
    ))
    title_text <- i18n$t("リアルタイム感染者数マップ")
  }

  map <- dt %>%
    e_charts(translatedRegionName) %>%
    e_map_register("japan", japanMap) %>%
    e_map_(input$selectMapBottomButton,
      map = "japan",
      name = "感染確認数",
      nameMap = useMapNameMap(languageSetting),
      layoutSize = "50%",
      center = c(137.1374062, 36.8951298),
      zoom = 1.5,
      itemStyle = list(
        borderWidth = 0.2,
        borderColor = "white"
      ),
      emphasis = list(
        label = list(
          fontSize = 8
        )
      ),
      roam = "move"
    ) %>%
    e_visual_map_(
      input$selectMapBottomButton,
      top = "25%",
      left = "0%",
      inRange = list(color = color_in_range),
      type = "piecewise",
      splitList = split_list
    ) %>%
    e_color(background = "#FFFFFF") %>%
    e_mark_point(serie = dt[diff > 0]$en) %>%
    e_tooltip(formatter = formatter) %>%
    e_title(
      text = title_text,
      subtext = subText
    )

  # 本日増加分をプロット
  if (input$selectMapBottomButton %in% c("active")) {
    newToday <- dt[diff > 0]
    for (i in 1:nrow(newToday)) {
      map <- map %>%
        e_mark_point(
          data = list(
            name = newToday[i]$ja,
            coord = c(newToday[i]$lng, newToday[i]$lat),
            symbolSize = c(7, newToday[i]$diff / 2)
          ),
          symbol = "triangle",
          symbolOffset = c(0, "-50%"),
          itemStyle = list(
            color = "#520e05",
            shadowColor = "white",
            shadowBlur = 0,
            opacity = 0.75
          )
        )
    }
  }
  map
})

output$echartsMap <- renderEcharts4r({
  mapDt <- cumSumConfirmedByDateAndRegion()
  # mapDt <- mapData # TEST
  newByDate <- rowSums(byDate[date >= input$mapDateRange[1] & date <= input$mapDateRange[2], 2:48])
  provinceCountByDate <- rowSums(
    byDate[date >= input$mapDateRange[1] & date <= input$mapDateRange[2], 2:48] != 0
  )
  dateSeq <- seq.Date(input$mapDateRange[1], input$mapDateRange[2], by = "day")
  # 日別合計
  sumByDay <- cumsum(rowSums(byDate[, 2:ncol(byDate)]))
  sumByDay <- data.table(byDate[, 1], sumByDay)
  timeSeriesTitle <- lapply(seq_along(dateSeq), function(i) {
    subText <- i18n$t("各都道府県からの新規報告なし")
    if (provinceCountByDate[i] > 0) {
      subText <- sprintf(i18n$t("発表がある%s都道府県合計新規%s人, 合計%s人\n\n"),
        provinceCountByDate[i], newByDate[i], sumByDay[date == dateSeq[i]]$sumByDay
      )
    }
    return(
      list(
        text = dateSeq[i],
        subtext = subText
      )
    )
  })

  timeSeriesTitleSub <- lapply(seq_along(dateSeq), function(i) {
    columnName <- colnames(byDate)[49:ncol(byDate)]
    item <- ""
    for (name in columnName) {
      diff <- byDate[date == dateSeq[i], name, with = F][[1]]
      if (diff > 0) {
        # 新規
        item <- paste(item, paste0(name, i18n$t("新規"), diff), " ")
      }
    }
    return(
      list(
        subtext = item,
        right = "5%",
        bottom = "10%"
      )
    )
  })

  timeSeriesTitleSource <- lapply(seq_along(dateSeq), function(i) {
    return(
      list(
        subtext = i18n$t("マップのソースについて"),
        sublink = "https://github.com/dataofjapan/land",
        subtextStyle = list(
          color = "#3c8dbc",
          fontSize = 10
        ),
        left = "0%",
        top = "8%"
      )
    )
  })

  mapDt[, translatedRegionName := convertRegionName(full_ja, languageSetting)]
  # provinceCode <- fread(paste0(DATA_PATH, 'prefectures.csv')) # TEST
  if (input$showPopupOnMap) {
    provinceColnames <- colnames(byDate)[2:ncol(byDate)]
    provinceDiffPopup <- lapply(dateSeq, function(dateItem) {
      row <- as.matrix(byDate[date == dateItem])[1, 2:48]
      value <- row[row != "0"]
      name <- names(value)

      dateData <- list()
      for (i in seq_along(value)) {
        province <- provinceCode[`name-ja` == name[i]]
        dateData[[i]] <- list(
          coord = list(province$lng, province$lat),
          value = paste0(name[i], "\n", value[i])
        )
      }
      list(
        data = dateData,
        itemStyle = list(color = darkYellow),
        label = list(fontSize = 8),
        symbol = "pin",
        symbolSize = 40
      )
    })
  }
  
  map <- mapDt %>%
    group_by(date) %>%
    e_charts(translatedRegionName, timeline = T) %>%
    e_map_register("japan", japanMap) %>%
    e_map(count,
      map = "japan",
      name = "感染確認数",
      nameMap = useMapNameMap(languageSetting),
      layoutSize = "50%",
      center = c(137.1374062, 36.8951298),
      zoom = 1.5,
      itemStyle = list(
        borderWidth = 0.2,
        borderColor = "white"
      ),
      emphasis = list(
        label = list(
          fontSize = 8
        )
      ),
      roam = "move"
    ) %>%
    e_visual_map(
      count,
      top = "20%",
      left = "0%",
      inRange = list(color = c("#DADADA", "#FFCEAB", "#FF9D57", "#FF781E", "#EA5432", "#C02B11", "#8C0B00")),
      type = "piecewise",
      splitList = list(
        list(min = 1000),
        list(min = 500, max = 1000),
        list(min = 100, max = 500),
        list(min = 50, max = 100),
        list(min = 10, max = 50),
        list(min = 1, max = 10),
        list(value = 0)
      )
    ) %>%
    e_color(background = "#FFFFFF") %>%
    e_timeline_opts(
      left = "0%", right = "0%", symbol = "diamond",
      playInterval = input$mapFrameSpeed * 1000,
      loop = input$replyMapLoop,
      currentIndex = length(dateSeq) - 1
    ) %>%
    e_tooltip(formatter = htmlwidgets::JS('
      function(params) {
        if(params.value) {
          return(params.name + "：" + params.value)
        } else {
          return("");
        }
      }
    ')) %>%
    e_timeline_serie(
      title = timeSeriesTitle
    ) %>%
    e_timeline_serie(
      title = timeSeriesTitleSub,
      index = 2
    ) %>%
    e_timeline_serie(
      title = timeSeriesTitleSource,
      index = 3
    )

  if (input$showPopupOnMap) {
    map %>%
      e_timeline_on_serie(
        markPoint = provinceDiffPopup,
        serie_index = 1
      )
  } else {
    map
  }
})

# ====事例マップ==== # TODO ホームページの内容ではないから別のところに移動
output$caseMap <- renderLeaflet({
  defaultRadius <- 8
  genderColor <- c("女" = "red", "男" = "blue", "不明" = "grey")
  statusColor <- c("入院" = "red", "退院" = "green", "不明" = "grey")
  map <- leaflet() %>% addTiles()
  for (i in 1:length(activity)) {
    xOffset <- 0
    yOffset <- 0
    lat <- 0
    lng <- 0
    id <- as.numeric(names(activity[i]))
    label <- paste(
      "<b>患者番号：", id,
      '<span class="label label-info" style="float:right;">',
      activity[[i]]$status[2],
      "</span><br/>居住地：", detail[id, ]$residence,
      " 性別：", detail[id, ]$gender,
      "</b>"
    )
    popup <- paste0(label, "<hr/>")
    for (j in 1:length(activity[[i]]$process)) {
      popup <- paste(
        popup,
        paste(
          '<li><span class="label label-primary">',
          as.Date(names(activity[[i]]$process[j]), format = "%Y%m%d"),
          "</span>",
          activity[[i]]$process[[j]], "</li>"
        )
      )
    }
    popup <- paste(popup, "<hr/><b>", lang[[langCode]][68], "：", detail[id, ]$link, "</b>")
    for (j in 1:length(activity[[i]]$process)) {
      currentLat <- position[pos == activity[[i]]$activity[[j]]$pos]$lat
      currentLng <- position[pos == activity[[i]]$activity[[j]]$pos]$lng
      if (lat != currentLat && lng != currentLng) {
        if (lat != 0 && lng != 0) {
          map <- addFlows(map,
            color = genderColor[detail[id, ]$gender][[1]],
            lat0 = lat + xOffset, lat1 = currentLat + xOffset,
            lng0 = lng + yOffset, lng1 = currentLng + yOffset,
            opacity = 0.8,
            flow = 1,
            maxThickness = 1,
            time = as.Date(names(activity[[i]]$activity[j]), format = "%Y%m%d")
          )
        }
        lat <- currentLat
        lng <- currentLng
        radius <- defaultRadius
        if (!is.na(position[pos == activity[[i]]$activity[[j]]$pos]$radius)) {
          radius <- position[pos == activity[[i]]$activity[[j]]$pos]$radius
        }
        map <- addCircleMarkers(map,
          lat = currentLat + xOffset,
          lng = currentLng + yOffset,
          radius = radius,
          color = genderColor[detail[id, ]$gender][[1]],
          fillColor = statusColor[activity[[i]]$status][[1]],
          weight = 1, opacity = 1,
          popup = HTML(popup),
          label = HTML(label)
        )
      }
    }
  }
  map
})