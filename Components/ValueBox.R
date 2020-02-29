output$todayConfirmed <- renderUI({
  if (length(HAS_TODAY_CONFIRMED) > 0) {
    elements <- list()
    for (i in 1:length(HAS_TODAY_CONFIRMED)) {
      elements[[i]] <- dashboardLabel(paste(names(HAS_TODAY_CONFIRMED[i]), 
                                            '+', 
                                            HAS_TODAY_CONFIRMED[i]), 
                                      status = 'danger', style = 'square')
    }
    tagList(elements)
  } else {
    dashboardLabel(lang[[langCode]][63], status = 'danger', style = 'square') # 新たに確認された感染者はいません
  }
})

output$todayCured <- renderUI({
  dashboardLabel(lang[[langCode]][87], status = 'success', style = 'square')
})

output$todayDeath <- renderUI({
  if (length(HAS_TODAY_DEATH) > 0) {
    elements <- list()
    for (i in 1:length(HAS_TODAY_DEATH)) {
      elements[[i]] <- dashboardLabel(paste(names(HAS_TODAY_DEATH[i]), 
                                            '+', 
                                            HAS_TODAY_DEATH[i]), 
                                      status = 'primary', style = 'square')
    }
    tagList(elements)
  } else {
    dashboardLabel(lang[[langCode]][73], status = 'primary', style = 'square') # 新た死者は出ていません
  }
})
