observeEvent(input$sideBarTab, {
  if (input$sideBarTab == 'miyagi' && is.null(GLOBAL_VALUE$Miyagi[[1]])) {
    # GLOBAL_VALUE <- list(Miyagi = list(
    #       summary = NULL,
    #       patient = NULL,
    #       updateTime = NULL
    #   )) # TEST
    
    fileList <- list.files(paste0(DATA_PATH, 'Pref/Miyagi/'))
    
    indexName <- c('summary')
    fileName <- c('summary.csv')
    
    for (i in 1:length(indexName)) {
      GLOBAL_VALUE$Miyagi <- loadDataFromFile(
        fileList = fileList,
        FilePath = 'Pref/Miyagi/',
        fileName = fileName[i],
        object = GLOBAL_VALUE$Miyagi,
        index = indexName[i])
    }
    
    GLOBAL_VALUE$Miyagi$updateTime <- file.info(
      paste0(
        DATA_PATH,
        'Pref/Miyagi/',
        fileList[sapply(fileList, function(x) {grepl('summary.csv', x)})]
      )
    )$mtime
  }
})

output$MiyagiValueBoxes <- renderUI({
  data <- GLOBAL_VALUE$Miyagi$summary
  totalPositive <- sum(data$陽性数, na.rm = T)
  totalPCR <- tail(data$検査数累計, n = 1)
  # totalDischarge <-  sum(data$治療終了数, na.rm = T) # TODO 公式データまだない、とりあえず厚労省から計算
  mhlwMiyagi <- detailByRegion[都道府県名 == '宮城県']
  mhlwMiyagi[, 日次退院者 := 退院者 - shift(退院者)]
  # mhlwMiyagi$日次退院者[is.na(mhlwMiyagi$日次退院者)] <- 0
  dischargeValue <- mhlwMiyagi$退院者
  totalDischarge <- tail(dischargeValue, n = 1)
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
                       sparkline = createSparklineInValueBox(data, '検査数'),
                       subtitle = lang[[langCode]][100], 
                       icon = 'vials',
                       color = 'yellow', 
                       diff = tail(data$実施数, n = 1)
        ),
        createValueBox(value = totalPositive,
                       subValue = paste0('速報：', sum(byDate[, 5, with = T], na.rm = T)), 
                       sparkline = createSparklineInValueBox(data, '陽性数'),
                       subtitle = lang[[langCode]][101], 
                       icon = 'procedures',
                       color = 'red', 
                       diff = tail(data$陽性数, n = 1)
        )
      ),
      fluidRow(
        createValueBox(value = totalDischarge, # TODO 今は厚労省のデータを使ってる
                       subValue = dischargeRate, # TODO
                       sparkline = createSparklineInValueBox(mhlwMiyagi, '日次退院者', length = 20),
                       subtitle = lang[[langCode]][102], 
                       icon = 'user-shield',
                       color = 'green',
                       diff = totalDischarge - dischargeValue[length(dischargeValue) - 1]
        ),
        createValueBox(value = totalDeath, # TODO 公式データまだない
                       subValue = '-', # deathRate, 
                       sparkline = createSparklineInValueBox(data, '死亡数'),
                       subtitle = lang[[langCode]][103], 
                       icon = 'bible',
                       color = 'navy',
                       diff = tail(data$死亡数, n = 1)
        )
      )
    )
  )
})

output$MiyagiSummary <- renderEcharts4r({
  data <- GLOBAL_VALUE$Miyagi$summary
  data$date <- as.Date(data$date)
  data %>%
    e_chart(date) %>%
    e_bar(検査数, name = '検査実施件数', y_index = 1, barGap = '-100%', color = middleYellow) %>%
    e_bar(陽性数, name = '陽性者数', y_index = 1, color = middleRed) %>%
    e_line(検査数累計, name = '検査実施件数累計', color = darkYellow) %>%
    e_line(陽性数累計, name = '陽性数者累計', color = darkRed) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = max(data$検査数, na.rm = T) * 2) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_grid(left = '8%', right = '10%', bottom = '10%', top = '28%') %>%
    e_legend(orient = 'vertical', top = '28%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = '検査実施件数・陽性者数',
            subtext = paste(paste('更新時刻：', getUpdateTimeDiff(GLOBAL_VALUE$Miyagi$updateTime)),
                            '\n注1. 検査開始日；令和２年１月３０日（木）１９時',
                            '注2. PCR検査実施件数は，帰国者・接触者外来を通じて検査を行った数のみを計上しており，',
                            '     退院時の確認検査などは含まれておりません。',
                            sep = '\n')
    ) %>%
    e_group('miyagiSumarry')
})

output$MiyagiContact <- renderEcharts4r({
  data <- GLOBAL_VALUE$Miyagi$summary
  data$date <- as.Date(data$date)
  data %>%
    e_chart(date) %>%
    # e_bar(一般相談, name = '（一般相談）受付 相談件数（日次）', y_index = 1, stack = 1, color = middleBlue) %>%
    e_bar(相談件数, name = lang[[langCode]][107], y_index = 1, stack = 1, color = lightBlue) %>%
    # e_line(一般相談累計, name = '（一般相談）受付 相談件数（累計）', stack = 2, color = darkRed) %>%
    e_line(相談件数累計, name = lang[[langCode]][108],stack = 2, color = middelNavy) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = max(data$相談件数, na.rm = T) * 2) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_grid(left = '8%', right = '8%', bottom = '10%') %>%
    e_legend(orient = 'vertical', top = '15%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = '新型コロナウイルス感染症相談窓口（コールセンター）対応状況',
            subtext = paste('更新時刻：', getUpdateTimeDiff(GLOBAL_VALUE$Miyagi$updateTime))
    ) %>%
    e_group('miyagiSumarry') %>%
    e_connect_group('miyagiSumarry')
})