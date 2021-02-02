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
  ),
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
)
#     fluidRow(column(
#       width = 12,
#       style = "padding:0px;",
#       box(
#         width = 12,
#         headerBorder = FALSE,
#         footer = NULL,
#         title = tagList(
#         actionButton(
#           inputId = "twitterShare",
#           label = "Twitter",
#           icon = icon("twitter"),
#           style = "background-color:#1DA1F2;color:white;",
#           onclick = sprintf("window.open('%s')", twitterUrl)
#         )
#         )
#       )
#     ))
#   )
# )
