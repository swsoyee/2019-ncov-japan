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
      title = tagList(icon("bullhorn"), "㝊知ら㝛"),
      collapsible = T,
      collapsed = T,
      tags$small(context)
    )
  ))
}