output$compareWithYesterday <- renderUI({
  # 前日比べの詳細表示ボックスの作成
  # Retruns:
  #   box: 前日比べの詳細表示ボックス
  deathIncreaseAtTheLastDay <- '2'
  lastDayDeathIncreasePercentage <- 66.66
  
  box(
    title = gsub('%1%', as.POSIXct(colnames(db)[ncol(db)-1], format = '%Y%m%d'),
                 lang[[langCode]][27]), # 前日比べ
    width = 12,
    footer = fluidRow(
      column(
        width = 4,
        descriptionBlock(
          number = TOTAL_WITHIN_DIFF,
          number_color = "red", 
          number_icon = "fa fa-caret-up",
          header = TOTAL_WITHIN, 
          text = lang[[langCode]][28], # 確認増加数
        )
      ),
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
          number_icon = "fa fa-caret-up",
          header = paste(lastDayDeathIncreasePercentage, '%'),
          text = lang[[langCode]][31], # 死亡増加数
          right_border = FALSE,
          margin_bottom = FALSE
        )
      )
    )
  )
})

output$todayConfirmed <- renderUI({
  if (length(HAS_TODAY_CONFIRMED) > 0) {
    elements <- list()
    for (i in 1:length(HAS_TODAY_CONFIRMED)) {
      elements[[i]] <- dashboardLabel(paste(names(HAS_TODAY_CONFIRMED[i]), 
                                            '+', 
                                            HAS_TODAY_CONFIRMED[i]), 
                                      status = "danger")
    }
    tagList(elements)
  } else {
    lang[[langCode]][31] # 新たに確認された感染者はいません。
  }
})
