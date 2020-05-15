fluidRow(
  boxPlus(
    width = 12, closable = F, collapsible = T, collapsed = F, 
    enable_label = T, label_text = tagList("表示", icon('hand-point-right')),
    title = tagList(icon("first-aid"), "COVID-19重症者における人工呼吸器装着数の推移"),
    uiOutput("artificialRespirators") %>% withSpinner()
  ),
  boxPlus(
    width = 12, closable = F, collapsible = T, collapsed = T, 
    enable_label = T, label_text = tagList("表示", icon('hand-point-right')),
    title = tagList(icon("heartbeat"), "COVID-19重症者におけるECMO装着数の推移"),
    uiOutput("ecmoUsing") %>% withSpinner()
  ),
  boxPlus(
    width = 12, closable = F, collapsible = T, collapsed = T, 
    enable_label = T, label_text = tagList("表示", icon('hand-point-right')),
    title = tagList(icon("file-medical"), "国内のCOVID-19に対するECMO治療の成績累計"),
    fluidRow(
      column(
        width = 4,
        tags$br(),
        tags$b(icon("exclamation-circle"), i18n$t("注意事項")),
        blockQuote(
          tags$small(
            "この図はCRISISに申告のあった症例と、それ以外に我々のネットワークで集めたECMO症例の推移をあわらしたものです。あとから判明した症例も多くありますので、過去にさかのぼって日々数が変異しております。したがって上の図の数とここに表す数にも若干の齟齬が生じますのでご了承ください。人工呼吸が必要な患者さんのほぼ5人に1人がECMOも必要と判断されます。ECMOからの生還例ではおおよそ10日間から2週間のECMO装着が必要となります。ーー2020/5/1記載"
          )
        )
        ),
      column(
        width = 8,
        echarts4rOutput("ecmo") %>% withSpinner()
      )
    )
  )
)
