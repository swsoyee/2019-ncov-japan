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
          tags$p(tags$b(i18n$t("クルーズ・チャーター便事例の表示"))),
          switchInput(
            inputId = "showShipInPCR",
            label = icon("ship"),
            offLabel = icon("eye-slash"),
            onLabel = icon("eye"),
            value = F,
            inline = T
          ),
          switchInput(
            inputId = "showFlightInPCR",
            label = icon("plane"),
            offLabel = icon("eye-slash"),
            onLabel = icon("eye"),
            value = T,
            inline = T
          )
        ),
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
        tags$li(i18n$t("これまで延べ人数で公表しましたクルーズ船のＰＣＲ検査の結果について、３月５日以後に実員数で精査した結果になり、３月５日のデータを下方修正しました。")),
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
