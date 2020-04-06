observeEvent(input$sideBarTab, {
  if (input$sideBarTab == 'hokkaido' && is.null(GLOBAL_VALUE$hokkaidoData)) {
    # GLOBAL_VALUE <- list(hokkaidoData = NULL, hokkaidoPatients = NULL) # TEST
    GLOBAL_VALUE$hokkaidoData <- fread(file = paste0(DATA_PATH, 'Pref/Hokkaido/covid19_data.csv'))
    GLOBAL_VALUE$hokkaidoDataUpdateTime <- file.info(paste0(DATA_PATH, 'Pref/Hokkaido/covid19_data.csv'))$mtime
    GLOBAL_VALUE$hokkaidoData$date <- as.Date(paste0(GLOBAL_VALUE$hokkaidoData$年, '/', GLOBAL_VALUE$hokkaidoData$月, '/', GLOBAL_VALUE$hokkaidoData$日))
    # data <- GLOBAL_VALUE$hokkaidoData # TEST
    GLOBAL_VALUE$hokkaidoPatients <- fread(file = paste0(DATA_PATH, 'Pref/Hokkaido/patients.csv'))
    # data <- GLOBAL_VALUE$hokkaidoPatients # TEST
  }
})

hokkaidoData <- reactive({
  return(list(data = GLOBAL_VALUE$hokkaidoData, 
              dataUpdateTime = GLOBAL_VALUE$hokkaidoDataUpdateTime,
              patient = GLOBAL_VALUE$hokkaidoPatients))
})

output$hokkaidoValueBoxes <- renderUI({
  data <- hokkaidoData()$data
  positiveRate <- paste0(round(tail(data$陽性累計, n = 1) / tail(data$検査累計, n = 1) * 100, 2), '%')
  dischargeRate <- paste0(round(tail(data$治療終了累計, n = 1) / tail(data$陽性累計, n = 1) * 100, 2), '%')
  deathRate <- precentage <- paste0(round(tail(data$死亡累計, n = 1) / tail(data$陽性累計, n = 1) * 100, 2), '%')
  
  return(
    tagList(
      fluidRow(
        createValueBox(value = tail(data$検査累計, n = 1),
                       subValue = paste0('陽性率：', precentage), 
                       sparkline = createSparklineInValueBox(data, '日検査数'), 
                       subtitle = lang[[langCode]][100], 
                       icon = 'vials',
                       color = 'yellow',
                       diff = tail(data$日検査数 , n = 1)
        ),
        createValueBox(value = tail(data$陽性累計, n = 1),
                       subValue = paste0('速報：', sum(byDate[, 2, with = T], na.rm = T)), 
                       sparkline = createSparklineInValueBox(data, '日陽性数'), 
                       subtitle = lang[[langCode]][101], 
                       icon = 'procedures',
                       color = 'red',
                       diff = tail(data$日陽性数 , n = 1)
        )
      ),
      fluidRow(
        createValueBox(value = tail(data$治療終了累計, n = 1),
                       subValue = dischargeRate, 
                       sparkline = createSparklineInValueBox(data, '日治療終了数'), 
                       subtitle = lang[[langCode]][102], 
                       icon = 'user-shield',
                       color = 'green',
                       diff = tail(data$日治療終了数 , n = 1)
        ),
        createValueBox(value = tail(data$死亡累計, n = 1),
                       subValue = deathRate, 
                       sparkline = createSparklineInValueBox(data, '日死亡数'), 
                       subtitle = lang[[langCode]][103], 
                       icon = 'bible',
                       color = 'navy',
                       diff = tail(data$日死亡数 , n = 1)
        )
      )
    )
  )
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
    e_title(subtext = paste('更新時刻：', LATEST_UPDATE))
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
    e_title(subtext = paste('更新時刻：', LATEST_UPDATE))
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
  id <- hokkaidoValue$profileId
  if (!is.null(data) && !is.null(id)) {
    data <- hokkaidoData()$patient
    return(data[No == id])
  } else {
    return(NULL)
  }
})

hokkaidoValue <- reactiveValues(profileId = NULL)

observeEvent(input$hokkaidoConfirmedMap_marker_click$id, {
  hokkaidoValue$profileId <- input$hokkaidoConfirmedMap_marker_click$id
})
observeEvent(input$hokkaidoPatientTable_rows_selected, {
  hokkaidoValue$profileId <- input$hokkaidoPatientTable_rows_selected
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
        src = ifelse(profile$性別.x == '男性', 'Icon/male.png', 'Icon/female.png'),
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
  # testData <- data
  
  showCols <- c('No', 'リリース日', '居住地.x', '年代.x', '性別.x', '濃厚接触者状況')
  dataForShow <- data[, showCols, with = F]
  colnames(dataForShow) <- c('自治体番号', '公表日', '居住地', '年代', '性別', '濃厚接触者状況')
  dataForShow$公表日 <- as.Date(dataForShow$公表日)
  dataForShow$居住地 <- as.factor(dataForShow$居住地)
  dataForShow$年代 <- as.factor(dataForShow$年代)
  dataForShow$性別 <- as.factor(dataForShow$性別)
  DT::datatable(
    dataForShow,
    rownames = F,
    filter = 'top',
    extensions = c('Responsive'),
    selection = 'single',
    options = list(
      dom = 'tf',
      paging = F,
      filter = 'top',
      # scrollCollapse = T,
      scrollX = T,
      scrollY = '300px'
    )
  )
})

# ====作成中====
# output$hokkaidoGenderBar <- renderEcharts4r({
#   data <- hokkaidoData()$patient
#   
#   dt <- data[, .(count = .N), by = .(年代.x, 性別.x)]
#   
#   maleCount <- sum(dt$count.男性)
#   femaleCount <- sum(dt$count.女性)
#   totalCount <- maleCount + femaleCount
#   dt %>%
#     e_chart(年齢) %>%
#     e_bar(count.男, stack = '1', name = '男性', itemStyle = list(color = darkNavy)) %>%
#     e_bar(count.女性, stack = '1', name = '女性', itemStyle = list(color = middleRed)) %>%
#     e_x_axis(axisTick = list(show = F), offset = - 20) %>%
#     e_labels(position = 'inside', formatter = htmlwidgets::JS('
#       function(params) {
#         let count = params.value[0]
#         if(count < 0) {
#           count = -count
#         }
#         return(count)
#       }
#     ')) %>%
#     e_y_axis(show = F) %>%
#     e_flip_coords() %>%
#     e_tooltip(formatter = htmlwidgets::JS(paste0('
#       function(params) {
#         let count = params[0].value[0]
#         if(count < 0) {
#           count = -count
#         }
#         const total = Number(count) + Number(params[1].value[0])
#         return(`${params[0].value[1]}合計：${total}人 (総計の${Math.round(total/', totalCount, '*100, 4)}%)
#           <hr>男性：${count}人 (${params[0].value[1]}の${Math.round(count/total*100, 4)}%)
#           <br>女性：${params[1].value[0]}人 (${params[0].value[1]}の${Math.round(params[1].value[0]/total*100, 4)}%)
#         `)
#       }
#                                           ')), 
#               trigger = 'axis',
#               axisPointer = list(type = 'shadow')
#     ) %>%
#     e_title(
#       text = paste0(
#         '男性：', maleCount, '人 (', round(maleCount / totalCount * 100, 2), 
#         '%), 女性：', femaleCount, '人 (', round(femaleCount / totalCount * 100, 2), 
#         '%), 計：', totalCount, '人'),
#       textStyle = list(fontSize = 11),
#       subtext = '性別、年齢不明および発表なしの感染者が含まれていませんのでご注意ください。',
#       subtextStyle = list(fontSize = 9)
#     ) %>%
#     e_legend(top = '15%', right = '0%', selectedMode = F, orient = 'vertical') %>%
#     e_grid(bottom = '0%', right = '5%', left = '5%')
# })
# 
# 
