output$todayConfirmed <- renderUI({
  if (length(HAS_TODAY_CONFIRMED) > 0) {
    elements <- list()
    for (i in 1:length(HAS_TODAY_CONFIRMED)) {
      elements[[i]] <- dashboardLabel(paste(
        i18n$t(names(HAS_TODAY_CONFIRMED[i])),
        "+",
        HAS_TODAY_CONFIRMED[i]
      ),
      status = "danger", style = "square"
      )
    }
    tagList(tags$b(i18n$t("本日新規")), elements)
  } else {
    tagList(
      tags$b(i18n$t("本日新規")),
      dashboardLabel(i18n$t("なし"), status = "danger", style = "square")
    )
  }
})

output$todayDeath <- renderUI({
  if (length(HAS_TODAY_DEATH) > 0) {
    elements <- list()
    for (i in 1:length(HAS_TODAY_DEATH)) {
      elements[[i]] <- dashboardLabel(paste(
        i18n$t(names(HAS_TODAY_DEATH[i])),
        "+",
        HAS_TODAY_DEATH[i]
      ),
      status = "primary", style = "square"
      )
    }
    tagList(tags$b(i18n$t("本日新規")), elements)
  } else {
    tagList(
      tags$b(i18n$t("本日新規")),
      dashboardLabel(i18n$t("なし"), status = "primary", style = "square")
    )
  }
})

output$saveArea <- renderUI({
  # 感染者なしの地域
  dt <- simpleMapDataset()
  regionZero <- dt[order(regions)][active == 0, ja]
  if (length(regionZero) > 0) {
    elements <- list()
    for (i in 1:length(regionZero)) {
      elements[[i]] <- dashboardLabel(i18n$t(regionZero[i]), status = "success", style = "square")
    }
    tagList(elements)
  } else {
    tagList(tags$b("感染者0の地域"), dashboardLabel(i18n$t("なし"), status = "info", style = "square")) # なし
  }
})