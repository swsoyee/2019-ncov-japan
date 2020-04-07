observeEvent(input$sideBarTab, {
  if (input$sideBarTab == 'kanagawa' && is.null(GLOBAL_VALUE$Kanagawa[[1]])) {
    # GLOBAL_VALUE <- list(Kanagawa = list(
    #       summary = NULL,
    #       updateTime = NULL
    #   )) # TEST
    
    fileList <- list.files(paste0(DATA_PATH, 'Pref/Kanagawa/'))
    
    indexName <- c('summary')
    fileName <- c('summary.csv')
    
    for (i in 1:length(indexName)) {
      GLOBAL_VALUE$Kanagawa <- loadDataFromFile(
        fileList = fileList,
        FilePath = 'Pref/Kanagawa/',
        fileName = fileName[i],
        object = GLOBAL_VALUE$Kanagawa,
        index = indexName[i])
    }
    
    GLOBAL_VALUE$Kanagawa$updateTime <- file.info(
      paste0(
        DATA_PATH,
        'Pref/Kanagawa/',
        fileList[sapply(fileList, function(x) {grepl('summary.csv', x)})]
      )
    )$mtime
  }
})

output$kanagawaContact <- renderEcharts4r({
  data <- GLOBAL_VALUE$Kanagawa$summary
  data %>%
    e_chart(日付) %>%
    e_bar(合計, name = lang[[langCode]][105], stack = 1, color = darkBlue) %>%
    e_bar(相談対応件数, name = lang[[langCode]][107], stack = 1, color = lightBlue) %>%
    e_line(専用ダイヤル累計, name = lang[[langCode]][106], stack = 2, y_index = 1, color = darkRed) %>%
    e_line(相談対応件数累計, name = lang[[langCode]][108], stack = 2, y_index = 1, color = lightNavy) %>%
    e_y_axis(splitLine = list(show = F), index = 1) %>%
    e_grid(left = '8%', right = '10%', bottom = '10%') %>%
    e_legend(orient = 'vertical', top = '15%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = lang[[langCode]][104],
            subtext = paste('更新時刻：', getUpdateTimeDiff(GLOBAL_VALUE$Kanagawa$updateTime))) %>%
    e_group('kanagawaSumarry')
})

output$kanagawaPatientSummary <- renderEcharts4r({
  data <- GLOBAL_VALUE$Kanagawa$summary
  data %>%
    e_chart(日付) %>%
    e_bar(男性, stack = 1, y_index= 1, color = darkNavy) %>%
    e_bar(女性, stack = 1, y_index= 1, color = middleRed) %>%
    e_bar(非公表, stack = 1, y_index= 1, color = darkBlue) %>%
    e_bar(調査中, stack = 1, y_index= 1, color = darkYellow) %>%
    e_line(累積陽性数, y_index = 0, color = darkRed) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = max(data$陽性数, na.rm = T) * 2) %>%
    e_grid(left = '8%', right = '5%', bottom = '10%') %>%
    e_legend(orient = 'vertical', top = '15%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = paste0('陽性患者数（計', tail(data$累積陽性数, n = 1), '人）'),
            subtext = paste('更新時刻：', getUpdateTimeDiff(GLOBAL_VALUE$Kanagawa$updateTime))) %>%
    e_group('kanagawaSumarry') %>%
    e_connect_group('kanagawaSumarry')
})

output$kanagawaValueBoxes <- renderUI({
  data <- GLOBAL_VALUE$Kanagawa$summary
  totalPositive <- tail(data$累積陽性数, n = 1)
  totalPCR <- sum(data$実施数, na.rm = T) # TODO 公式データまだない
  totalDischarge <-  sum(data$治療終了数, na.rm = T) # TODO 公式データまだない
  totalDeath <- sum(death[, 15, with = F]) # TODO 公式データまだない
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
        createValueBox(value = '情報なし', # TODO
                       subValue = '-', # paste0('陽性率：', positiveRate), 
                       sparkline = createSparklineInValueBox(data, '実施数', length = 10),
                       subtitle = lang[[langCode]][100], 
                       icon = 'vials',
                       color = 'yellow', 
                       diff = tail(data$実施数, n = 1)
        ),
        createValueBox(value = tail(data$累積陽性数, n = 1),
                       subValue = paste0('速報：', sum(byDate[, 15, with = T], na.rm = T)), 
                       sparkline = createSparklineInValueBox(data, '陽性数', length = 10),
                       subtitle = lang[[langCode]][101], 
                       icon = 'procedures',
                       color = 'red', 
                       diff = tail(data$陽性数, n = 1)
        )
      ),
      fluidRow(
        createValueBox(value = '情報なし', # TODO
                       subValue = '-', # TODO
                       sparkline = createSparklineInValueBox(data, '治療終了数', length = 10),
                       subtitle = lang[[langCode]][102], 
                       icon = 'user-shield',
                       color = 'green',
                       diff = tail(data$治療終了数, n = 1)
        ),
        createValueBox(value = totalDeath, # TODO 公式データまだない
                       subValue = deathRate, 
                       sparkline = createSparklineInValueBox(death, '神奈川', length = 10),
                       subtitle = lang[[langCode]][103], 
                       icon = 'bible',
                       color = 'navy',
                       diff = tail(death[, 15, with = F], n = 1)
        )
      )
    )
  )
})
