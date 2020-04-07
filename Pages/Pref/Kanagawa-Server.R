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
    e_bar(合計, name = '専用ダイヤル相談件数（日次）', stack = 1, color = darkBlue) %>%
    e_bar(相談対応件数, name = '帰国者・接触者相談センター相談件数（日次）', stack = 1, color = lightBlue) %>%
    e_line(専用ダイヤル累計, name = '専用ダイヤル相談件数（累計）', stack = 2, y_index = 1, color = darkRed) %>%
    e_line(相談対応件数累計, name = '帰国者・接触者相談センター相談件数（累計）', stack = 2, y_index = 1, color = lightNavy) %>%
    e_y_axis(splitLine = list(show = F), index = 1) %>%
    e_grid(left = '8%', right = '10%', bottom = '10%') %>%
    e_legend(orient = 'vertical', top = '15%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = '専用ダイヤルおよび帰国者・接触者相談センター相談件数',
            subtext = paste('更新時刻：', getUpdateTimeDiff(GLOBAL_VALUE$Kanagawa$updateTime)))
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
            subtext = paste('更新時刻：', getUpdateTimeDiff(GLOBAL_VALUE$Kanagawa$updateTime)))
})
