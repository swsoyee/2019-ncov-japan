output$totalConfirmed <- renderValueBox({
  # 確認数の表示ボックス
  # Returns:
  #   valueBox: 確認数
  valueBox(
    value = sum(db[, 2:ncol(db)]),
    subtitle = paste0(lang[[langCode]][9], '*'),
    icon = icon('sad-tear'),
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
    value = "0",
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
    value = "2",
    subtitle = lang[[langCode]][6],
    icon = icon('grin-squint'),
    color = "green"
  )
})

output$compareWithYesterday <- renderUI({
  # 前日比べの詳細表示ボックスの作成
  # Retruns:
  #   box: 前日比べの詳細表示ボックス
  confirmedIncreaseAtTheLastDay <- sum(db[, ncol(db), with = F])
  lastDayConfirmedIncreasePercentage <- round(confirmedIncreaseAtTheLastDay / sum(db[, 2:ncol(db)]), 2) * 100
  # TODO データはないのでしばらくベタ書き
  suspiciousIncreaseAtTheLastDay <- '-'
  lastDaySuspiciousIncreasePercentage <- 0
  recoveredIncreaseAtTheLastDay <- '-'
  lastDayRecoveredIncreasePercentage <- 1
  deathIncreaseAtTheLastDay <- '-'
  lastDayDeathIncreasePercentage <- 0
  
  box(
    title = gsub('%1%', as.POSIXct(colnames(db)[ncol(db)-1], format = '%Y%m%d'),
                 lang[[langCode]][27]), # 前日比べ
    width = 12,
    footer = fluidRow(
      column(
        width = 3,
        descriptionBlock(
          number = confirmedIncreaseAtTheLastDay,
          number_color = "red", 
          number_icon = "fa fa-caret-up",
          header = paste(lastDayConfirmedIncreasePercentage, '%'), 
          text = lang[[langCode]][28], # 確認増加数
        )
      ),
      column(
        width = 3,
        descriptionBlock(
          number = suspiciousIncreaseAtTheLastDay,
          number_color = "red", 
          # number_icon = "fa fa-caret-up",
          header = paste(lastDaySuspiciousIncreasePercentage, '%'), 
          text = lang[[langCode]][29], # 観察中増加数
        )
      ),
      column(
        width = 3,
        descriptionBlock(
          number = lastDayRecoveredIncreasePercentage,
          number_color = "green", 
          # number_icon = "fa fa-equals",
          header = paste(50, '%'), 
          text = lang[[langCode]][30], # 完治増加数
        )
      ),
      column(
        width = 3,
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
