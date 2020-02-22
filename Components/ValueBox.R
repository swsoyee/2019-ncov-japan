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
