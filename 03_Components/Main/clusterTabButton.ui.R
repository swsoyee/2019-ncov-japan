Button.clusterTab <- function() {
  column(
    width = 8,
    actionButton(
      width = "100%",
      inputId = "gotoRoutePage",
      style = paste0("color: #fff; background-color: ", middleRed),
      label = tagList(
        i18n$t("感染ルート・クラスターへ"),
        # Beta xx
        dashboardLabel(
          lang[[langCode]][121],
          status = "warning"
        )
      ),
      icon = icon("connectdevelop")
    )
  )
}