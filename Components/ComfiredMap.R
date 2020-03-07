# ====感染状況を日本標準マップで表示する画像を作成====
# Returns:
#   data.table: データセット
cumSumConfirmedByDateAndRegion <- reactive({
  dt <- data.frame(date = byDate$date)
  for(i in 2:ncol(byDate)) {
    dt[, i] = cumsum(byDate[, i, with = F])
  }
  dt <- reshape2::melt(dt, id.vars = 'date')
  data.table(dt)
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
  mapDt %>%
    group_by(date) %>% 
    e_charts(ja, timeline = T) %>%
    em_map("Japan") %>%
    e_map(count, map = "Japan",
          name = '感染確認数', roam = T,
          nameMap = nameMap,
          layoutSize = '50%',
          scaleLimit = list(min = 0.7, max = 5)) %>%
    e_visual_map(
      count,
      top = '5%',
      left = '0%',
      inRange = list(color = c('#EEEEEE', middleRed, darkRed)),
      type = 'piecewise',
      splitList = list(
        list(min = 50),
        list(min = 30, max = 50),
        list(min = 10, max = 30),
        list(min = 5, max = 10),
        list(min = 1, max = 5),
        list(value = 0)
      )
    ) %>% e_color(background = '#FFFFFF') %>%
    e_timeline_opts(left = '0%', right = '0%', symbol = 'diamond',
                    playInterval = 1000,
                    currentIndex = nrow(byDate) - 1) %>%
    e_tooltip(formatter = htmlwidgets::JS('
      function(params) {
        if(params.value) {
          return(params.name + "：" + params.value)
        } else {
          return("");
        }
      }
    '))
})

# ====事例マップ====
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


colSums(byDate[, 2:ncol(byDate)]) == 0