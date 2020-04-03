output$confirmedSparkLine <- renderSparkline({
  value <- rowSums(byDate[, 2:ncol(byDate), with = T])
  value <- value[(length(value) - 21):length(value)]
  sparkline(value, type = 'bar', width = 100, barColor = 'white')
})

output$deathSparkLine <- renderSparkline({
  value <- rowSums(death[, 2:ncol(death), with = T])
  value <- value[(length(value) - 21):length(value)]
  sparkline(value, type = 'bar', width = 100, barColor = 'white')
})
