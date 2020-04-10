observeEvent(input$sideBarTab, {
  if (input$sideBarTab == 'ibaraki' && is.null(GLOBAL_VALUE$Ibaraki[[1]])) {
    # GLOBAL_VALUE <- list(Ibaraki = list(
    #       summary = NULL,
    #       patient = NULL,
    #       updateTime = NULL
    #   )) # TEST
    
    fileList <- list.files(paste0(DATA_PATH, 'Pref/Ibaraki/'))
    
    indexName <- c('summary')
    fileName <- c('summary.csv')
    
    for (i in 1:length(indexName)) {
      GLOBAL_VALUE$Ibaraki <- loadDataFromFile(
        fileList = fileList,
        FilePath = 'Pref/Ibaraki/',
        fileName = fileName[i],
        object = GLOBAL_VALUE$Ibaraki,
        index = indexName[i])
    }
    
    GLOBAL_VALUE$Ibaraki$updateTime <- file.info(
      paste0(
        DATA_PATH,
        'Pref/Ibaraki/',
        fileList[sapply(fileList, function(x) {grepl('summary.csv', x)})]
      )
    )$mtime
  }
})

output$IbarakiValueBoxes <- renderUI({
  data <- GLOBAL_VALUE$Ibaraki$summary
  totalPositive <- sum(data$陽性数, na.rm = T)
  totalPCR <- tail(data$検査数累計, n = 1)
  # totalDischarge <-  sum(data$治療終了数, na.rm = T) # TODO 公式データまだない、とりあえず厚労省から計算
  mhlw <- detailByRegion[都道府県名 == '茨城県']
  mhlw[, 日次退院者 := 退院者 - shift(退院者)]
  mhlw[, 日次死亡者 := 死亡者 - shift(死亡者)]
  # mhlw$日次退院者[is.na(mhlw$日次退院者)] <- 0
  dischargeValue <- mhlw$退院者
  totalDischarge <- tail(dischargeValue, n = 1)
  
  # totalDeath <- sum(data$死亡数, na.rm = T) # TODO TODO 公式データまだない、とりあえず厚労省から計算
  deathValue <- mhlw$死亡者
  totalDeath <- tail(deathValue, n = 1)
  positiveRate <- paste0(round(totalPositive / totalPCR * 100, 2), '%')
  dischargeRate <- paste0(
    round(
      totalDischarge / totalPositive * 100, 2
    ), '%'
  )
  deathRate <- paste0(
    round(
      totalDeath / totalPositive * 100, 2
    ), '%'
  )
  
  return(
    tagList(
      fluidRow(
        createValueBox(value = totalPCR,
                       subValue = paste0('陽性率：', positiveRate), 
                       sparkline = createSparklineInValueBox(data, '検査数'),
                       subtitle = lang[[langCode]][100], 
                       icon = 'vials',
                       color = 'yellow', 
                       diff = tail(data$実施数, n = 1)
        ),
        createValueBox(value = totalPositive,
                       subValue = paste0('速報：', sum(byDate[, 9, with = T], na.rm = T)), 
                       sparkline = createSparklineInValueBox(data, '陽性数'),
                       subtitle = lang[[langCode]][101], 
                       icon = 'procedures',
                       color = 'red', 
                       diff = tail(data$陽性数, n = 1)
        )
      ),
      fluidRow(
        createValueBox(value = totalDischarge, # TODO 今は厚労省のデータを使ってる
                       subValue = dischargeRate, 
                       sparkline = createSparklineInValueBox(mhlw, '日次退院者', length = 20),
                       subtitle = lang[[langCode]][102], 
                       icon = 'user-shield',
                       color = 'green',
                       diff = totalDischarge - dischargeValue[length(dischargeValue) - 1]
        ),
        createValueBox(value = totalDeath, # TODO 今は厚労省のデータを使ってる
                       subValue = deathRate, 
                       sparkline = createSparklineInValueBox(mhlw, '日次死亡数', length = 20),
                       subtitle = lang[[langCode]][103], 
                       icon = 'bible',
                       color = 'navy',
                       diff = totalDeath - deathValue[length(deathValue) - 1]
        )
      )
    )
  )
})

output$IbarakiSummary <- renderEcharts4r({
  data <- GLOBAL_VALUE$Ibaraki$summary
  data$date <- as.Date(data$date)
  data %>%
    e_chart(date) %>%
    e_bar(検査数, name = '検査実施数', y_index = 1, barGap = '-100%', color = middleYellow) %>%
    e_bar(陽性数, name = '陽性数', y_index = 1, color = middleRed) %>%
    e_line(検査数累計, name = '検査実施数累計', color = darkYellow) %>%
    e_line(陽性数累計, name = '陽性数累計', color = darkRed) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = max(data$検査数, na.rm = T) * 2) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_grid(left = '8%', right = '10%', bottom = '10%', top = '28%') %>%
    e_legend(orient = 'vertical', top = '28%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = '検査実施数',
            subtext = paste(paste('更新時刻：', getUpdateTimeDiff(GLOBAL_VALUE$Ibaraki$updateTime)),
                            '\n注1. 医療機関が保険適用で行った検査は含まれていない',
                            '注2. チャーター機帰国者、クルーズ船乗客等は含まれていない',
                            '注3. 速報値として公開するものであり、後日確定データとして修正される場合あり',
                            sep = '\n')
    ) %>%
    e_group('ibarakiSumarry')
})

output$IbarakiContact <- renderEcharts4r({
  data <- GLOBAL_VALUE$Ibaraki$summary
  data$date <- as.Date(data$date)
  data %>%
    e_chart(date) %>%
    e_bar(相談件数, name = '電話相談件数（日次）', y_index = 1, stack = 1, color = middleBlue) %>%
    e_line(相談件数累計, name = '電話相談件数（累計）', stack = 2, color = darkRed) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = max(data$相談件数, na.rm = T) * 2) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_grid(left = '8%', right = '8%', bottom = '10%') %>%
    e_legend(orient = 'vertical', top = '15%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = '新型コロナウイルス感染症　電話相談件数',
            subtext = paste('更新時刻：', getUpdateTimeDiff(GLOBAL_VALUE$Ibaraki$updateTime))
    ) %>%
    e_group('ibarakiSumarry') %>%
    e_connect_group('ibarakiSumarry')
})