# ====退院推移図データセット====
dischargeData <- reactive({
  dt <- domesticDailyReport
  dt <- merge(x = domesticDailyReport, y = flightDailyReport, by = "date", all.x = T, suffixes = c(".d", ".f"))
  dt <- merge(x = dt, y = airportDailyReport, by = "date", all.x = T)
  dt <- merge(x = dt, y = shipDailyReport, by = "date", all.x = T)

  dataset <- domesticDailyReport

  dataset$positive <- rowSums(cbind(dataset$positive, dt$positive.x), na.rm = T)
  dataset$discharge <- rowSums(cbind(dataset$discharge, dt$discharge.x), na.rm = T)
  dataset$mild <- rowSums(cbind(dataset$mild, dt$mild), na.rm = T)
  dataset$severe <- rowSums(cbind(dataset$severe, dt$severe.x), na.rm = T)
  dataset$death <- rowSums(cbind(dataset$death, dt$death.x), na.rm = T)

  if (input$showFlightInDischarge) {
    dataset$positive <- dataset$positive + flightDailyReport$positive
    dataset$discharge <- dataset$discharge + flightDailyReport$discharge
    dataset$mild <- dataset$mild + flightDailyReport$mild
    dataset$severe <- dataset$severe + flightDailyReport$severe
    dataset$death <- dataset$death + flightDailyReport$death
  }
  if (input$showShipInDischarge) {
    ship <- shipDailyReport[2:nrow(shipDailyReport), ]
    setnafill(ship, fill = 0)
    dataset$positive <- dataset$positive + ship$positive
    dataset$discharge <- dataset$discharge + ship$discharge
    dataset$severe <- dataset$severe + ship$severe
    dataset$death <- dataset$death + ship$death
  }
  dataset
})