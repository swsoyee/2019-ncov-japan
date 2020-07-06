fluidRow(
  boxPlus(
    width = 12,
    closable = F,
    title = tagList(icon("globe"), "World Map"),
    fluidRow(
      column(
        width = 8,
        fluidRow(
          column(
            width = 9,
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
            )
          ),
          column(
            width = 3,
            switchInput(
              inputId = "switchWorldMapVersion",
              value = T,
              onLabel = i18n$t("シンプル"),
              onStatus = "danger",
              offStatus = "danger",
              offLabel = i18n$t("詳細"),
              label = i18n$t("表示モード"),
              inline = T,
              size = "small",
              width = "300px",
              labelWidth = "200px",
              handleWidth = "100px"
            ),
          )
        ),
        uiOutput("worldConfirmedDateSelector"),
        echarts4rOutput("worldConfirmed", height = "600px") %>% withSpinner()
      ),
      column(
        width = 4,
        echarts4rOutput("countryLine", height = "350px") %>% withSpinner(),
        echarts4rOutput("countryTestLine", height = "350px") %>% withSpinner()
      )
    )
  ),
  boxPlus(
    width = 12,
    closable = F,
    title = "Summary",
    dataTableOutput("worldSummaryTable") %>% withSpinner()
  )
)
