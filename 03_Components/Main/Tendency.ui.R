Component.Tendency <- function() {
  box(
    # 国内状況推移
    title = tagList(icon("chart-line"), i18n$t("国内状況推移")),
    closable = F,
    collapsible = T,
    collapsed = F,
    enable_label = T,
    label = boxLabel(
      i18n$t("実況中"), 
      status = "info"
    ),
    footer = tags$small(icon("lightbulb"), i18n$t("凡例クリックすると表示・非表示の切替ができます。")),
    width = 12,
    tabsetPanel(
      id = "linePlot",
      # 感染者数の推移
      source(
        file = paste0(COMPONENT_PATH, "/Main/Tendency.Confirmed.ui.R"),
        local = T,
        encoding = "UTF-8"
      )$value,
      # PCR検査数推移
      source(
        file = paste0(COMPONENT_PATH, "/Main/Tendency.Test.ui.R"),
        local = T,
        encoding = "UTF-8"
      )$value,
      # 退院数推移
      source(
        file = paste0(COMPONENT_PATH, "/Main/Tendency.Discharged.ui.R"),
        local = T,
        encoding = "UTF-8"
      )$value,
      # コールセンターの対応
      source(
        file = paste0(COMPONENT_PATH, "/Main/Tendency.CallCenter.ui.R"),
        local = T,
        encoding = "UTF-8"
      )$value
    )
  )
}