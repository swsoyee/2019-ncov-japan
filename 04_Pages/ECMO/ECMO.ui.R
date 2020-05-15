fluidRow(
  boxPlus(
    width = 12, closable = F, collapsible = T, collapsed = F, enable_label = T, label_text = "表示",
    title = tagList(icon("first-aid"), "COVID-19重症者における人工呼吸器装着数の推移"),
    uiOutput("artificialRespirators") %>% withSpinner()
  ),
  boxPlus(
    width = 12, closable = F, collapsible = T, collapsed = T, enable_label = T, label_text = "表示",
    title = tagList(icon("heartbeat"), "COVID-19重症者におけるECMO装着数の推移"),
    uiOutput("ecmoUsing") %>% withSpinner()
  ),
  boxPlus(
    width = 12, closable = F, collapsible = T, collapsed = T, enable_label = T, label_text = "表示",
    title = tagList(icon("file-medical"), "国内のCOVID-19に対するECMO治療の成績累計")#,
    # uiOutput("artificialRespirators") %>% withSpinner()
  )
)
