# 総計検査人数Sparkline  ====
output$pcrSparkLine <- renderSparkline({
  sparkline(
    tail(mhlwSummary[, .(cumsum = sum(検査人数, na.rm = T)), by = "日付"][, .(diff = cumsum - shift(cumsum))], n = 28)[[1]],
    type = "bar", width = 100, barColor = "white"
  )
})

output$confirmedSparkLine <- renderSparkline({
  value <- rowSums(byDate[, 2:ncol(byDate), with = T])
  value <- value[(length(value) - 21):length(value)]
  sparkline(value, type = "bar", width = 100, barColor = "white")
})

output$dischargeSparkLine <- renderSparkline({
  sparkline(
    dailyReport$dischargeDiff[(nrow(dailyReport) - 21):nrow(dailyReport)],
    type = "bar", width = 100, barColor = "white"
  )
})

output$deathSparkLine <- renderSparkline({
  value <- rowSums(death[, 2:ncol(death), with = T])
  value <- value[(length(value) - 21):length(value)]
  sparkline(value, type = "bar", width = 100, barColor = "white")
})