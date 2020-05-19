fluidPage(
  fluidRow(
    column(
      width = 6, style = "padding:0px;",
      widgetUserBox(
        title = i18n$t("福岡県"),
        subtitle = i18n$t("九州地方"),
        width = 12,
        # src = 'Pref/aomori.png',
        type = 2,
        color = "aqua-active",
        collapsible = F,
        sprintf(
          i18n$t("こちらは%sの発生状況をまとめたページです。厚労省のまとめより早く状況を把握できますが、県の集計時間は厚労省の発表時間と完全に一致していないため、タイムラグによる数値の違いが生じる可能性もありますので、予めご注意ください。また、速報では陰性から再び陽性になった人は再計算に含めていないため、自治体発表の陽性者数と数値が異なる場合があります。"),
          i18n$t("福岡県")
        ),
        footer = tagList(
          tags$small(
            icon("github"),
            tags$a(
              href = "https://ckan.open-governmentdata.org/organization/fukuoka-pref",
              i18n$t("自治体オープンデータのCKAN")
            )
          )
        )
      )
    ),
    column(
      width = 6,
      # uiOutput("MiyagiValueBoxes") %>% withSpinner(proxy.height = "200px")
    )
  ),
  fluidRow(
    boxPlus(
      width = 12,
      closable = F,
      title = tagList(icon("chart-line"), sprintf(i18n$t("%sの発生状況"), i18n$t("福岡県"))),
      fluidRow(
        column(
          width = 6,
          # echarts4rOutput("FukuokaContact") %>% withSpinner()
        ),
        column(
          width = 6,
          echarts4rOutput("FukuokaInfectedRoute") %>% withSpinner()
        )
      ),
      fluidRow(
        column(
          width = 6,
          # echarts4rOutput("FukuokaContact") %>% withSpinner()
        ),
        column(
          width = 6,
          echarts4rOutput("FukuokaResidentialTreeMap") %>% withSpinner()
        )
      ),
      footer = tags$small(icon("lightbulb"), i18n$t("凡例クリックすると表示・非表示の切替ができます。"))
    )
  ),
  fluidRow(
    boxPlus(
      width = 12,
      closable = F,
      collapsed = T,
      collapsible = T,
      enable_label = T,
      label_text = tagList("クリックして", icon("hand-point-right")),
      label_status = "warning",
      title = tagList("県内の感染者"),
      # fluidRow(
      #   column(
      #     width = 8,
      #     # leafletOutput('hokkaidoConfirmedMap', height = '500px') %>% withSpinner(),
      #     # dataTableOutput('hokkaidoPatientTable') %>% withSpinner(),
      #   ),
      #   column(
      #     width = 4,
      #     # uiOutput('hokkaidoProfile') %>% withSpinner()
      #   )
      # ) # ,
      fluidRow(
        column(
          width = 8,
          echarts4rOutput('FukuokaCluster', height = "600px") %>% withSpinner(proxy.height = "600px")
        )
      ),
      fluidRow(
        column(
          width = 12,
          dataTableOutput("fukuokaPatientTable") %>% withSpinner()
        )
      )
    )
  )
)
