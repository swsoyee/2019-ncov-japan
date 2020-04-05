observeEvent(input$sideBarTab, {
  if (input$sideBarTab == 'hokkaido' && is.null(GLOBAL_VALUE$hokkaidoData)) {
    # GLOBAL_VALUE <- list(hokkaidoData = NULL, hokkaidoPatients = NULL) # TEST
    GLOBAL_VALUE$hokkaidoData <- fread(file = paste0(DATA_PATH, 'Pref/Hokkaido/covid19_data.csv'))
    GLOBAL_VALUE$hokkaidoDataUpdateTime <- file.info(paste0(DATA_PATH, 'Pref/Hokkaido/covid19_data.csv'))$mtime
    GLOBAL_VALUE$hokkaidoData$date <- as.Date(paste0(GLOBAL_VALUE$hokkaidoData$年, '/', GLOBAL_VALUE$hokkaidoData$月, '/', GLOBAL_VALUE$hokkaidoData$日))
    # data <- GLOBAL_VALUE$hokkaidoData # TEST
    GLOBAL_VALUE$hokkaidoPatients <- fread(file = paste0(DATA_PATH, 'Pref/Hokkaido/patients.csv'))
    data <- GLOBAL_VALUE$hokkaidoPatients # TEST
  }
})

hokkaidoData <- reactive({
  return(list(data = GLOBAL_VALUE$hokkaidoData, 
              dataUpdateTime = GLOBAL_VALUE$hokkaidoDataUpdateTime,
              patient = GLOBAL_VALUE$hokkaidoPatients))
})

createValueBox <- function(value, subValue, subtitle, sparkline, icon, color, width = 6) {
  return(
    valueBox(
      value = tagList(value, 
                      tags$small(
                        paste0('| ' , subValue),
                        style = 'color:white;font-size:16px;margin-top:10px;margin-right:10px;opacity:0.8'
                        )
      ),
      subtitle = tagList(sparklineOutput(sparkline), 
                         tags$span(subtitle, style = 'float:right')), 
      icon = icon(icon), 
      color = color,
      width = width
    )
  )
}

output$hokkaidoPCRValue <- renderUI({
  data <- hokkaidoData()$data
  precentage <- paste0(round(tail(data$陽性累計, n = 1) / tail(data$検査累計, n = 1) * 100, 2), '%')
  createValueBox(value = tail(data$検査累計, n = 1),
                 subValue = paste0('陽性率：', precentage), 
                 sparkline = 'hokkaidoFormalPCRSparkline', 
                 subtitle = '累計検査数', 
                 icon = 'vials',
                 color = 'yellow',
  )
})

output$hokkaidoConfirmedValue <- renderUI({
  data <- hokkaidoData()$data
  createValueBox(value = tail(data$陽性累計, n = 1),
                 subValue = paste0('速報：', sum(byDate[, 2, with = T], na.rm = T)), 
                 sparkline = 'hokkaidoFormalConfirmedSparkline', 
                 subtitle = '累計陽性者数', 
                 icon = 'procedures',
                 color = 'red'
                 )
})

output$hokkaidoDischargeValue <- renderUI({
  data <- hokkaidoData()$data
  precentage <- paste0(round(tail(data$治療終了累計, n = 1) / tail(data$陽性累計, n = 1) * 100, 2), '%')
  createValueBox(value = tail(data$治療終了累計, n = 1),
                 subValue = precentage, 
                 sparkline = 'hokkaidoFormalDischargeSparkline', 
                 subtitle = '累計治療終了数', 
                 icon = 'user-shield',
                 color = 'green'
  )
})

output$hokkaidoDeathValue <- renderUI({
  data <- hokkaidoData()$data
  precentage <- paste0(round(tail(data$死亡累計, n = 1) / tail(data$陽性累計, n = 1) * 100, 2), '%')
  createValueBox(value = tail(data$死亡累計, n = 1),
                 subValue = precentage, 
                 sparkline = 'hokkaidoFormalDeathSparkline', 
                 subtitle = '累計死亡者数', 
                 icon = 'bible',
                 color = 'navy'
  )
})

createSparklineInValueBox <- function(data, column, barColor = 'white', negBarColor = 'white', length = 30) {
  if (!is.null(data) && nrow(data) > 0) {
    sparkline(data[[column]][(nrow(data) - length):nrow(data)], 
              type = 'bar', 
              barColor = barColor, 
              negBarColor = negBarColor, 
              width = 160)
  }
}

output$hokkaidoFormalConfirmedSparkline <- renderSparkline({
  createSparklineInValueBox(hokkaidoData()$data, '日陽性数')
})

output$hokkaidoFormalPCRSparkline <- renderSparkline({
  createSparklineInValueBox(hokkaidoData()$data, '日検査数')
})

output$hokkaidoFormalDischargeSparkline <- renderSparkline({
  createSparklineInValueBox(hokkaidoData()$data, '日治療終了数')
})

output$hokkaidoFormalDeathSparkline <- renderSparkline({
  createSparklineInValueBox(hokkaidoData()$data, '日死亡数')
})

output$hokkaidoSummaryGraph <- renderEcharts4r({
  
  data <- hokkaidoData()$data
  dataUpdateTime <- hokkaidoData()$dataUpdateTime
  
  latestUpdateDuration <- difftime(Sys.time(), dataUpdateTime)
  LATEST_UPDATE <- paste0(
    round(latestUpdateDuration[[1]], 0), 
    convertUnit2Ja(latestUpdateDuration)
  )
  
  data %>%
    e_chart(date) %>%
    e_line(陽性累計, color = lightRed) %>%
    e_line(患者累計, color = middleYellow) %>%
    e_line(死亡累計, color = darkNavy) %>%
    e_bar(日陽性数, color = darkRed, name = '日次陽性者数', y_index = 1) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = 3 * max(data$日陽性数, na.rm = T)) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_grid(left = '8%', right = '5%', bottom = '10%') %>%
    e_legend(orient = 'vertical', top = '15%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = '北海道の発生状況（その一）', subtext = paste('更新時刻：', LATEST_UPDATE))
})

output$hokkaidoStackGraph <- renderEcharts4r({
  
  data <- hokkaidoData()$data
  dataUpdateTime <- hokkaidoData()$dataUpdateTime
  
  latestUpdateDuration <- difftime(Sys.time(), dataUpdateTime)
  LATEST_UPDATE <- paste0(
    round(latestUpdateDuration[[1]], 0), 
    convertUnit2Ja(latestUpdateDuration)
  )
  
  data %>%
    e_chart(date) %>%
    e_bar(検査累計, color = middleYellow, stack = 1) %>%
    e_bar(陽性累計, color = middleRed, stack = 2, z = 2, barGap = '-100%') %>%
    e_bar(治療終了累計, color = middleGreen, stack = 3) %>%
    e_bar(死亡累計, color = darkNavy, stack = 3) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_grid(left = '8%', right = '5%', bottom = '10%') %>%
    e_legend(orient = 'vertical', top = '15%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = '北海道の発生状況（その二）', subtext = paste('更新時刻：', LATEST_UPDATE))
})

output$hokkaidoConfirmedMap <- renderLeaflet({
  data <- hokkaidoData()$patient
  
  # getColor <- function(value) {
  #   sapply(value, function(gender) {
  #     if(gender == '男性') {
  #       return('lightblue')
  #     } else if(gender == '女性') {
  #       return('red')
  #     } else {
  #       return('beige')
  #     } })
  # }
  # 
  # icons <- awesomeIcons(
  #   icon = 'home',
  #   iconColor = 'black',
  #   library = 'fa',
  #   markerColor = unname(getColor(data$性別.x))
  # )
  # 
  # 
  # testDt <- data # TEST

  leaflet(data) %>% 
    addTiles() %>% 
    addCircleMarkers(lng = ~居住地経度, 
                      lat = ~居住地緯度, 
                      layerId = ~No,
                      label = mapply(function(No, age, gender) {
                        HTML(sprintf('<b>%s番：</b>%s %s', No, age, gender))},
                        data$No, data$年代.x, data$性別.x, SIMPLIFY = F),
                      # icon = icons,
                      clusterOptions = markerClusterOptions()
    ) %>%
    setView(lng = provinceCode[id == 1]$lng,
            lat = provinceCode[id == 1]$lat,
            zoom = 7) %>%
    # addEasyButton(easyButton(
    #   icon = icon('crosshairs'), title = '自分の位置',
    #   onClick = JS("function(btn, map){ map.locate({setView: true}); }"))) %>%
    addMiniMap(
      tiles = providers$Esri.WorldStreetMap,
      toggleDisplay = TRUE)
})

hokkaidoProfile <- reactive({
  id <- input$hokkaidoConfirmedMap_marker_click$id
  data <- hokkaidoData()$patient
  if (!is.null(data) && !is.null(id)) {
    return(data[No == id])
  } else {
    return(NULL)
  }
})

output$hokkaidoProfile <- renderUI({
  profile <- hokkaidoProfile()
  if(!is.null(profile)) {
    # 外部確認リンク
    outerLinks <- strsplit(profile$情報源, split = ';')[[1]]
    outerLinkTags <- tagList(lapply(1:length(outerLinks), function(i){
      tags$a(href = outerLinks[i], icon('link'), '外部リンク', style = 'float: right!important;')
    }))
    # 行動歴
    activityLog <- ifelse(profile$行動歴 == '', '詳細なし', gsub('\n', '<br>', profile$行動歴))

    boxPlus(
      title = tagList(icon('id-card'), '公開された感染者情報'),
      width = 12, 
      closable = F,
      boxProfile(
        title = paste0('北海道', profile$No),
        subtitle = tagList(profile$性別.x),
        boxProfileItemList(
          bordered = TRUE,
          boxProfileItem(title = tagList(icon('user-clock'), '年代'),
                         description = profile$年代.x),
          boxProfileItem(title = tagList(icon('bullhorn'), '公表日'),
                         description = as.Date(profile$リリース日)),
          boxProfileItem(title = tagList(icon('user-tie'), '職業'),
                         description = profile$属性),
          boxProfileItem(title = tagList(icon('home'), '居住地'),
                         description = profile$居住地.x),
          boxProfileItem(
            title = tagList(icon('external-link-alt'), '情報源'),
            description = outerLinkTags
          ),
        )
      ),
      footer = tagList(
        tags$b(icon('handshake'), '濃厚接触者状況'),
        tags$p(tags$small(HTML(gsub('\n', '<br>', profile$濃厚接触者状況)))),
        tags$hr(),
        tags$b(icon('procedures'), '症状・経過'),
        tags$p(tags$small(HTML(gsub('\n', '<br>', profile$`症状・経過`)))),
        tags$hr(),
        tags$b(icon('walking'), '行動歴'),
        tags$p(tags$small(HTML(activityLog)))
      )
    )
  } else {
    return(tags$b('マップ上のマークをクリックすると感染者詳細がみれます。'))
  }
})


# observeEvent(input$hokkaidoConfirmedMap_click, { 
#   id <- input$hokkaidoConfirmedMap_marker_click$id
#   data <- hokkaidoData()$patient
#   profile <- data[No == 1]
#   
# })

output$hokkaidoPatientTable <- renderDataTable({
  data <- hokkaidoData()$patient
  testData <- data
  
  showCols <- c('No', 'リリース日', '居住地.x', '年代.x', '性別.x')
  dataForShow <- testData[, showCols, with = F]
  colnames(dataForShow) <- c('自治体番号', '公表日', '居住地', '年代', '性別')
  dataForShow$公表日 <- as.Date(dataForShow$公表日)
  DT::datatable(
    dataForShow,
    rownames = F,
    extensions = c('Responsive'),
    options = list(
      dom = 't',
      paging = F,
      filter = 'top',
      # scrollCollapse = T,
      scrollX = T,
      scrollY = '300px'
    )
  )
})


