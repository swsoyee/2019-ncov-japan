fluidRow(
  boxPlus(
    title = "コミュニティモビリティレポート",
    width = 12,
    closable = F,
    footer = tags$small("取り急ぎバージョン V 0.1"),
    fluidRow(
      column(
        width = 6,
        radioGroupButtons(
          inputId = "prefMobility",
          label = "自治体",
          size = "sm",
          choices = c("全国", provinceCode$`name-ja`), 
          status = "danger"
        ),
        uiOutput("mobilityCalendar") %>% withSpinner(proxy.height = "400px")
      )
    )
  )
)