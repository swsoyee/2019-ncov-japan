fluidRow(
  boxPlus(
    width = 12,
    closable = F,
    title = tagList(icon("globe"), "World Map"),
    fluidRow(
      column(
        width = 8,
        radioGroupButtons(
          inputId = "switchWorldMap",
          label = NULL,
          justified = T,
          choiceNames = c(
            paste(icon("procedures"), i18n$t("感染")),
            paste(icon("vials"), i18n$t("検査")),
            paste(icon("user-plus"), i18n$t("陽性率"))
          ),
          choiceValues = c("worldCase", "worldTest", "worldRate"),
          status = "danger"
        ),
        uiOutput("worldConfirmedDateSelector"),
        echarts4rOutput("worldConfirmed", height = "600px") %>% withSpinner()
      ),
      column(
        width = 4,
        echarts4rOutput("countryLine") %>% withSpinner()
      )
    )
  )
)
