tabPanel(
  # PCR検査数推移
  title = i18n$t("PCR検査数の推移"),
  icon = icon("vials"),
  value = "pcr",
  fluidRow(
    column(
      width = 8,
      tags$br(),
      fluidRow(
        column(
          width = 4,
          sliderInput(
            inputId = "testDaySpan",
            label = i18n$t("移動平均時間間隔"),
            min = 1,
            max = 10,
            value = 7,
            ticks = F,
            step = 1,
            post = i18n$t("日")
          )
        ),
        column(
          width = 8,
          pickerInput(
            inputId = "pcrRegionSelection",
            label = i18n$t("表示選択"),
            choices = setNames(
              c("国内", "チャーター便", "空港検疫", "クルーズ船"),
              c(i18n$t("国内"), i18n$t("チャーター便"), i18n$t("空港検疫"), i18n$t("クルーズ船"))
            ),
            selected = c("国内", "チャーター便", "空港検疫", "クルーズ船"),
            options = list(
              `actions-box` = TRUE,
              size = 10,
              `deselect-all-text` = i18n$t("クリア"),
              `select-all-text` = i18n$t("全部"),
              `selected-text-format` = i18n$t("三件以上選択されました"),
              `max-options` = 5
            ),
            multiple = T
          )
        )
      ),
      echarts4rOutput("pcrLine") %>% withSpinner()
    ),
    column(
      width = 4,
      tagList(
        tags$br(),
        tags$b(i18n$t("注意事項")),
        tags$li(i18n$t("「令和２年３月４日版」以後は、陽性となった者の濃厚接触者に対する検査も含めた検査実施人数を都道府県に照会し、回答を得たものを公表している。なお、国内事例のPCR検査実施人数は、疑似症報告制度の枠組みの中で報告が上がった数を計上しており、各自治体で行った全ての検査結果を反映しているものではない（退院時の確認検査などは含まれていない）。")),
        tags$li(i18n$t("これまで延べ人数で公表されていたクルーズ船のＰＣＲ検査の結果については、３月５日以後、実員数で精査された結果になったため、３月５日のデータで下方修正されています。")),
        tags$br(),
        tags$a(
          href = "https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/0000121431_00086.html",
          icon("link"),
          i18n$t("報道発表一覧（新型コロナウイルス）")
        ),
        tags$hr(),
        tags$b(i18n$t("PCR検査人数（日次）"))
      ),
      echarts4rOutput("pcrCalendar", height = "130px") %>% withSpinner()
    )
  )
)
