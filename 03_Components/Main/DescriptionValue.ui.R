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
      number = PCR_WITHIN$diff + PCR_FLIGHT$diff + PCR_AIRPORT$diff,
      number_color = "yellow",
      number_icon = getChangeIconWrapper(PCR_WITHIN$diff + PCR_FLIGHT$diff + PCR_AIRPORT$diff, type = "fa"),
      header = paste(PCR_WITHIN$final + PCR_FLIGHT$final + PCR_AIRPORT$final, ""),
      right_border = F,
      text = i18n$t("検査人数")
    )
  ),
  bsTooltip(
    id = "domesticPCR",
    placement = "top",
    title = paste0(
      i18n$t("「令和２年３月４日版」以後は、陽性となった者の濃厚接触者に対する検査も含めた検査実施人数を都道府県に照会し、回答を得たものを公表している。なお、国内事例のPCR検査実施人数は、疑似症報告制度の枠組みの中で報告が上がった数を計上しており、各自治体で行った全ての検査結果を反映しているものではない（退院時の確認検査などは含まれていない）。"),
      sprintf(
        i18n$t("<hr>国内：%s (%s)<br>空港検疫：%s (+%s)<br>チャーター便：%s"),
        PCR_WITHIN$final, getDiffValueAndSign(PCR_WITHIN$diff),
        PCR_AIRPORT$final, PCR_AIRPORT$diff, PCR_FLIGHT$final
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
      number = DISCHARGE_DIFF_NO_SHIP,
      number_color = "green",
      number_icon = getChangeIconWrapper(DISCHARGE_DIFF_NO_SHIP, type = "fa"),
      # header = DISCHARGE_TOTAL_NO_SHIP,
      header = tail(confirmingData$domesticDischarged, n = 1) + DISCHARGE_FLIGHT$final + DISCHARGE_AIRPORT$final, # 2020-04-23 厚労省退院基準変更による仕様変更
      right_border = F,
      text = i18n$t("退院者")
    )
  ),
  bsTooltip(
    id = "domesticDischarged",
    placement = "top",
    title = sprintf(
      i18n$t("国内事例（確定）：%s (+%s)<br>※突合作業中：%s<br>空港検疫：%s (+%s)<br>チャーター便：%s（全員退院済み）"),
      DISCHARGE_WITHIN$final, DISCHARGE_WITHIN$diff, (tail(confirmingData$domesticDischarged, n = 1) - DISCHARGE_WITHIN$final),
      DISCHARGE_AIRPORT$final, DISCHARGE_AIRPORT$diff, DISCHARGE_FLIGHT$final
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
      number = PCR_SHIP$diff,
      number_color = "yellow",
      number_icon = getChangeIconWrapper(PCR_SHIP$diff, type = "fa"),
      header = paste(PCR_SHIP$final, ""),
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
      number = DISCHARGE_SHIP$diff,
      number_color = "green",
      number_icon = getChangeIconWrapper(DISCHARGE_SHIP$diff, type = "fa"),
      header = paste(DISCHARGE_SHIP$final, ""),
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
