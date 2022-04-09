fluidPage(
  # Component.Notification(
  #   status = "danger",
  #   context = paste0(
  #     "当サイト使っているサーバーの性能が限られているため、一部のキャッシュをブラウザーに保存しております。",
  #     "画面表示がおかしくなったり、数値が更新されていない場合はリロードまたはキャッシュをクリアして再度アクセスしてください。",
  #   )
  # ),
  # メイン部分、Valueboxを含むなど
  source(
    file = paste0(COMPONENT_PATH, "/Main/FirstRow.ui.R"),
    local = T,
    encoding = "UTF-8"
  )$value,
  if (envSetting == "dev") {
    source(
      file = paste0(COMPONENT_PATH, "/CurrentStatus/CurrentBox.ui.R"),
      local = T,
      encoding = "UTF-8"
    )$value
  },
  fluidRow(
    uiOutput("surveyBtn"),
    box(
      title = tagList(
        icon("map-marked-alt"),
        i18n$t("各都道府県の状況")
      ),
      closable = F, 
      label = boxLabel(
        i18n$t("実況中"), 
        status = "info"
      ),
      collapsible = T,
      width = 12,
      tabsetPanel(
        # 感染マップ、都道府県の情況のテーブル
        id = "main_tabset",
        source(
          file = paste0(COMPONENT_PATH, "/Main/ConfirmedMap.ui.R"),
          local = T,
          encoding = "UTF-8"
        )$value,
        # 実効再生産数
        source(
          file = paste0(COMPONENT_PATH, "/Main/RtLine.ui.R"), 
          local = TRUE,
          encoding = "UTF-8"
        )$value,
        # 各都道府県の比較
        source(
          file = paste0(COMPONENT_PATH, "/Main/ComparePref.ui.R"),
          local = T,
          encoding = "UTF-8"
        )$value,
        # 感染者数ヒートマップ
        tabPanel(
          title = tagList(icon("th"), i18n$t("感染者数ヒートマップ")),
          fluidRow(
            column(
              width = 9,
              uiOutput("confirmedHeatmapWrapper") %>% withSpinner(proxy.height = "600px")
            ),
            column(
              width = 3,
              tags$div(
                radioGroupButtons(
                  inputId = "confirmedHeatmapSelector",
                  label = i18n$t("ヒートマップ選択"),
                  size = "sm", justified = T,
                  choiceNames = c(i18n$t("日次新規"), i18n$t("倍加時間")),
                  choiceValues = list("confirmedHeatmap", "confirmedHeatmapDoublingTime"),
                  status = "danger"
                ),
                style = "margin-top:5px;"
              ),
              uiOutput("confirmedHeatmapDoublingTimeOptions")
            )
          )
        )# ,
        # # 市レベルの感染者数
        # tabPanel(
        #   title = tagList(icon("grip-horizontal"), i18n$t("市区町村の感染者数")),
        #   echarts4rOutput("confirmedCityTreemap", height = "600px") %>% withSpinner()
        # )
      ),
      tags$hr(),
      # 各カテゴリの合計と増加分表示の説明ブロック
      source(
        file = paste0(COMPONENT_PATH, "Main/DescriptionValue.ui.R"),
        local = T,
        encoding = "UTF-8"
      )$value,
      footer = tags$small(paste(
        i18n$t("更新時刻"), UPDATE_DATETIME
      ))
    ),
  ),
  fluidRow(
    Component.Tendency()
  ),
  fluidRow(
    Component.ComfirmedPyramid(),
    Component.SymptomsProgression()
  ),
  fluidRow(
    Component.NewsList(),
    column(
      width = 8,
      actionButton(
        width = "100%",
        inputId = "gotoRoutePage",
        style = paste0("color: #fff; background-color: ", middleYellow),
        label = tagList(
          i18n$t("感染ルート・クラスターへ"),
          boxLabel(
            "Archived",
            status = "danger"
          )
        ),
        icon = icon("connectdevelop")
      )
    )#,
    # column(
    #   width = 4,
    #   actionButton(
    #     width = "100%",
    #     inputId = "gotoECMOPage",
    #     style = paste0("color: #fff; background-color: ", darkNavy),
    #     label = tagList(
    #       i18n$t("ECMOnet・重症患者状況へ")
    #     ),
    #     icon = icon("hospital")
    #   )
    # )
  )
)
