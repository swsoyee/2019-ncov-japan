# ====感染状況を日本標準マップで表示する画像を作成====
# Returns:
#   data.table: データセット
cumSumConfirmedByDateAndRegion <- reactive({
  dt <- data.frame(date = byDate$date)
  for(i in 2:ncol(byDate)) {
    dt[, i] = cumsum(byDate[, i, with = F])
  }
  dt <- reshape2::melt(dt, id.vars = 'date')
  dt <- data.table(dt)
  # input <- list(mapDateRange = c(as.Date('2020-03-01'), as.Date('2020-03-10')), showPopupOnMap = T) # TEST
  dt <- dt[date >= input$mapDateRange[1] & date <= input$mapDateRange[2]]
  dt
})

output$echartsMap <- renderEcharts4r({
  mapDt <- cumSumConfirmedByDateAndRegion()
  # mapDt <- data.table(dt) # TEST
  mapDt <- mapDt[!(variable %in% c('クルーズ船', 'チャーター便', '検疫職員'))]
  mapDt <- merge(x = mapDt, y = provinceCode, by.x = 'variable', by.y = 'name-ja', all = T)
  mapDt <- mapDt[, .(date, variable, `name-en`, value)]
  colnames(mapDt) <- c('date', 'ja', 'en', 'count')
  nameMap <- as.list(mapDt$ja)
  names(nameMap) <- mapDt$en
  
  newByDate <- rowSums(byDate[date >= input$mapDateRange[1] & date <= input$mapDateRange[2], 2:48])
  provinceCountByDate <- rowSums(
    byDate[date >= input$mapDateRange[1] & date <= input$mapDateRange[2], 2:48] != 0
    )
  dateSeq <- seq.Date(input$mapDateRange[1], input$mapDateRange[2], by = 'day')
  # 日別合計
  sumByDay <- cumsum(rowSums(byDate[, 2:ncol(byDate)]))
  sumByDay <- data.table(byDate[, 1], sumByDay)
  timeSeriesTitle <- lapply(seq_along(dateSeq), function(i) {
    # 各都道府県からの新規報告なし
    subText <- lang[[langCode]][119]
    if (provinceCountByDate[i] > 0) {
      subText <- paste0('発表がある', provinceCountByDate[i], '都道府県合計新規', newByDate[i], 
                        '人, 合計', sumByDay[date == dateSeq[i]]$sumByDay, '人')
    }
    return(
      list(
        text = dateSeq[i],
        subtext = subText
      )
    )
  })
  
  timeSeriesTitleSub <- lapply(seq_along(dateSeq), function(i) {
    columnName <- colnames(byDate)[49:51]
    item <- ''
    for(name in columnName) {
      diff <- byDate[date == dateSeq[i], name, with = F][[1]]
      if(diff > 0) {
        # 新規
        item <- paste(item, paste0(name, lang[[langCode]][118], diff), ' ')
      }
    }
    return(
      list(
        subtext = item,
        right = '5%',
        bottom = '10%'
      )
    )
  })
  
  timeSeriesTitleSource <- lapply(seq_along(dateSeq), function(i) {
    return(
      list(
        # マップのソースについて
        subtext = lang[[langCode]][116],
        # https://code.highcharts.com/mapdata/
        sublink = lang[[langCode]][117],
        subtextStyle = list(
          color = '#3c8dbc',
          fontSize = 10
        ),
        left = '0%',
        top = '8%'
      )
    )
  })
  
  # provinceCode <- fread(paste0(DATA_PATH, 'prefectures.csv')) # TEST
  if(input$showPopupOnMap) {
    provinceColnames <- colnames(byDate)[2:ncol(byDate)]
    provinceDiffPopup <- lapply(dateSeq, function(dateItem) {
      row <- as.matrix(byDate[date == dateItem])[1, 2:48]
      value <- row[row != "0"]
      name <- names(value)
      
      dateData <- list()
      for(i in seq_along(value)) {
        province <- provinceCode[`name-ja` == name[i]]
        dateData[[i]] <- list(
          coord = list(province$lng, province$lat), 
          value = paste0(name[i], '\n', value[i])
          )
      }
        list(
          data = dateData,
          itemStyle = list(color = darkYellow),
          label = list(fontSize = 8),
          symbol = 'pin',
          symbolSize = 40
        )
    })
  }
  # provinceColnames <- colnames(byDate)[2:4] # TEST
  # for(i in 1:length(provinceColnames)) {
  #   provinceDiffPopup[[i]] <- lapply(seq_along(byDate$date), function(j) {
  #     text <- ''
  #     subtext <- ''
  #     left <- 0
  #     bottom <- 0
  #     diff <- byDate[[i + 1]][j]
  #     if (diff > 0) {
  #       text <- provinceColnames[i]
  #       subtext <- diff
  #       element <- provinceCode[`name-ja` == provinceColnames[i]]
  #       left <- paste0((element$x), '%')
  #       bottom <- paste0((element$y), '%')
  #     }
  #     return(
  #       list(
  #         text = paste0(text, '+', subtext),
  #         textStyle = list(fontSize = 10),
  #         left = left,
  #         bottom = bottom
  #       )
  #     )
  #   })
  # }
  
  map <- mapDt %>%
    group_by(date) %>% 
    e_charts(ja, timeline = T) %>%
    em_map("Japan") %>%
    e_map(count, map = "Japan",
          name = '感染確認数',
          nameMap = nameMap,
          layoutSize = '50%',
          center = c(137.1374062, 36.8951298),
          zoom = 1.5,
          roam = 'move') %>%
    e_visual_map(
      count,
      top = '20%',
      left = '0%',
      inRange = list(color = c('#EEEEEE', middleRed, darkRed)),
      type = 'piecewise',
      splitList = list(
        list(min = 500),
        list(min = 100, max = 500),
        list(min = 50, max = 100),
        list(min = 10, max = 50),
        list(min = 1, max = 10),
        list(value = 0)
      )
    ) %>% e_color(background = '#FFFFFF') %>%
    e_timeline_opts(left = '0%', right = '0%', symbol = 'diamond',
                    playInterval = input$mapFrameSpeed * 1000, 
                    loop = input$replyMapLoop,
                    currentIndex = length(dateSeq) - 1) %>%
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
  
  # for (i in seq_along(provinceDiffPopup)) {
  #   map <- map %>%
  #     e_timeline_serie(
  #       title = provinceDiffPopup[[i]],
  #       index = i + 1
  #     )
  # }

  if(input$showPopupOnMap) {
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
  genderColor <- c('女' = 'red', '男' = 'blue', '不明' = 'grey')
  statusColor <- c('入院'= 'red', '退院' = 'green', '不明' = 'grey')
  map <- leaflet() %>% addTiles()
  for(i in 1:length(activity)) {
    xOffset <- 0
    yOffset <- 0
    lat <- 0
    lng <- 0
    id <- as.numeric(names(activity[i]))
    label <- paste('<b>患者番号：', id, 
                   '<span class="label label-info" style="float:right;">',
                   activity[[i]]$status[2],
                   '</span><br/>居住地：', detail[id, ]$residence, 
                   ' 性別：', detail[id, ]$gender, 
                   '</b>')
    popup <- paste0(label, '<hr/>')
    for(j in 1:length(activity[[i]]$process)) {
      popup <- paste(popup, 
                     paste('<li><span class="label label-primary">', 
                           as.Date(names(activity[[i]]$process[j]), format = '%Y%m%d'), 
                           '</span>',
                           activity[[i]]$process[[j]], '</li>')
                     )
    }
    popup <- paste(popup, '<hr/><b>', lang[[langCode]][68], '：', detail[id, ]$link, '</b>')
    for(j in 1:length(activity[[i]]$process)) {
      currentLat <- position[pos == activity[[i]]$activity[[j]]$pos]$lat
      currentLng <- position[pos == activity[[i]]$activity[[j]]$pos]$lng
      if(lat != currentLat && lng != currentLng) {
        if (lat != 0 && lng != 0) {
          map <- addFlows(map, 
                          color = genderColor[detail[id, ]$gender][[1]],
                          lat0 = lat + xOffset, lat1 = currentLat + xOffset,
                          lng0 = lng + yOffset, lng1 = currentLng + yOffset,
                          opacity = 0.8,
                          flow = 1,
                          maxThickness = 1,
                          time = as.Date(names(activity[[i]]$activity[j]), format = '%Y%m%d')
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
                                label = HTML(label))
      }
    }
  }
  map
})
