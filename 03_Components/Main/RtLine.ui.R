# 実効再生産数
tabPanel(
  title = tagList(icon("chart-line"), i18n$t("実効再生産数")),
  fluidRow(
    style = "margin-top:10px;",
    column(
      width = 8,
      pickerInput(
        inputId = "regionRtLinePicker",
        label = i18n$t("地域選択"),
        choices = regionName[6:length(regionName)],
        selected = regionName[6:length(regionName)][1],
        options = list(
          `actions-box` = TRUE,
          size = 10,
          `deselect-all-text` = i18n$t("クリア"),
          `select-all-text` = i18n$t("全部"),
          `live-search` = T
        ),
        multiple = T,
        width = "100%"
      ),
      echarts4rOutput(
        outputId = "RtLine",
        height = "500px"
      ) %>%
        withSpinner()
    ),
    column(
      width = 4,
      pickerInput(
        inputId = "presetRtLineOption",
        label = i18n$t("プリセット"),
        choices = list(
          "Hiroshi Nishiura et al.," = "nishiura",
          "Sheikh Taslim Ali et al.," = "ali"
        ),
        options = list(
          style = "btn-danger"
        )
      ),
      sliderInput(
        inputId = "RtLineMeanSi",
        label = i18n$t("発症間隔平均値"),
        min = 2,
        value = 4.8,
        max = 21,
        step = 0.1
      ),
      sliderInput(
        inputId = "RtLineStdSi",
        label = i18n$t("発症間隔標準偏差"),
        min = 0,
        value = 2.3,
        max = 10,
        step = 0.1
      ),
      actionButton(
        width = "100%",
        inputId = "generateRtLine",
        style = paste0("color: #fff; background-color: ", middleRed),
        label = i18n$t("作成"),
        icon = icon("play")
      )
    )
  )
)
