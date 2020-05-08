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
    e_bar(合計, name = i18n$t("コールセンター（日次）"), stack = 1, color = darkBlue) %>%
    e_bar(相談対応件数, name = i18n$t("帰国者・接触者相談（日次）"), stack = 1, color = lightBlue) %>%
    e_line(専用ダイヤル累計, name = i18n$t("コールセンター（累計）"), stack = 2, y_index = 1, color = darkRed) %>%
    e_line(相談対応件数累計, name = lang[[langCode]][108], stack = 2, y_index = 1, color = lightNavy) %>%
    e_y_axis(splitLine = list(show = F), index = 1) %>%
    e_grid(left = '8%', right = '10%', bottom = '10%') %>%
    e_legend(orient = 'vertical', top = '15%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = lang[[langCode]][104],
            subtext = paste(i18n$t("更新時刻："), getUpdateTimeDiff(GLOBAL_VALUE$Kanagawa$updateTime))) %>%
    e_group('kanagawaSumarry')
})

output$kanagawaPatientSummary <- renderEcharts4r({
  data <- GLOBAL_VALUE$Kanagawa$summary
  data %>%
    e_chart(日付) %>%
    e_bar(男性, stack = 1, y_index= 1, color = darkNavy) %>%
    e_bar(女性, stack = 1, y_index= 1, color = middleRed) %>%
    e_bar(非公表, stack = 1, y_index= 1, color = darkBlue) %>%
    # e_bar(調査中, stack = 1, y_index= 1, color = darkYellow) %>%
    e_line(累積陽性数, y_index = 0, color = darkRed) %>%
    e_mark_line(data = list(xAxis = '2020-04-07', label = list(formatter = i18n$t("4月7日\n緊急事態宣言"))), symbol = 'circle') %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = max(data$陽性数, na.rm = T) * 2) %>%
    e_grid(left = '8%', right = '5%', bottom = '10%') %>%
    e_legend(orient = 'vertical', top = '15%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = paste0('陽性患者数（計', tail(data$累積陽性数, n = 1), '人）'),
            subtext = paste(i18n$t("更新時刻："), getUpdateTimeDiff(GLOBAL_VALUE$Kanagawa$updateTime))) %>%
    e_group('kanagawaSumarry') %>%
    e_connect_group('kanagawaSumarry')
})

output$kanagawaValueBoxes <- renderUI({
  data <- GLOBAL_VALUE$Kanagawa$summary
  totalPositive <- tail(data$累積陽性数, n = 1)
  # totalPCR <- sum(data$実施数, na.rm = T) # TODO 公式データまだない、とりあえずけんもうデータから計算
  pcrData <- pcrByRegion[都道府県略称 == '神奈川']
  pcrData[, 日次検査人数 := 検査人数 - shift(検査人数)]
  totalPCR <- tail(pcrData$検査人数, n = 1)
  # totalDischarge <-  sum(data$治療終了数, na.rm = T) # TODO 公式データまだない、とりあえず厚労省から計算
  mhlwKanagawa <- detailByRegion[都道府県名 == '神奈川県']
  mhlwKanagawa[, 日次退院者 := 退院者 - shift(退院者)]
  # mhlwKanagawa$日次退院者[is.na(mhlwKanagawa$日次退院者)] <- 0
  dischargeValue <- mhlwKanagawa$退院者
  totalDischarge <- tail(dischargeValue, n = 1)
  
  totalDeath <- sum(death[, 15, with = F]) # TODO 公式データまだない
  positiveRate <- paste0(round(tail(pcrData$陽性者数, n = 1) / totalPCR * 100, 2), '%')
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
        createValueBox(value = totalPCR, # TODO 今はけんものデータを使ってる
                       subValue = paste0(i18n$t('陽性率：'), positiveRate), 
                       sparkline = createSparklineInValueBox(pcrData, '日次検査人数'),
                       subtitle = i18n$t("検査数"),
                       icon = 'vials',
                       color = 'yellow', 
                       diff = tail(pcrData$日次検査人数, n = 1)
        ),
        createValueBox(value = tail(data$累積陽性数, n = 1),
                       subValue = paste0(i18n$t('速報：'), sum(byDate[, 15, with = T], na.rm = T)), 
                       sparkline = createSparklineInValueBox(data, '陽性数'),
                       subtitle = i18n$t("陽性者数"),
                       icon = 'procedures',
                       color = 'red', 
                       diff = tail(data$陽性数, n = 1)
        )
      ),
      fluidRow(
        createValueBox(value = totalDischarge, # TODO 今は厚労省のデータを使ってる
                       subValue = dischargeRate, # TODO
                       sparkline = createSparklineInValueBox(mhlwKanagawa, '日次退院者', length = 19),
                       subtitle = i18n$t("退院者数"),
                       icon = 'user-shield',
                       color = 'green',
                       diff = totalDischarge - dischargeValue[length(dischargeValue) - 1]
        ),
        createValueBox(value = totalDeath, # TODO 公式データまだない
                       subValue = deathRate, 
                       sparkline = createSparklineInValueBox(death, '神奈川'),
                       subtitle = i18n$t("死亡者数"),
                       icon = 'bible',
                       color = 'navy',
                       diff = tail(death[, 15, with = F], n = 1)
        )
      )
    )
  )
})
