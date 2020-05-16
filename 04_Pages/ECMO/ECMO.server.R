observeEvent(input$sideBarTab, {
  if (input$sideBarTab == "ecmo" && is.null(GLOBAL_VALUE$ECMO[[1]])) {
    GLOBAL_VALUE$ECMO <- list(
      ecmoUising = fread(paste0(DATA_PATH, "Collection/ecmoUsing.", languageSetting,".csv")),
      ecmo = fread(paste0(DATA_PATH, "Collection/ecmo.csv")),
      artificialRespirators = fread(paste0(DATA_PATH, "Collection/artificialRespirators.", languageSetting,".csv"))
    )

    startIndex <- 1
    groupList <- list(
      "北海道・東北" = c(1, startIndex + 1:7),
      "関東" = c(1, startIndex + 8:14),
      "中部" = c(1, startIndex + 15:23),
      "近畿" = c(1, startIndex + 24:30),
      "中国" = c(1, startIndex + 31:35),
      "四国" = c(1, startIndex + 36:39),
      "九州・沖縄" = c(1, startIndex + 40:47)
    )
    names(groupList) <- c(
      i18n$t("北海道・東北"),
      i18n$t("関東"),
      i18n$t("中部"),
      i18n$t("近畿"),
      i18n$t("中国"),
      i18n$t("四国"),
      i18n$t("九州・沖縄")
    )

    for (index in seq(length(groupList))) {
      local({
        i <- index
        # 人工呼吸器
        output[[paste0("artificialRespirators_", i)]] <- renderEcharts4r({
          plot <- melt(GLOBAL_VALUE$ECMO$artificialRespirators[, groupList[i][[1]], with = F], id.vars = "date") %>%
            group_by(variable) %>%
            e_chart(date) %>%
            e_line(value, symbol = "circle", symbolSize = 1) %>%
            e_title(text = sprintf("%s", names(groupList[i]))) %>%
            e_tooltip(trigger = "axis") %>%
            e_y_axis(
              max = 100,
              axisTick = list(show = F),
              axisLabel = list(inside = T),
              name = i18n$t("実施件数"),
              nameTextStyle = list(padding = c(0, 0, 0, nchar(i18n$t("実施件数")) * 7 + 10)),
              splitLine = list(lineStyle = list(opacity = 0.2))
            ) %>%
            e_legend(
              type = "scroll",
              orient = "vertical",
              left = "18%",
              top = "15%",
              right = "15%"
            ) %>%
            e_grid(right = "2%", left = "2%") %>%
            e_group("artificialRespirators")

          if (index == max(length(groupList))) {
            plot %>% e_connect_group("artificialRespirators")
          } else {
            plot
          }
        })
        # ECMO
        output[[paste0("ecmoUsing_", i)]] <- renderEcharts4r({
          plot <- melt(GLOBAL_VALUE$ECMO$ecmoUising[, groupList[i][[1]], with = F], id.vars = "date") %>%
            group_by(variable) %>%
            e_chart(date) %>%
            e_line(value, symbol = "circle", symbolSize = 1) %>%
            e_title(text = sprintf("%s", names(groupList[i]))) %>%
            e_tooltip(trigger = "axis") %>%
            e_y_axis(
              max = 20,
              axisTick = list(show = F),
              axisLabel = list(inside = T),
              name = i18n$t("実施件数"),
              nameTextStyle = list(padding = c(0, 0, 0, nchar(i18n$t("実施件数")) * 7 + 10)),
              splitLine = list(lineStyle = list(opacity = 0.2))
            ) %>%
            e_legend(
              type = "scroll",
              orient = "vertical",
              left = "18%",
              top = "15%",
              right = "15%"
            ) %>%
            e_grid(right = "2%", left = "2%") %>%
            e_group("ecmoUsing")

          if (index == max(length(groupList))) {
            plot %>% e_connect_group("ecmoUsing")
          } else {
            plot
          }
        })
      })
    }
  }
  # artificialRespirators = fread(paste0(DATA_PATH, "/Collection/artificialRespirators.csv")) # TEST
})


output$artificialRespirators <- renderUI({
  style <- "padding-left:3px; padding-right:3px; padding-top:1px; padding-bottom:1px"
  tagList(
    fluidRow(
      column(
        3,
        tags$br(),
        tags$b(icon("exclamation-circle"), i18n$t("注意事項")),
        blockQuote(tags$small("これらのグラフはCRISISに申告された人工呼吸が必要な重症患者さんの推移を地方別、都道府県別に示すものです。現在精度を上げるべく努力しております。全体の流れは把握していると自負しておりますが、かならずしも正確な数が示されている訳ではないことをご理解ください。COVID-19では長期の人工呼吸となる患者さんが多い傾向があります。このあたりも今後このコラムでお示ししていけるように計画しております。ーー2020/5/1記載"))
      ),
      column(3, echarts4rOutput("artificialRespirators_1"), style = style),
      column(3, echarts4rOutput("artificialRespirators_2"), style = style),
      column(3, echarts4rOutput("artificialRespirators_3"), style = "padding-left:3px; padding-top:1px; padding-bottom:1px")
    ),
    fluidRow(
      column(3, echarts4rOutput("artificialRespirators_4"), style = "padding-right:3px; padding-top:1px; padding-bottom:1px"),
      column(3, echarts4rOutput("artificialRespirators_5"), style = style),
      column(3, echarts4rOutput("artificialRespirators_6"), style = style),
      column(3, echarts4rOutput("artificialRespirators_7"), style = "padding-left:3px; padding-top:1px; padding-bottom:1px")
    )
  )
})

output$ecmoUsing <- renderUI({
  style <- "padding-left:3px; padding-right:3px; padding-top:1px; padding-bottom:1px"
  tagList(
    fluidRow(
      column(
        3,
        tags$br(),
        tags$b(icon("exclamation-circle"), i18n$t("注意事項")),
        blockQuote(tags$small(i18n$t("ECMO装着の方の多くは人工呼吸器も装着しておられるので上記と一部重複のカウントとなります。CRISISに申告のあったECMOの数の推移です。その日のECMOの稼働数とお考えください。CRISISに加入されずECMOを行っている施設も数施設ございます。ーー2020/5/1記載")))
      ),
      column(3, echarts4rOutput("ecmoUsing_1"), style = style),
      column(3, echarts4rOutput("ecmoUsing_2"), style = style),
      column(3, echarts4rOutput("ecmoUsing_3"), style = "padding-left:3px; padding-top:1px; padding-bottom:1px")
    ),
    fluidRow(
      column(3, echarts4rOutput("ecmoUsing_4"), style = "padding-right:3px; padding-top:1px; padding-bottom:1px"),
      column(3, echarts4rOutput("ecmoUsing_5"), style = style),
      column(3, echarts4rOutput("ecmoUsing_6"), style = style),
      column(3, echarts4rOutput("ecmoUsing_7"), style = "padding-left:3px; padding-top:1px; padding-bottom:1px")
    )
  )
})

output$ecmo <- renderEcharts4r({
  today <- tail(GLOBAL_VALUE$ECMO$ecmo, n = 1)
  todaySum <- sum(today[, 2:4])
  GLOBAL_VALUE$ECMO$ecmo %>%
    e_chart(日付) %>%
    e_area(死亡, name = i18n$t("死亡"),
      stack = 1, itemStyle = list(color = darkNavy),
      symbol = "circle", symbolSize = 1, smooth = T
    ) %>%
    e_area(実施中, name = i18n$t("実施中"),
      stack = 1, itemStyle = list(color = darkRed),
      symbol = "circle", symbolSize = 1, smooth = T
    ) %>%
    e_area(離脱, name = i18n$t("離脱"),
      stack = 1, itemStyle = list(color = middleGreen),
      symbol = "circle", symbolSize = 1, smooth = T
    ) %>%
    e_y_axis(
      axisTick = list(show = F),
      axisLabel = list(inside = T),
      splitLine = list(lineStyle = list(opacity = 0.2))
    ) %>%
    e_legend(
      type = "scroll",
      orient = "vertical",
      left = "18%",
      top = "15%",
      right = "15%"
    ) %>%
    e_grid(
      left = "5%",
      right = "5%"
    ) %>%
    e_tooltip(trigger = "axis") %>%
    e_title(
      text = sprintf(i18n$t("%s現在"), today$日付),
      subtext = sprintf(
        i18n$t("ECMO離脱 %s 例（%s%%）、ECMO実施中 %s 例（%s%%）、死亡 %s 例（%s%%）"),
        today$離脱, round(today$離脱 / todaySum * 100, 2),
        today$実施中, round(today$実施中 / todaySum * 100, 2),
        today$死亡, round(today$死亡 / todaySum * 100, 2)
      )
    )
})
