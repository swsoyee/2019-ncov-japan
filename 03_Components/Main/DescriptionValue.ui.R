fluidRow(
  column(
    width = 2,
    descriptionBlock(
      number = "　",
      header = tagList(icon("torii-gate"), i18n$t("国内事例")),
      text = i18n$t("チャーター便を含む")
    )
  ),
  column(
    width = 1,
    id = "domesticPCR",
    descriptionBlock(
      number = sum(mhlwSummary[日付 == max(日付) & 分類 %in% 0:2]$検査人数) - sum(mhlwSummary[日付 == (max(日付) - 1) & 分類 %in% 0:2]$検査人数),
      number_color = "yellow",
      number_icon = getChangeIconWrapper(sum(mhlwSummary[日付 == max(日付) & 分類 %in% 0:2]$検査人数) - sum(mhlwSummary[日付 == (max(日付) - 1) & 分類 %in% 0:2]$検査人数), type = "fa"),
      header = sum(mhlwSummary[日付 == max(日付) & 分類 %in% 0:2]$検査人数),
      right_border = F,
      text = i18n$t("検査人数")
    )
  ),
  bsTooltip(
    id = "domesticPCR",
    placement = "top",
    title = paste0(
      i18n$t("チャーター便を除く国内事例については、令和2年5月8日公表分から、データソースを従来の厚生労働省が把握した個票を積み上げたものから、各自治体がウェブサイトで公表している数等を積み上げたものに変更した。また、一部自治体について件数を計上しているため、実際の人数より過大である。"),
      sprintf(
        i18n$t("<hr>国内：%s (%s)<br>空港検疫：%s (+%s)<br>チャーター便：%s"),
        sum(mhlwSummary[日付 == max(日付) & 分類 %in% 0]$検査人数),
        getDiffValueAndSign(sum(mhlwSummary[日付 == max(日付) & 分類 %in% 0]$検査人数) - sum(mhlwSummary[日付 == (max(日付) - 1) & 分類 %in% 0]$検査人数)),
        sum(mhlwSummary[日付 == max(日付) & 分類 %in% 1]$検査人数),
        sum(mhlwSummary[日付 == max(日付) & 分類 %in% 1]$検査人数) - sum(mhlwSummary[日付 == (max(日付) - 1) & 分類 %in% 1]$検査人数),
        sum(mhlwSummary[日付 == max(日付) & 分類 %in% 2]$検査人数)
      )
    )
  ),
  column(
    width = 1,
    id = "domesticConfirmed",
    descriptionBlock(
      number = TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF + TOTAL_FLIGHT_DIFF + tail(byDate$伊客船, n = 1),
      number_color = "red",
      number_icon = getChangeIconWrapper(TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF + TOTAL_FLIGHT_DIFF + tail(byDate$伊客船, n = 1), type = "fa"),
      header = paste(TOTAL_DOMESITC + TOTAL_OFFICER + TOTAL_FLIGHT + sum(byDate$伊客船)),
      right_border = F,
      text = i18n$t("感染者")
    )
  ),
  bsTooltip(
    id = "domesticConfirmed",
    placement = "top",
    title = sprintf(
      i18n$t("国内事例：%s (+%s)<br>チャーター便：%s<br>コスタ・アトランチカ号：%s"),
      (TOTAL_DOMESITC + TOTAL_OFFICER), (TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF),
      TOTAL_FLIGHT, sum(byDate$伊客船)
    )
  ),
  column(
    width = 1,
    id = "domesticDischarged",
    descriptionBlock(
      number = sum(mhlwSummary[日付 == max(日付) & 分類 %in% 0:2]$退院者) - sum(mhlwSummary[日付 == max(日付) -1 & 分類 %in% 0:2]$退院者),
      number_color = "green",
      number_icon = getChangeIconWrapper(
        sum(mhlwSummary[日付 == max(日付) & 分類 %in% 0:2]$退院者) - sum(mhlwSummary[日付 == max(日付) -1 & 分類 %in% 0:2]$退院者), type = "fa"),
      header = sum(mhlwSummary[日付 == max(日付) & 分類 %in% 0:2]$退院者),
      right_border = F,
      text = i18n$t("退院者")
    )
  ),
  bsTooltip(
    id = "domesticDischarged",
    placement = "top",
    title = sprintf(
      i18n$t("国内事例：%s (+%s)<br>空港検疫：%s (+%s)<br>チャーター便：%s（全員退院済み）"),
      sum(mhlwSummary[日付 == max(日付) & 分類 %in% 0]$退院者), 
      sum(mhlwSummary[日付 == max(日付) & 分類 %in% 0]$退院者) - sum(mhlwSummary[日付 == max(日付) -1 & 分類 %in% 0]$退院者),
      sum(mhlwSummary[日付 == max(日付) & 分類 %in% 1]$退院者),
      sum(mhlwSummary[日付 == max(日付) & 分類 %in% 1]$退院者) - sum(mhlwSummary[日付 == max(日付) -1 & 分類 %in% 1]$退院者),
      sum(mhlwSummary[日付 == max(日付) & 分類 %in% 2]$退院者)
    )
  ),
  column(
    width = 1,
    descriptionBlock(
      number = DEATH_DOMESITC_DIFF + DEATH_OFFICER_DIFF,
      number_color = "black",
      number_icon = getChangeIconWrapper(DEATH_DOMESITC_DIFF + DEATH_OFFICER_DIFF, type = "fa"),
      header = paste(DEATH_DOMESITC + DEATH_OFFICER, ""),
      right_border = F,
      text = i18n$t("死亡者")
    )
  ),
  column(
    width = 2,
    id = "shipDescriptionBlock",
    descriptionBlock(
      number = "　",
      header = tagList(icon("ship"), i18n$t("クルーズ船")),
      text = ""
    )
  ),
  bsTooltip(
    id = "shipDescriptionBlock",
    title = i18n$t("ダイアモンド・プリンセス号：那覇港出港時点の人数は3711人。うち日本国籍の者1341人。"),
    placement = "top"
  ),
  column(
    width = 1,
    id = "shipPCRValue",
    # クルーズ船
    descriptionBlock(
      number = mhlwSummary[日付 == max(日付) & 分類 %in% 3]$検査人数 - mhlwSummary[日付 == max(日付) - 1 & 分類 %in% 3]$検査人数,
      number_color = "yellow",
      number_icon = getChangeIconWrapper(mhlwSummary[日付 == max(日付) & 分類 %in% 3]$検査人数 - mhlwSummary[日付 == max(日付) - 1 & 分類 %in% 3]$検査人数, type = "fa"),
      header = mhlwSummary[日付 == max(日付) & 分類 %in% 3]$検査人数,
      right_border = F,
      text = i18n$t("検査人数")
    )
  ),
  bsTooltip(
    id = "shipPCRValue",
    title = paste(
      i18n$t("ダイアモンド・プリンセス号：令和２年３月５日まで延べ人数で公表しましたＰＣＲ検査の結果について、実員数で精査した結果は下記の数値通りです。<br><br>"),
      tags$a(
        href = "https://www.mhlw.go.jp/stf/newpage_09997.html",
        i18n$t("参考：横浜港で検疫中のクルーズ船の乗客・乗員に係る新型コロナウイルス感染症ＰＣＲ検査結果について")
      ),
      i18n$t("<br><br>※下船した方に対する健康フォローアップ期間中の249人に対するPCR検査数は含まれていない。")
    ),
    placement = "top"
  ),
  column(
    width = 1,
    id = "shipConfirmedValue",
    descriptionBlock(
      number = TOTAL_SHIP_DIFF,
      number_color = "red",
      number_icon = getChangeIconWrapper(TOTAL_SHIP_DIFF, type = "fa"),
      header = TOTAL_SHIP,
      right_border = F,
      text = i18n$t("感染者")
    )
  ),
  bsTooltip(
    id = "shipConfirmedValue",
    title = i18n$t("船会社の医療スタッフとして途中乗船し、PCR陽性となった1名は含めず、チャーター便で帰国した40名を含む。"),
    placement = "top"
  ),
  column(
    width = 1,
    id = "shipDischargedValue",
    descriptionBlock(
      number = mhlwSummary[日付 == max(日付) & 分類 %in% 3]$退院者 - mhlwSummary[日付 == max(日付) - 1 & 分類 %in% 3]$退院者,
      number_color = "green",
      number_icon = getChangeIconWrapper(mhlwSummary[日付 == max(日付) & 分類 %in% 3]$退院者 - mhlwSummary[日付 == max(日付) - 1 & 分類 %in% 3]$退院者, type = "fa"),
      header =  mhlwSummary[日付 == max(日付) & 分類 %in% 3]$退院者,
      right_border = F,
      text = i18n$t("退院者")
    )
  ),
  bsTooltip(
    id = "shipDischargedValue",
    title = i18n$t("チャーター便で帰国した者を除く。"),
    placement = "top"
  ),
  column(
    width = 1,
    id = "shipDeathValue",
    descriptionBlock(
      number = DEATH_SHIP_DIFF,
      number_color = "black",
      number_icon = getChangeIconWrapper(DEATH_SHIP_DIFF, type = "fa"),
      header = paste(DEATH_SHIP, ""),
      right_border = F,
      text = i18n$t("死亡者")
    )
  ),
  bsTooltip(
    id = "shipDeathValue",
    title = i18n$t("この他にチャーター便で帰国後、3月1日に死亡したとオーストラリア政府が発表した１名がいる。"),
    placement = "top"
  )
)
