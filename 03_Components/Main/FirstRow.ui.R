fluidRow(
  column(
    width = 5,
    style = "padding:0px;",
    widgetUserBox(
      title = lang[[langCode]][17],
      # 新型コロナウイルス
      subtitle = lang[[langCode]][18],
      # 2019 nCoV
      width = 12,
      type = NULL,
      src = "ncov.jpeg",
      color = "purple",
      collapsible = F,
      background = T,
      footer_padding = F,
      backgroundUrl = "ncov_back.jpg",
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
      tags$p(
        tags$img(src = "https://img.shields.io/badge/dynamic/json?url=https://stg.covid-2019.live/ncov-static/stats.json&label=%E9%96%B2%E8%A6%A7%E6%95%B0&query=$.result.totals.pageviews.all&color=orange&style=flat-square")
      ),
      # 発熱や上気道症状を引き起こすウイルス...
      tags$p(lang[[langCode]][19]),
      tagList(
        tags$small(
          tags$a(
            href = lang[[langCode]][21], # https://www.mhlw.go.jp/stf/...
            icon("external-link-alt"),
            paste0(
              lang[[langCode]][22], # コロナウイルスはどのようなウイルスですか？
              "（", lang[[langCode]][5], # 厚生労働省
              "）、 "
            )
          ),
          tags$a(
            href = lang[[langCode]][59], # https://phil.cdc.gov/Details.aspx?pid=2871
            icon("image"),
            # 背景画像
            lang[[langCode]][58]
          )
        )
      )
    )
  ),
  column(
    width = 7,
    fluidRow(
      Component.MainValueBox(
        mainValue = sum(
          PCR_WITHIN$final,
          PCR_FLIGHT$final,
          PCR_SHIP$final,
          PCR_AIRPORT$final
        ),
        mainValueSub = LATEST_UPDATE_DOMESTIC_DAILY_REPORT,
        sparklineName = "pcrSparkLine",
        diffNumber = dailyReport$pcrDiff[nrow(dailyReport)],
        text = lang[[langCode]][90],
        # 検査人数
        icon = "vials",
        color = "yellow"
      ),
      Component.MainValueBox(
        mainValue = TOTAL_JAPAN,
        mainValueSub = LATEST_UPDATE,
        sparklineName = "confirmedSparkLine",
        diffNumber = TOTAL_JAPAN_DIFF,
        text = lang[[langCode]][9],
        # 感染者数
        icon = "procedures",
        color = "red"
      )
    ),
    fluidRow(
      Component.MainValueBox(
        mainValue = DISCHARGE_TOTAL,
        mainValueSub = paste0(round(100 * DISCHARGE_TOTAL / TOTAL_JAPAN, 2), "%"),
        sparklineName = "dischargeSparkLine",
        diffNumber = dailyReport$dischargeDiff[nrow(dailyReport)],
        text = lang[[langCode]][6],
        # 退院者数
        icon = "user-shield",
        color = "green"
      ),
      Component.MainValueBox(
        mainValue = DEATH_JAPAN,
        mainValueSub = paste0(round(100 * DEATH_JAPAN / TOTAL_JAPAN, 2), "%"),
        sparklineName = "deathSparkLine",
        diffNumber = DEATH_JAPAN_DIFF,
        text = lang[[langCode]][07],
        # 死亡者数
        icon = "bible",
        color = "navy"
      )
    ),
    fluidRow(column(
      width = 12,
      style = "padding:0px;",
      boxPlus(
        width = 12,
        actionButton(
          inputId = "twitterShare",
          label = "Twitter",
          icon = icon("twitter"),
          onclick = sprintf("window.open('%s')", twitterUrl)
        ),
        actionButton(
          inputId = "github",
          label = "Github",
          icon = icon("github"),
          onclick = sprintf(
            "window.open('%s')",
            "https://github.com/swsoyee/2019-ncov-japan"
          )
        )
      )
    ))
  )
)
