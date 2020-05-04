observeEvent(input$sideBarTab, {
  if (input$sideBarTab == 'iwate' && is.null(GLOBAL_VALUE$Iwate[[1]])) {
    # GLOBAL_VALUE <- list(Iwate = list(
    #       summary = NULL,
    #       patient = NULL,
    #       updateTime = NULL
    #   )) # TEST
    
    fileList <- list.files(paste0(DATA_PATH, 'Pref/Iwate/'))
    
    indexName <- c('summary')
    fileName <- c('summary.csv')
    
    for (i in 1:length(indexName)) {
      GLOBAL_VALUE$Iwate <- loadDataFromFile(
        fileList = fileList,
        FilePath = 'Pref/Iwate/',
        fileName = fileName[i],
        object = GLOBAL_VALUE$Iwate,
        index = indexName[i])
    }
    
    GLOBAL_VALUE$Iwate$updateTime <- file.info(
      paste0(
        DATA_PATH,
        'Pref/Iwate/',
        fileList[sapply(fileList, function(x) {grepl('summary.csv', x)})]
      )
    )$mtime
  }
})

output$IwateValueBoxes <- renderUI({
  data <- GLOBAL_VALUE$Iwate$summary
  totalPositive <- sum(data$陽性数, na.rm = T)
  totalPCR <- tail(data$検査数累計, n = 1)
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
                       subValue = paste0(i18n$t('陽性率：'), positiveRate), 
                       sparkline = createSparklineInValueBox(data, '検査数'),
                       subtitle = i18n$t("検査数"),
                       icon = 'vials',
                       color = 'yellow', 
                       diff = tail(data$実施数, n = 1)
        ),
        createValueBox(value = totalPositive,
                       subValue = paste0(i18n$t('速報：'), sum(byDate[, 4, with = T], na.rm = T)), 
                       sparkline = createSparklineInValueBox(data, '陽性数'),
                       subtitle = i18n$t("陽性者数"),
                       icon = 'procedures',
                       color = 'red', 
                       diff = tail(data$陽性数, n = 1)
        )
      ),
      fluidRow(
        createValueBox(value = totalDischarge, # TODO 公式データまだない
                       subValue = '-', # dischargeRate, 
                       sparkline = createSparklineInValueBox(data, '治療終了数'),
                       subtitle = i18n$t("退院者数"),
                       icon = 'user-shield',
                       color = 'green',
                       diff = tail(data$治療終了数, n = 1)
        ),
        createValueBox(value = totalDeath, # TODO 公式データまだない
                       subValue = '-', # deathRate, 
                       sparkline = createSparklineInValueBox(data, '死亡数'),
                       subtitle = i18n$t("死亡者数"),
                       icon = 'bible',
                       color = 'navy',
                       diff = tail(data$死亡数, n = 1)
        )
      )
    )
  )
})

output$IwateSummary <- renderEcharts4r({
  data <- GLOBAL_VALUE$Iwate$summary
  data$date <- as.Date(data$date)
  data %>%
    e_chart(date) %>%
    e_bar(検査数, name = '検査実施件数', y_index = 1, barGap = '-100%', color = middleYellow) %>%
    # e_bar(陽性数, name = '陽性数', y_index = 1, color = middleRed) %>%
    e_line(検査数累計, name = '検査実施件数累計', color = darkYellow) %>%
    # e_line(陽性数累計, name = '陽性数累計', color = darkRed) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = max(data$検査数, na.rm = T) * 2) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_grid(left = '8%', right = '10%', bottom = '10%', top = '28%') %>%
    e_legend(orient = 'vertical', top = '28%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = '検査実施件数',
            subtext = paste(paste(i18n$t("更新時刻："), getUpdateTimeDiff(GLOBAL_VALUE$Iwate$updateTime)),
                            '\n注1. 医療機関が保険適用で行った検査は含まれていない',
                            '注2. 同一の対象者について複数の検体を検査する場合あり',
                            '注3. 速報値として公開するものであり、後日確定データとして修正される場合あり',
                            sep = '\n')
    ) %>%
    e_group('iwateSumarry')
})

output$IwateContact <- renderEcharts4r({
  data <- GLOBAL_VALUE$Iwate$summary
  data$date <- as.Date(data$date)
  data %>%
    e_chart(date) %>%
    e_bar(一般相談, name = '（一般相談）受付 相談件数（日次）', y_index = 1, stack = 1, color = middleBlue) %>%
    e_bar(相談件数, name = i18n$t("帰国者・接触者相談（日次）"), y_index = 1, stack = 1, color = lightBlue) %>%
    e_line(一般相談累計, name = '（一般相談）受付 相談件数（累計）', stack = 2, color = darkRed) %>%
    e_line(相談件数累計, name = lang[[langCode]][108],stack = 2, color = middelNavy) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = max(data$相談件数 + data$一般相談, na.rm = T) * 2) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_grid(left = '8%', right = '8%', bottom = '10%') %>%
    e_legend(orient = 'vertical', top = '15%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = '一般相談および帰国者・接触者相談件数',
            subtext = paste(i18n$t("更新時刻："), getUpdateTimeDiff(GLOBAL_VALUE$Iwate$updateTime))
    ) %>%
    e_group('iwateSumarry') %>%
    e_connect_group('iwateSumarry')
})