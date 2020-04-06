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

output$AomoriFormalConfirmedSparkline <- renderSparkline({
  createSparklineInValueBox(GLOBAL_VALUE$Aomori$summary, '陽性数', length = 10)
})

output$AomoriFormalPCRSparkline <- renderSparkline({
  createSparklineInValueBox(GLOBAL_VALUE$Aomori$summary, '実施数', length = 10)
})

output$AomoriFormalDischargeSparkline <- renderSparkline({
  createSparklineInValueBox(GLOBAL_VALUE$Aomori$summary, '治療終了数', length = 10)
})

output$AomoriFormalDeathSparkline <- renderSparkline({
  createSparklineInValueBox(GLOBAL_VALUE$Aomori$summary, '死亡数', length = 10)
})

output$AomoriPCRValue <- renderUI({
  precentage <- paste0(round(sum(GLOBAL_VALUE$Aomori$summary$陽性数, na.rm = T) / sum(GLOBAL_VALUE$Aomori$summary$実施数, na.rm = T) * 100, 2), '%')
  createValueBox(value = sum(GLOBAL_VALUE$Aomori$summary$実施数, na.rm = T),
                 subValue = paste0('陽性率：', precentage),
                 sparkline = 'AomoriFormalPCRSparkline',
                 subtitle = '累計検査数',
                 icon = 'vials',
                 color = 'yellow',
  )
})

output$AomoriConfirmedValue <- renderUI({
  createValueBox(value = sum(GLOBAL_VALUE$Aomori$summary$陽性数, na.rm = T),
                 subValue = paste0('速報：', sum(byDate[, 3, with = T], na.rm = T)),
                 sparkline = 'AomoriFormalConfirmedSparkline',
                 subtitle = '累計陽性者数',
                 icon = 'procedures',
                 color = 'red'
  )
})

output$AomoriDischargeValue <- renderUI({
  data <- hokkaidoData()$data
  precentage <- paste0(
    round(
      sum(GLOBAL_VALUE$Aomori$summary$治療終了数, na.rm = T) / sum(GLOBAL_VALUE$Aomori$summary$陽性数, na.rm = T
                                                              ) * 100, 2
      ), '%'
    )
  createValueBox(value = sum(GLOBAL_VALUE$Aomori$summary$治療終了数, na.rm = T),
                 subValue = precentage, 
                 sparkline = 'AomoriFormalDischargeSparkline', 
                 subtitle = '累計治療終了数', 
                 icon = 'user-shield',
                 color = 'green'
  )
})

output$AomoriDeathValue <- renderUI({
  precentage <- paste0(
    round(
      sum(GLOBAL_VALUE$Aomori$summary$死亡数, na.rm = T) / sum(GLOBAL_VALUE$Aomori$summary$陽性数, na.rm = T
      ) * 100, 2
    ), '%'
  )
  createValueBox(value = sum(GLOBAL_VALUE$Aomori$summary$死亡数, na.rm = T),
                 subValue = precentage, 
                 sparkline = 'AomoriFormalDeathSparkline', 
                 subtitle = '累計死亡者数', 
                 icon = 'bible',
                 color = 'navy'
  )
})
