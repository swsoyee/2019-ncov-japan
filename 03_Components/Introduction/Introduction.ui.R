column(
    width = 5,
    style = "padding:0px;",
    userBox(
      title = userDescription(
        title = i18n$t("新型コロナウイルス"),
        subtitle = i18n$t("Coronavirus disease 2019 (COVID-19)"),
        image = "ncov.jpeg",
        backgroundImage = "ncov_back.jpg"
      ),
      width = 12,
      closable = FALSE,
      collapsible = FALSE,
      # tags$p(boxLabel(status = 'danger',  # APIアクセスできなかった
      #                       style = 'square',
      #                       paste(sep = ' | ', lang[[langCode]][71], # ページ閲覧数
      #                             statics$result$totals$pageviews$all)
      #                       ),
      #        boxLabel(status = 'success',
      #                       style = 'square',
      #                       paste(sep = ' | ', lang[[langCode]][72], # 閲覧者数
      #                             statics$result$totals$uniques)
      #        )
      #        ),
      tags$p(
        tags$img(src = "https://img.shields.io/badge/dynamic/json?url=https://cdn.covid-2019.live/static/stats.json&label=PV&query=$.result.totals.pageviews.all&color=orange&style=flat-square"),
        tags$a(
          href = "https://github.com/swsoyee/2019-ncov-japan",
          tags$img(src = "https://img.shields.io/github/stars/swsoyee/2019-ncov-japan?style=social", style="float:right;")
        )
      ),
      # 発熱や上気道症状を引き起こすウイルス...
      footer = tagList(
        tags$p(
          i18n$t("「新型コロナウイルス（SARS-CoV2）」はコロナウイルスのひとつです。コロナウイルスには、一般の風邪の原因となるウイルスや、「重症急性呼吸器症候群（ＳＡＲＳ）」や2012年以降発生している「中東呼吸器症候群（ＭＥＲＳ）」ウイルスが含まれます。")
        ),
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
  )