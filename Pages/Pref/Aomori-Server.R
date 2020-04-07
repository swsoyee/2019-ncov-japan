observeEvent(input$sideBarTab, {
  if (input$sideBarTab == 'aomori' && is.null(GLOBAL_VALUE$Aomori[[1]])) {
    # GLOBAL_VALUE <- list(Aomori = list(
    #       summary = NULL,
    #       patient = NULL,
    #       callCenter = NULL,
    #       contact = NULL,
    #       updateTime = NULL
    #   )) # TEST

    fileList <- list.files(paste0(DATA_PATH, 'Pref/Aomori/'))

    indexName <- c('summary', 'patient', 'callCenter', 'contact')
    fileName <- c('検査実施状況.csv', '陽性患者関係.csv', 'コールセンター', '接触者相談')

    for (i in 1:length(indexName)) {
      GLOBAL_VALUE$Aomori <- loadDataFromFile(
        fileList = fileList,
        FilePath = 'Pref/Aomori/',
        fileName = fileName[i],
        object = GLOBAL_VALUE$Aomori,
        index = indexName[i])
    }

    GLOBAL_VALUE$Aomori$updateTime <- file.info(
      paste0(
        DATA_PATH,
        'Pref/Aomori/',
        fileList[sapply(fileList, function(x) {grepl('検査実施状況.csv', x)})]
        )
      )$mtime
  }
})

output$AomoriValueBoxes <- renderUI({
  data <- GLOBAL_VALUE$Aomori$summary
  totalPositive <- sum(data$陽性数, na.rm = T)
  totalPCR <- sum(data$実施数, na.rm = T)
  totalDischarge <-  sum(data$治療終了数, na.rm = T) # TODO 公式データまだない
  totalDeath <- sum(data$死亡数, na.rm = T) # TODO 公式データまだない
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
                       sparkline = createSparklineInValueBox(data, '実施数', length = 10),
                       subtitle = lang[[langCode]][100], 
                       icon = 'vials',
                       color = 'yellow', 
                       diff = tail(data$実施数, n = 1)
        ),
        createValueBox(value = totalPositive,
                       subValue = paste0('速報：', sum(byDate[, 3, with = T], na.rm = T)), 
                       sparkline = createSparklineInValueBox(data, '陽性数', length = 10),
                       subtitle = lang[[langCode]][101], 
                       icon = 'procedures',
                       color = 'red', 
                       diff = tail(data$陽性数, n = 1)
        )
      ),
      fluidRow(
        createValueBox(value = totalDischarge, # TODO 公式データまだない
                       subValue = dischargeRate, 
                       sparkline = createSparklineInValueBox(data, '治療終了数', length = 10),
                       subtitle = lang[[langCode]][102], 
                       icon = 'user-shield',
                       color = 'green',
                       diff = tail(data$治療終了数, n = 1)
        ),
        createValueBox(value = totalDeath, # TODO 公式データまだない
                       subValue = deathRate, 
                       sparkline = createSparklineInValueBox(data, '死亡数', length = 10),
                       subtitle = lang[[langCode]][103], 
                       icon = 'bible',
                       color = 'navy',
                       diff = tail(data$死亡数, n = 1)
        )
      )
    )
  )
})

output$AomoriSummary <- renderEcharts4r({
  data <- GLOBAL_VALUE$Aomori$summary
  data$検査日時 <- as.Date(data$検査日時, '%Y年%m月%d日')
  data$実施数累計 <- cumsum(data$実施数)
  data$陽性数累計 <- cumsum(data$陽性数)
  data %>%
    e_chart(検査日時) %>%
    e_bar(実施数, name = '検査実施数', y_index = 1, barGap = '-100%', color = middleYellow) %>%
    e_bar(陽性数, name = '陽性数', y_index = 1, color = middleRed) %>%
    e_line(実施数累計, name = '検査実施数累計', color = darkYellow) %>%
    e_line(陽性数累計, name = '陽性数累計', color = darkRed) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = max(data$実施数, na.rm = T) * 2) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_grid(left = '8%', right = '10%', bottom = '10%', top = '28%') %>%
    e_legend(orient = 'vertical', top = '28%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = '検査実施数・陽性数',
            subtext = paste(paste('更新時刻：', getUpdateTimeDiff(GLOBAL_VALUE$Aomori$updateTime)),
              '\n注1. 医療機関が保険適用で行った検査は含まれていない',
              '注2. 同一の対象者について複数の検体を検査する場合あり',
              '注3. 速報値として公開するものであり、後日確定データとして修正される場合あり',
              sep = '\n')
            # subtext = paste('更新時刻：', getUpdateTimeDiff(GLOBAL_VALUE$Aomori$updateTime))
            ) %>%
    e_group('aomoriSumarry')
})