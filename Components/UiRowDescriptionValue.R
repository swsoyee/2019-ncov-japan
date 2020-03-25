fluidRow(
  column(
    width = 2,
    # 国内事例
    descriptionBlock(
      number = '　',
      header = tagList(icon('torii-gate'), lang[[langCode]][4]),
      text = paste0(lang[[langCode]][36], 'を含む')
    )
  ),
  column(
    width = 1,
    id = 'domesticPCR',
    # 国内事例
    descriptionBlock(
      number = PCR_WITHIN$diff + PCR_FLIGHT$diff + PCR_AIRPORT$diff,
      number_color = 'yellow',
      number_icon = getChangeIcon(PCR_WITHIN$diff + PCR_FLIGHT$diff + PCR_AIRPORT$diff),
      header = paste(PCR_WITHIN$final + PCR_FLIGHT$final + PCR_AIRPORT$final, ''),
      right_border = F,
      text = '検査人数'
    )
  ),
  bsTooltip(
    id = 'domesticPCR', 
    placement = 'top',
    title = paste0(
      '「令和２年３月４日版」以後は、陽性となった者の濃厚接触者に対する検査も含めた検査実施人数を都道府県に照会し、',
      '回答を得たものを公表している。なお、国内事例のPCR検査実施人数は、',
      '疑似症報告制度の枠組みの中で報告が上がった数を計上しており、',
      '各自治体で行った全ての検査結果を反映しているものではない（退院時の確認検査などは含まれていない）。',
      '<hr>国内：', PCR_WITHIN$final, ' (', getDiffValueAndSign(PCR_WITHIN$diff),
      ')<br>空港検疫：', PCR_AIRPORT$final, ' (+', PCR_AIRPORT$diff,
      ')<br>チャーター便：', PCR_FLIGHT$final, ' (+', PCR_FLIGHT$diff, ')'
      )
    ),
  column(
    width = 1,
    id = 'domesticConfirmed', 
    # 国内事例
    descriptionBlock(
      number = TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF + TOTAL_FLIGHT_DIFF,
      number_color = 'red',
      number_icon = getChangeIcon(TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF + TOTAL_FLIGHT_DIFF),
      header = paste(TOTAL_DOMESITC + TOTAL_OFFICER + TOTAL_FLIGHT, ''),
      right_border = F,
      text = '感染者'
    )
  ),
  bsTooltip(
    id = 'domesticConfirmed', 
    placement = 'top',
    title = paste0(
      '国内事例：', (TOTAL_DOMESITC + TOTAL_OFFICER), ' (+', (TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF),
      ')<br>チャーター便：', TOTAL_FLIGHT
    )
  ),
  column(
    width = 1,
    id = 'domesticDischarged', 
    # 国内事例
    descriptionBlock(
      number = SYMPTOM_DISCHARGE_WITHIN$diff + 
        SYMPTOMLESS_DISCHARGE_WITHIN$diff + 
        SYMPTOM_DISCHARGE_FLIGHT$diff + 
        SYMPTOMLESS_DISCHARGE_FLIGHT$diff,
      number_color = 'green',
      number_icon = getChangeIcon(SYMPTOM_DISCHARGE_WITHIN$diff + 
                                    SYMPTOMLESS_DISCHARGE_WITHIN$diff + 
                                    SYMPTOM_DISCHARGE_FLIGHT$diff + 
                                    SYMPTOMLESS_DISCHARGE_FLIGHT$diff),
      header = paste(SYMPTOM_DISCHARGE_WITHIN$final + 
                       SYMPTOMLESS_DISCHARGE_WITHIN$final +
                       SYMPTOM_DISCHARGE_FLIGHT$final + 
                       SYMPTOMLESS_DISCHARGE_FLIGHT$final, ''),
      right_border = F,
      text = '退院者'
    )
  ),
  bsTooltip(
    id = 'domesticDischarged', 
    placement = 'top',
    title = paste0(
      '国内無症状者：', SYMPTOMLESS_DISCHARGE_WITHIN$final, ' (+', SYMPTOMLESS_DISCHARGE_WITHIN$diff,
      ')<br>国内有症状者：', SYMPTOM_DISCHARGE_WITHIN$final, ' (+', SYMPTOM_DISCHARGE_WITHIN$diff,
      ')<br><br>チャーター便無症状者：', SYMPTOMLESS_DISCHARGE_FLIGHT$final,
      '<br>チャーター便有症状者：', SYMPTOM_DISCHARGE_FLIGHT$final, '<br>全員退院済み'
    )
  ),
  column(
    width = 1,
    # 国内事例
    descriptionBlock(
      number = DEATH_DOMESITC_DIFF + DEATH_OFFICER_DIFF,
      number_color = 'black',
      number_icon = getChangeIcon(DEATH_DOMESITC_DIFF + DEATH_OFFICER_DIFF),
      header = paste(DEATH_DOMESITC + DEATH_OFFICER, ''),
      right_border = F,
      text = '死亡者'
    )
  ),
  column(
    width = 2,
    id = 'shipDescriptionBlock',
    # 国内事例
    descriptionBlock(
      number = '　',
      header = tagList(icon('ship'), lang[[langCode]][35]),
      text = '3711人'
    )
  ),
  bsTooltip(
    id = 'shipDescriptionBlock', 
    title = '那覇港出港時点の人数。うち日本国籍の者1,341人。',
    placement = 'top'),
  column(
    width = 1,
    id = 'shipPCRValue',
    # クルーズ船
    descriptionBlock(
      number = PCR_SHIP$diff,
      number_color = 'yellow',
      number_icon = getChangeIcon(PCR_SHIP$diff),
      header = paste(PCR_SHIP$final, ''),
      right_border = F,
      text = '検査人数'
    )
  ),
  bsTooltip(
    id = 'shipPCRValue', 
    title = paste(
      '令和２年３月５日まで延べ人数で公表しましたＰＣＲ検査の結果について、実員数で精査した結果は下記の通りです。<br>参考：',
      tags$a(href = 'https://www.mhlw.go.jp/stf/newpage_09997.html', 
             '横浜港で検疫中のクルーズ船の乗客・乗員に係る新型コロナウイルス感染症ＰＣＲ検査結果について'),
      '<hr>なお、下船した方に対する健康フォローアップ期間中の249人に対するPCR検査数は含まれていない。'
    ),
    placement = 'top'),
  column(
    width = 1,
    id = 'shipConfirmedValue',
    # クルーズ船
    descriptionBlock(
      number = TOTAL_SHIP_DIFF,
      number_color = 'red',
      number_icon = getChangeIcon(TOTAL_SHIP_DIFF),
      header = paste(TOTAL_SHIP, ''),
      right_border = F,
      text = '感染者'
    )
  ),
  bsTooltip(
    id = 'shipConfirmedValue', 
    title = '船会社の医療スタッフとして途中乗船し、PCR陽性となった1名は含めず、チャーター便で帰国した40名を含む。',
    placement = 'top'),
  column(
    width = 1,
    id = 'shipDischargedValue',
    # クルーズ船
    descriptionBlock(
      number = DISCHARGE_SHIP$diff,
      number_color = 'green',
      number_icon = getChangeIcon(DISCHARGE_SHIP$diff),
      header = paste(DISCHARGE_SHIP$final, ''),
      right_border = F,
      text = '退院者'
    )
  ),
  bsTooltip(
    id = 'shipDischargedValue', 
    title = 'チャーター便で帰国した者を除く。',
    placement = 'top'),
  column(
    width = 1,
    id = 'shipDeathValue',
    # クルーズ船
    descriptionBlock(
      number = DEATH_SHIP_DIFF,
      number_color = 'black',
      number_icon = getChangeIcon(DEATH_SHIP_DIFF),
      header = paste(DEATH_SHIP, ''),
      right_border = F,
      text = '死亡者'
    )
  ),
  bsTooltip(
    id = 'shipDeathValue', 
    title = 'この他にチャーター便で帰国後、3月1日に死亡したとオーストラリア政府が発表した１名がいる。',
    placement = 'top'),
)
