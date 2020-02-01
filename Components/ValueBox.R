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
    value = "1",
    subtitle = lang[[langCode]][6],
    icon = icon('grin-squint'),
    color = "green"
  )
})
