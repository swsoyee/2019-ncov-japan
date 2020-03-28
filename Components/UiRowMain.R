fluidRow(
  column(width = 7, style='padding:0px;',
         widgetUserBox(
           title = lang[[langCode]][17],
           # 新型コロナウイルス
           subtitle = lang[[langCode]][18],
           # 2019 nCoV
           width = 12,
           type = NULL,
           src = 'ncov.jpeg',
           color = "purple",
           collapsible = F,
           background = T,
           backgroundUrl = 'ncov_back.jpg',
           # tags$p(dashboardLabel(status = 'danger',  # APIアクセスできなかった
           #                       style = 'square', 
           #                       paste(sep = ' | ', lang[[langCode]][71], # ページ閲覧数
           #                             statics$result$totals$pageviews$all)
           #                       ),
           #        dashboardLabel(status = 'success',
           #                       style = 'square',
           #                       paste(sep = ' | ', lang[[langCode]][72], # 閲覧者数
           #                             statics$result$totals$uniques)
           #        )
           #        ),
           tags$p(tags$img(src = 'https://img.shields.io/badge/dynamic/json?url=https://stg.covid-2019.live/ncov-static/stats.json&label=%E9%96%B2%E8%A6%A7%E6%95%B0&query=$.result.totals.pageviews.all&color=orange&style=flat-square')),
           # 発熱や上気道症状を引き起こすウイルス...
           tags$p(lang[[langCode]][19]),
           footer = tagList(
             tags$a(href = lang[[langCode]][21], # https://www.mhlw.go.jp/stf/...
                    icon('link'), 
                    paste0(lang[[langCode]][22], # コロナウイルスはどのようなウイルスですか？
                           '（', lang[[langCode]][5], # 厚生労働省
                           '）、 ')),
             tags$a(href = lang[[langCode]][59], # https://phil.cdc.gov/Details.aspx?pid=2871
                    icon('image'), 
                    # 背景画像
                    lang[[langCode]][58])
           )
         )
  ),
  column(
    width = 5,
    fluidRow(
      valueBox(
        width = 6,
        value = sum(PCR_WITHIN$final, PCR_FLIGHT$final, PCR_SHIP$final, PCR_AIRPORT$final),
        subtitle = paste0(lang[[langCode]][90], ' (', 
                          getDiffValueAndSign(sum(PCR_WITHIN$diff, PCR_FLIGHT$diff, PCR_SHIP$diff, PCR_AIRPORT$diff)),
                          ')'),
        icon = icon('vials'),
        color = "yellow"
      ),
      valueBox(
        width = 6,
        value = TOTAL_JAPAN,
        subtitle = paste0(lang[[langCode]][60], ' (+', TOTAL_JAPAN_DIFF, ')'),
        icon = icon('procedures'),
        color = "red"
      )
    ),
    fluidRow(
      valueBox(
        width = 6,
        value = DISCHARGE_TOTAL,
        subtitle = paste0(lang[[langCode]][6],
                          ' (+', DISCHARGE_DIFF, ')'),
        icon = icon('user-shield'),
        color = "green"
      ),
      valueBox(
        width = 6,
        value = DEATH_JAPAN,
        subtitle = paste0(lang[[langCode]][7], ' (+', DEATH_JAPAN_DIFF, ')'),
        icon = icon('bible'),
        color = "navy"
      )
    ),
    fluidRow(
      column(width = 12, style='padding:0px;',
             boxPlus(
               width = 12,
               actionButton(inputId = 'twitterShare',
                            label = 'Twitter',
                            icon = icon('twitter'),
                            onclick = sprintf("window.open('%s')", twitterUrl)
               ),
               actionButton(inputId = 'github',
                            label = 'Github',
                            icon = icon('github'),
                            onclick = sprintf("window.open('%s')", 'https://github.com/swsoyee/2019-ncov-japan')
               )
             )
      )
    )
  )
)