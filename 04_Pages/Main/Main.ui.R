fluidPage(
  Component.Notification(
    context = paste0(
      "当サイト使っているサーバーの性能が限られているため、一部のキャッシュをブラウザーに保存しております。",
      "画面表示がおかしくなったり、数値が更新されていない場合はリロードまたはキャッシュをクリアして再度アクセスしてください。"
    )
  ),
  # メイン部分、Valueboxを含むなど
  source(
    file = paste0(COMPONENT_PATH, "/Main/FirstRow.ui.R"),
    local = T,
    encoding = "UTF-8"
  )$value,
  fluidRow(
    boxPlus(
      title = tagList(
        icon("map-marked-alt"),
        i18n$t("各都道府県の状況")
      ),
      closable = F,
      collapsible = T,
      width = 12,
      tabsetPanel(
        # 感染マップ、都道府県の情況のテーブル
        source(
          file = paste0(COMPONENT_PATH, "/Main/ConfirmedMap.ui.R"),
          local = T,
          encoding = "UTF-8"
        )$value,
        # 各都道府県のPCR検査数
        source(
          file = paste0(COMPONENT_PATH, "UiTabRegionPCR.R"),
          local = T,
          encoding = "UTF-8"
        )$value,
        # 感染者数ヒートマップ
        tabPanel(
          title = tagList(icon("th"), i18n$t("感染者数ヒートマップ")),
          fluidRow(
            column(width = 9,
                   uiOutput("confirmedHeatmapWrapper") %>% withSpinner(proxy.height = "600px")
            ),
            column(width = 3,
                   tags$div(
                     radioGroupButtons(
                       inputId = "confirmedHeatmapSelector",
                       label = i18n$t("ヒートマップ選択"),
                       size = "sm", justified = T,
                       choices = list("日次新規" = "confirmedHeatmap",
                                      "倍加時間" = "confirmedHeatmapDoublingTime"), 
                       status = "danger"
                     ),
                     style = "margin-top:5px;"
                   ),
                   uiOutput("confirmedHeatmapDoublingTimeOptions")
            )
          )
        ),
        # 市レベルの感染者数
        tabPanel(
          title = tagList(icon("grip-horizontal"), i18n$t("市区町村の感染者数")),
          echarts4rOutput("confirmedCityTreemap", height = "600px") %>% withSpinner()
        )
      ),
      tags$hr(),
      # 各カテゴリの合計と増加分表示の説明ブロック
      source(
        file = paste0(COMPONENT_PATH, "Main/DescriptionValue.ui.R"),
        local = T,
        encoding = "UTF-8"
      )$value,
      footer = tags$small(paste(
        i18n$t("更新時刻"), UPDATE_DATETIME, i18n$t("開発＆調整中")
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
    Button.clusterTab(),
  )
)