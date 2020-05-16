fluidRow(
  boxPlus(
    width = 12, closable = F,
    title = tagList(icon("chart-line"), "COVID-19 重症患者状況　日本COVID-19対策ECMOnet集計"),
    tags$p("このページは、", 
           tags$a(
             icon("external-link-alt"), 
             "COVID-19 重症患者状況　日本COVID-19対策ECMOnet集計", 
             href = "https://covid19.jsicm.org/"), 
           "のデータ（文言を含む）を一覧できるように、若干異なる可視化方法でデータを表現しています。"
           ),
    blockQuote(
      tags$small(
        "このグラフ群は横断的ICU情報探索システム(CRoss Icu Searchable Information System, 略称CRISIS, 非公開) に蓄積されたデータベースを視覚化したものです。このCRISISには日本集中治療医学会専門医認定施設、日本救急医学会救急科専門医指定施設を中心に日本全国570以上の施設が参加されており、それら施設の総ICUベッド数は5500にのぼり、日本全体のICUベッド（6500ベッドほど）の80％をカバーしております。本事業は各病院担当者の方々の善意により忙しい合間を縫って任意に手入力いただいているものです。そのため精度はかなり高いと存じますが完璧なものではないことをご理解いただければ幸いです。当初我々はECMOに関するデータを中心に集めて参りました。しかしながら人工呼吸器を必要とする重症の方々のデータも必要であると改めて認識し、データの精度を高めるよう努力しております。少しずつではございますが改善させ、このコロナ禍を乗り切った暁には重要な資産として次の世代に遺せるものを目指しております。　日本COVID-19対策ECMOnet　2020/5/1記載
        ")
      ),
    accordion(
      accordionItem(
        id = 11,
        title = tagList(icon("first-aid"), "COVID-19重症者における人工呼吸器装着数の推移"),
        collapsed = F,
        uiOutput("artificialRespirators") %>% withSpinner()
      ),
      accordionItem(
        id = 12,
        title = tagList(icon("heartbeat"), i18n$t("COVID-19重症者におけるECMO装着数の推移")),
        collapsed = T,
        uiOutput("ecmoUsing") %>% withSpinner()
      ),
      accordionItem(
        id = 13,
        title = tagList(icon("file-medical"), i18n$t("国内のCOVID-19に対するECMO治療の成績累計")),
        collapsed = T,
        fluidRow(
          column(
            width = 4,
            tags$br(),
            tags$b(icon("exclamation-circle"), i18n$t("注意事項")),
            blockQuote(
              tags$small(
                i18n$t("この図はCRISISに申告のあった症例と、それ以外に我々のネットワークで集めたECMO症例の推移をあわらしたものです。あとから判明した症例も多くありますので、過去にさかのぼって日々数が変異しております。したがって上の図の数とここに表す数にも若干の齟齬が生じますのでご了承ください。人工呼吸が必要な患者さんのほぼ5人に1人がECMOも必要と判断されます。ECMOからの生還例ではおおよそ10日間から2週間のECMO装着が必要となります。ーー2020/5/1記載")
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
  )
)
