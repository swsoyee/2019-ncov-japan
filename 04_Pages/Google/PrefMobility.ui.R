fluidRow(
  boxPlus(
    title = tagList(icon("google"), i18n$t("コミュニティモビリティレポート")),
    width = 12,
    closable = F,
    footer = tags$small(
      tags$a(href = "https://www.google.com/covid19/mobility/", 
             icon("file-medical-alt"),
             "Google Community Mobility Reports"),
      "取り急ぎバージョン V 0.1"
    ),
    fluidRow(
      column(
        width = 6,
        dataTableOutput("googleMobilityTable") %>% withSpinner()
      ),
      column(
        width = 6,
        radioGroupButtons(
          inputId = "prefMobility",
          label = i18n$t("自治体"),
          size = "sm",
          choices = c("全国", provinceCode$`name-ja`),
          status = "danger"
        ),
        uiOutput("mobilityCalendar") %>% withSpinner(proxy.height = "400px")
      )
    )
  )
)