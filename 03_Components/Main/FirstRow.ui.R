fluidRow(
  column(
    width = 5,
    style = "padding:0px;",
    widgetUserBox(
      title = i18n$t("新型コロナウイルス"),
      subtitle = i18n$t("Coronavirus disease 2019 (COVID-19)"),
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
        tags$img(src = "https://img.shields.io/badge/dynamic/json?url=https://cdn.covid-2019.live/static/stats.json&label=PV&query=$.result.totals.pageviews.all&color=orange&style=flat-square")
      ),
      # 発熱や上気道症状を引き起こすウイルス...
      tags$p(i18n$t("「新型コロナウイルス（SARS-CoV2）」はコロナウイルスのひとつです。コロナウイルスには、一般の風邪の原因となるウイルスや、「重症急性呼吸器症候群（ＳＡＲＳ）」や2012年以降発生している「中東呼吸器症候群（ＭＥＲＳ）」ウイルスが含まれます。")),
      tagList(
        tags$small(
          tags$a(
            href = lang[[langCode]][21], # https://www.mhlw.go.jp/stf/...
            icon("external-link-alt"),
            i18n$t("「新型コロナウイルス」はどのようなウイルスですか（厚生労働省）")
          ),
          tags$a(
            href = lang[[langCode]][59], # https://phil.cdc.gov/Details.aspx?pid=2871
            icon("image"),
            i18n$t("背景画像")
          )
        )
      )
    )
  ),
  column(
    width = 7,
    fluidRow(
      Component.MainValueBox(
        mainValue = sum(mhlwSummary[日付 == max(日付)]$検査人数),
        mainValueSub = getFileUpdateTime(mhlwSummaryPath),
        sparklineName = "pcrSparkLine",
        diffNumber = (sum(mhlwSummary[日付 == max(日付)]$検査人数) - sum(mhlwSummary[日付 == max(日付) - 1]$検査人数, na.rm = T)),
        text = i18n$t("検査人数"),
        icon = "vials",
        color = "yellow"
      ),
      Component.MainValueBox(
        mainValue = TOTAL_JAPAN,
        mainValueSub = LATEST_UPDATE,
        sparklineName = "confirmedSparkLine",
        diffNumber = TOTAL_JAPAN_DIFF,
        text = i18n$t("感染者数"),
        icon = "procedures",
        color = "red"
      )
    ),
    fluidRow(
      Component.MainValueBox(
        mainValue = sum(mhlwSummary[日付 == max(日付)]$退院者),
        # 退院者 / (PCR 陽性者 - クルーズ船帰国の40名 - 死亡者)
        mainValueSub = paste0(round(sum(mhlwSummary[日付 == max(日付)]$退院者) / 
          (sum(mhlwSummary[日付 == max(日付)]$陽性者) - 40 - sum(mhlwSummary[日付 == max(日付)]$死亡者, na.rm = T)) * 100, 2), "%"),
        sparklineName = "dischargeSparkLine",
        diffNumber = (sum(mhlwSummary[日付 == max(日付)]$退院者) - sum(mhlwSummary[日付 == max(日付) - 1]$退院者, na.rm = T)),
        text = i18n$t("回復者数"),
        icon = "user-shield",
        color = "green"
      ),
      Component.MainValueBox(
        mainValue = DEATH_JAPAN,
        mainValueSub = paste0(round(100 * DEATH_JAPAN / TOTAL_JAPAN, 2), "%"),
        sparklineName = "deathSparkLine",
        diffNumber = DEATH_JAPAN_DIFF,
        text = i18n$t("死亡者数"),
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
          inputId = "chineseVersion",
          label = "🇨🇳中文",
          onclick = sprintf(
            "window.open('%s')",
            "https://covid-2019.live/cn"
          )
        ),
        actionButton(
          inputId = "englishVersion",
          label = "🇺🇸English",
          onclick = sprintf(
            "window.open('%s')",
            "https://covid-2019.live/en"
          )
        )
      )
    ))
  )
)
