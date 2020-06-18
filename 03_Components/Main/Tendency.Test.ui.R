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
            selected = c("国内", "チャーター便", "空港検疫"),
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
        tags$li(tags$small(i18n$t("「令和2年3月4日版」以後は、陽性となった者の濃厚接触者に対する検査も含めた検査実施人数を都道府県に照会し、回答を得たものを公表しています。なお、国内事例のPCR検査実施人数は、疑似症患者（感染が疑われる者）報告制度の枠組みの中で報告された数を計上しており、各自治体で行った全ての検査結果を反映しているものではありません（退院時の確認検査などは含まず）。"))),
        tags$li(tags$small(i18n$t("これまで延べ人数で公表されていたクルーズ船のPCR検査の結果については、3月5日以後、実員数で精査された結果になったため、3月5日のデータで下方修正されています。"))),
        tags$li(tags$small(i18n$t("令和2年5月8日公表分から、データソースを従来の厚生労働省が把握した個票を積み上げたものから、各自治体がウェブサイトで公表している数等を積み上げたものに変更した。"))),
        tags$li(tags$small(
          i18n$t("一部のデータについて、マイナスになったり大きく増減しているのは、都道府県からの報告に訂正または集計されていないデータを加わった結果になります。参考："), 
          tags$a(icon("external-link-alt"), "5/13", href = "https://www.mhlw.go.jp/stf/newpage_11291.html"),
          tags$a(icon("external-link-alt"), "5/14", href = "https://www.mhlw.go.jp/stf/newpage_11311.html"),
          tags$a(icon("external-link-alt"), "5/15", href = "https://www.mhlw.go.jp/stf/newpage_11339.html"),
          tags$a(icon("external-link-alt"), "5/16", href = "https://www.mhlw.go.jp/stf/newpage_11354.html"),
          tags$a(icon("external-link-alt"), "6/18", href = "https://www.mhlw.go.jp/stf/newpage_11961.html"),
          tags$a(icon("external-link-alt"), icon("github"), href = "https://github.com/swsoyee/2019-ncov-japan/issues/389")
          ),
        ),
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
