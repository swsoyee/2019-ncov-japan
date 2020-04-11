output$todayConfirmed <- renderUI({
  if (length(HAS_TODAY_CONFIRMED) > 0) {
    elements <- list()
    for (i in 1:length(HAS_TODAY_CONFIRMED)) {
      elements[[i]] <- dashboardLabel(paste(names(HAS_TODAY_CONFIRMED[i]), 
                                            '+', 
                                            HAS_TODAY_CONFIRMED[i]), 
                                      status = 'danger', style = 'square')
    }
    tagList(tags$b(lang[[langCode]][78]), elements)
  } else {
    tagList(tags$b(lang[[langCode]][78]), 
            dashboardLabel(lang[[langCode]][63], status = 'danger', style = 'square') # なし
    )
  }
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
    tagList(tags$b(lang[[langCode]][78]), elements)
  } else {
    tagList(tags$b(lang[[langCode]][78]), 
            dashboardLabel(lang[[langCode]][73], status = 'primary', style = 'square') # なし
    )
  }
})

output$saveArea <- renderUI({
  if(length(regionZero) > 0 ) {
    elements <- list()
    for (i in 1:length(regionZero)) {
      elements[[i]] <- dashboardLabel(regionZero[i], status = 'success', style = 'square')
    }
    tagList(elements)
  } else {
    tagList(tags$b('感染者0の地域'), dashboardLabel(lang[[langCode]][73], status = 'info', style = 'square')) # なし
  }
})