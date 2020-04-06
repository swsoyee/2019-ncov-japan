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

    loadDataFromFile <- function(fileList, FilePath, fileName, object, index) {
      # 実際のファイル名を取得
      dataName <- fileList[sapply(fileList, function(x) {grepl(fileName, x)})]
      # 保存
      object[[index]] <- fread(file = paste0(DATA_PATH, FilePath, dataName))
      return(object)
    }

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
                       sparkline = createSparklineInValueBox(data, '陽性数', length = 10),
                       subtitle = lang[[langCode]][100], 
                       icon = 'vials',
                       color = 'yellow',
        ),
        createValueBox(value = totalPositive,
                       subValue = paste0('速報：', sum(byDate[, 2, with = T], na.rm = T)), 
                       sparkline = createSparklineInValueBox(data, '実施数', length = 10),
                       subtitle = lang[[langCode]][101], 
                       icon = 'procedures',
                       color = 'red'
        )
      ),
      fluidRow(
        createValueBox(value = totalDischarge, # TODO 公式データまだない
                       subValue = dischargeRate, 
                       sparkline = createSparklineInValueBox(data, '治療終了数', length = 10),
                       subtitle = lang[[langCode]][102], 
                       icon = 'user-shield',
                       color = 'green'
        ),
        createValueBox(value = totalDeath, # TODO 公式データまだない
                       subValue = deathRate, 
                       sparkline = createSparklineInValueBox(data, '死亡数', length = 10),
                       subtitle = lang[[langCode]][103], 
                       icon = 'bible',
                       color = 'navy'
        )
      )
    )
  )
})
