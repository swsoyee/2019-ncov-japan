# 実効再生産数
tabPanel(
  title = tagList(
    icon("chart-line"), 
    i18n$t("実効再生産数"),
    boxLabel("New", status = "warning")
  ),
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
        height = "400px"
      ) %>%
        withSpinner()
    ),
    column(
      width = 4,
      pickerInput(
        inputId = "presetRtLineOption",
        label = i18n$t("プリセット"),
        choices = list(
          "Hiroshi Nishiura et al., 2020" = "nishiura",
          "Sheikh Taslim Ali et al., 2020" = "ali"
        ),
        options = list(
          style = "btn-danger"
        ),
        choicesOpt = list(
          content = c(
            "Hiroshi Nishiura et al., 2020 <sup>[2]</sup>",
            "Sheikh Taslim Ali et al., 2020 <sup>[3]</sup>"
          )
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
  ),
  fluidRow(
    socialBox(
      width = 12,
      title = tagList(icon("graduation-cap"), i18n$t("参考文献")),
      headerBorder = FALSE,
      boxComment(
        title = tags$a(
          href = "https://academic.oup.com/aje/article/178/9/1505/89262",
          "1. A new framework and software to estimate time-varying reproduction numbers during epidemics.")
        ,
        date = "American journal of epidemiology 178.9 (2013): 1505-1512.",
        image = "paper_cover/aje178_9.cover.gif",
        "Anne Cori, Neil M. Ferguson, Christophe Fraser, and Simon Cauchemez"  
      ),
      boxComment(
        title = tags$a(
          href = "https://www.ijidonline.com/article/S1201-9712(20)30119-3/fulltext",
          "2. Serial interval of novel coronavirus (COVID-19) infections."
        ),
        date = "International journal of infectious diseases 93 (2020): 284-286.",
        image = "paper_cover/gr1.jpg",
        "Nishiura, Hiroshi, Natalie M. Linton, and Andrei R. Akhmetzhanov."  
      ),
      boxComment(
        title = tags$a(
          href = "https://science.sciencemag.org/content/369/6507/1106",
          "3. Serial interval of SARS-CoV-2 was shortened over time by nonpharmaceutical interventions."
        ),
        date = "Science 369.6507 (2020): 1106-1109.",
        image = "paper_cover/F1.medium.gif",
        "Sheikh Taslim Ali, Lin Wang, Eric H. Y. Lau, Xiao-Ke Xu, Zhanwei Du, Ye Wu, Gabriel M. Leung, and Benjamin J. Cowling"
      )
    )
  )
)
