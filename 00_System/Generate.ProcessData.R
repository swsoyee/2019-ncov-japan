library(data.table)

# ====準備部分====
DATA_PATH <- "Data/"

# 国内の日報
domesticDailyReport <- fread(paste0(DATA_PATH, "domesticDailyReport.csv"))
domesticDailyReport$date <- as.Date(as.character(domesticDailyReport$date), "%Y%m%d")
setnafill(domesticDailyReport, type = "locf")

# ====症状進行テーブル====
# 症状進展Sankey
processData <- data.table(
  "date" = as.Date(x = integer(0), origin = "1970-01-01"),
  "source" = character(0),
  "target" = character(0),
  "value" = numeric(0)
)

for (i in 1:nrow(domesticDailyReport)) {
  latestRecord <- domesticDailyReport[i]
  # latestRecord <- domesticDailyReport[nrow(domesticDailyReport)] # TEST
  data <- data.table("source" = character(0), "target" = character(0), "value" = numeric(0))
  label.pcr <- paste0("PCR検査陽性\n100.00%")
  label.symptomless <- paste0("無症状\n", round(latestRecord$symptomless / latestRecord$positive * 100, 2), "%")
  label.symptom <- paste0("有症状\n", round(latestRecord$symptom / latestRecord$positive * 100, 2), "%")
  label.hospitalized <- paste0(
    "入院治療必要\n",
    round(latestRecord$hospitalize / latestRecord$positive * 100, 2), "%"
  )
  label.discharge <- paste0(
    "退院\n",
    round(latestRecord$discharge / latestRecord$positive * 100, 2), "%"
  )
  label.waiting <- paste0(
    "入院待機中\n",
    round(
      (latestRecord$symptomlesshospitalizedWaiting + latestRecord$waiting) /
        (latestRecord$positive) * 100, 2
    ), "%"
  )
  label.mild <- paste0(
    "軽〜中等症の者\n",
    round(
      (latestRecord$mild) /
        (latestRecord$positive) * 100, 2
    ), "%"
  )
  label.severe <- paste0(
    "人工呼吸又は\nICUに入院\n",
    round(
      (latestRecord$severe) /
        (latestRecord$positive) * 100, 2
    ), "%"
  )
  label.confirming <- paste0(
    "確認中\n",
    round(
      (latestRecord$confirming) /
        (latestRecord$positive) * 100, 2
    ), "%"
  )
  label.death <- paste0(
    "死亡者\n",
    round(
      (latestRecord$death) /
        (latestRecord$positive) * 100, 2
    ), "%"
  )
  label.symptomConfirming <- paste0(
    "症状有無確認中\n",
    round(
      (latestRecord$symptomConfirming) /
        (latestRecord$positive) * 100, 2
    ), "%"
  )
  # Step1 陽性、症状有無、確認中
  data <- rbind(data, list(label.pcr, label.symptomless, latestRecord$symptomless))
  data <- rbind(data, list(label.pcr, label.symptom, latestRecord$symptom))
  data <- rbind(data, list(label.pcr, label.symptomConfirming, latestRecord$symptomConfirming))
  # Step2 症状ありのみ入院
  data <- rbind(data, list(label.symptom, label.discharge, latestRecord$discharge))
  data <- rbind(data, list(label.symptom, label.hospitalized, latestRecord$hospitalize))
  data <- rbind(data, list(label.symptom, label.death, latestRecord$death))
  data <- rbind(data, list(label.symptom, label.waiting, latestRecord$waiting))

  # Step3 入院者の状態
  data <- rbind(data, list(label.hospitalized, label.mild, latestRecord$mild))
  data <- rbind(data, list(label.hospitalized, label.severe, latestRecord$severe))
  data <- rbind(data, list(label.hospitalized, label.confirming, latestRecord$confirming))

  data <- cbind(date = latestRecord$date, data)

  processData <- rbind(processData, data)
}
# テーブル出力
fwrite(x = processData, file = paste0(DATA_PATH, "resultProcessData.csv"))