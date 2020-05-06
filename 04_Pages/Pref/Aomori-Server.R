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
  data <- data[検査日時 != ""]
  totalPositive <- sum(data$陽性数, na.rm = T)
  totalPCR <- sum(data$実施数, na.rm = T)
  # totalDischarge <-  sum(data$治療終了数, na.rm = T) # TODO 公式データまだない、とりあえず厚労省から計算
  mhlw <- detailByRegion[都道府県名 == '青森県']
  mhlw[, 日次退院者 := 退院者 - shift(退院者)]
  # mhlw$日次退院者[is.na(mhlw$日次退院者)] <- 0
  dischargeValue <- mhlw$退院者
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
                       subValue = paste0(i18n$t('陽性率：'), positiveRate), 
                       sparkline = createSparklineInValueBox(data, '実施数', length = 10),
                       subtitle = i18n$t("検査数"),
                       icon = 'vials',
                       color = 'yellow', 
                       diff = tail(data$実施数, n = 1)
        ),
        createValueBox(value = totalPositive,
                       subValue = paste0(i18n$t('速報：'), sum(byDate[, 3, with = T], na.rm = T)), 
                       sparkline = createSparklineInValueBox(data, '陽性数', length = 10),
                       subtitle = i18n$t("陽性者数"),
                       icon = 'procedures',
                       color = 'red', 
                       diff = tail(data$陽性数, n = 1)
        )
      ),
      fluidRow(
        createValueBox(value = totalDischarge, # TODO 公式データまだない
                       subValue = dischargeRate, 
                       sparkline = createSparklineInValueBox(mhlw, '日次退院者', length = 19),
                       subtitle = i18n$t("退院者数"),
                       icon = 'user-shield',
                       color = 'green',
                       diff = tail(data$治療終了数, n = 1)
        ),
        createValueBox(value = totalDeath, # TODO 公式データまだない
                       subValue = deathRate, 
                       sparkline = createSparklineInValueBox(data, '死亡数', length = 10),
                       subtitle = i18n$t("死亡者数"),
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
    e_bar(実施数, name = i18n$t('検査実施数'), y_index = 1, barGap = '-100%', color = middleYellow) %>%
    e_bar(陽性数, name = i18n$t('陽性数'), y_index = 1, color = middleRed) %>%
    e_line(実施数累計, name = i18n$t('検査実施数累計'), color = darkYellow) %>%
    e_line(陽性数累計, name = i18n$t('陽性数累計'), color = darkRed) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = max(data$実施数, na.rm = T) * 2) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_grid(left = '8%', right = '10%', bottom = '10%', top = '28%') %>%
    e_legend(orient = 'vertical', top = '28%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = i18n$t('検査実施数・陽性数'),
            subtext = paste(paste(i18n$t("更新時刻："), getUpdateTimeDiff(GLOBAL_VALUE$Aomori$updateTime)),
              '\n注1. 医療機関が保険適用で行った検査は含まれていない',
              '注2. 同一の対象者について複数の検体を検査する場合あり',
              '注3. 速報値として公開するものであり、後日確定データとして修正される場合あり',
              sep = '\n')
            ) %>%
    e_group('aomoriSumarry')
})

output$AomoriContact <- renderEcharts4r({
  callCenter <- GLOBAL_VALUE$Aomori$callCenter[受付_年月日 != '']
  contact <- GLOBAL_VALUE$Aomori$contact[受付_年月日 != '']
  callCenter$受付_年月日 <- as.Date(callCenter$受付_年月日, '%Y年%m月%d日')
  contact$受付_年月日 <- as.Date(contact$受付_年月日, '%Y年%m月%d日')
  callCenter[, コールセンター相談件数累計 := cumsum(相談件数.対応.)]
  contact[, 相談件数累計 := cumsum(相談件数)]
  dt <- merge(x = callCenter, y = contact, by = '受付_年月日', all = T, no.dups = T)
  
  dt %>%
    e_chart(受付_年月日) %>%
    e_bar(相談件数.対応., name = i18n$t("コールセンター（日次）"), y_index = 1, stack = 1, color = middleBlue) %>%
    e_bar(相談件数, name = i18n$t("帰国者・接触者相談（日次）"), y_index = 1, stack = 1, color = lightBlue) %>%
    e_line(コールセンター相談件数累計, name = i18n$t("コールセンター（累計）"), stack = 2, color = darkRed) %>%
    e_line(相談件数累計, name = lang[[langCode]][108], stack = 2, color = middelNavy) %>%
    e_y_axis(splitLine = list(show = F), index = 1, max = max(dt$相談件数 + dt$相談件数.対応., na.rm = T) * 2) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_grid(left = '8%', right = '8%', bottom = '10%') %>%
    e_legend(orient = 'vertical', top = '15%', left = '8%') %>%
    e_tooltip(trigger = 'axis') %>%
    e_title(text = lang[[langCode]][104],
            subtext = paste(i18n$t("更新時刻："), getUpdateTimeDiff(GLOBAL_VALUE$Aomori$updateTime))
    ) %>%
    e_group('aomoriSumarry') %>%
    e_connect_group('aomoriSumarry')
})