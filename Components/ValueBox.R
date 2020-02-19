output$totalConfirmed <- renderValueBox({
  # 確認数の表示ボックス
  # Returns:
  #   valueBox: 確認数 (国内事例)
  valueBox(
    value = paste0(sum(db[, 2:ncol(db)]), ' (', sum(db[c(1:47, 50), 2:ncol(db)]), ')'),
    subtitle = paste0(lang[[langCode]][9], ' (', lang[[langCode]][4], ')'),
    icon = icon('sad-tear'),
    color = "red"
  )
})

output$shipConfirmed <- renderValueBox({
  # 確認数の表示ボックス
  # Returns:
  #   valueBox: ダイアモンド・プリンセス号
  valueBox(
    value = sum(db[48, 2:ncol(db)]),
    subtitle = lang[[langCode]][35],
    icon = icon('ship'),
    color = "red"
  )
})

output$flightConfirmed <- renderValueBox({
  # 確認数の表示ボックス
  # Returns:
  #   valueBox: チャーター便
  valueBox(
    value = sum(db[49, 2:ncol(db)]),
    subtitle = lang[[langCode]][36],
    icon = icon('plane'),
    color = "red"
  )
})

output$totalSuspicious <- renderValueBox({
  # 観察中の表示ボックス
  # Returns:
  #   valueBox: 観察中
  valueBox(
    value = "？",
    subtitle = lang[[langCode]][8],
    icon = icon('flushed'),
    color = "orange"
  )
})

output$totalDeath <- renderValueBox({
  # 死亡数の表示ボックス
  # Returns:
  #   valueBox: 死亡数
  valueBox(
    value = "1",
    subtitle = lang[[langCode]][7],
    icon = icon('dizzy'),
    color = "navy"
  )
})

output$totalRecovered <- renderValueBox({
  # 完治数の表示ボックス
  # Returns:
  #   valueBox: 完治数
  valueBox(
    value = paste0(sum(recovered[, 2:3]), ' (', sum(recovered[, 3]), ')'),
    subtitle = paste0(lang[[langCode]][6], ' (', lang[[langCode]][36], ')'),
    icon = icon('grin-squint'),
    color = "green"
  )
})

output$compareWithYesterday <- renderUI({
  # 前日比べの詳細表示ボックスの作成
  # Retruns:
  #   box: 前日比べの詳細表示ボックス
  confirmedIncreaseAtTheLastDay <- sum(db[, ncol(db), with = F])
  lastDayConfirmedIncreasePercentage <- round(confirmedIncreaseAtTheLastDay / sum(db[, 2:ncol(db)]) * 100, 2)
  # TODO データはないのでしばらくベタ書き
  suspiciousIncreaseAtTheLastDay <- '-'
  lastDaySuspiciousIncreasePercentage <- 0
  recoveredIncreaseAtTheLastDay <- sum(recovered[nrow(recovered), 2:3])
  lastDayRecoveredIncreasePercentage <- round(recoveredIncreaseAtTheLastDay / sum(recovered[, 2:3]) * 100, 2)
  deathIncreaseAtTheLastDay <- '-'
  lastDayDeathIncreasePercentage <- 0
  
  box(
    title = gsub('%1%', as.POSIXct(colnames(db)[ncol(db)-1], format = '%Y%m%d'),
                 lang[[langCode]][27]), # 前日比べ
    width = 12,
    footer = fluidRow(
      column(
        width = 4,
        descriptionBlock(
          number = confirmedIncreaseAtTheLastDay,
          number_color = "red", 
          number_icon = "fa fa-caret-up",
          header = paste(lastDayConfirmedIncreasePercentage, '%'), 
          text = lang[[langCode]][28], # 確認増加数
        )
      ),
      # column(
      #   width = 3,
      #   descriptionBlock(
      #     number = suspiciousIncreaseAtTheLastDay,
      #     number_color = "red", 
      #     # number_icon = "fa fa-caret-up",
      #     header = paste(lastDaySuspiciousIncreasePercentage, '%'), 
      #     text = lang[[langCode]][29], # 観察中増加数
      #   )
      # ),
      column(
        width = 4,
        descriptionBlock(
          number = recoveredIncreaseAtTheLastDay,
          number_color = "green", 
          number_icon = "fa fa-caret-up",
          header = paste(lastDayRecoveredIncreasePercentage, '%'), 
          text = lang[[langCode]][30], # 完治増加数
        )
      ),
      column(
        width = 4,
        descriptionBlock(
          number = deathIncreaseAtTheLastDay, 
          number_color = "red", 
          # number_icon = "fa fa-caret-down",
          header = paste(lastDayDeathIncreasePercentage, '%'),
          text = lang[[langCode]][31], # 死亡増加数
          right_border = FALSE,
          margin_bottom = FALSE
        )
      )
    )
  )
})
