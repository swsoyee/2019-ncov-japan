Component.Notification <- function(status = "info", context = "") {
  return(fluidRow(
    boxPlus(
      width = 12,
      closable = T,
      enable_label = F,
      label_text = "New",
      label_status = "warning",
      solidHeader = T,
      status = status,
      title = tagList(icon("bullhorn"), i18n$t("お知らせ")),
      collapsible = T,
      collapsed = T,
      tags$small(context)
    )
  ))
}