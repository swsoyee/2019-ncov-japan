library(data.table)
library(tabulizer)

#### Update vaccine data by prefecture ####

# Define data path
data_path <- "50_Data/MHLW/vaccineByRegion.csv"

# Read exist data
vaccineByRegion <- fread(data_path)

# Define origion
definition <- list(
  # 医療従事者等は、令和３年７月30日で集計を終了。
  # list(
  #   category = "medical",
  #   url = "https://www.kantei.go.jp/jp/content/kenbetsu-vaccination_data2.pdf",
  #   page = 3
  # ),
  list(
    category = "elderly",
    url = "https://www.kantei.go.jp/jp/content/kenbetsu-vaccination_data2.pdf",
    page = 3
  )
)

for (item in definition) {
  # Extract update date in PDF file
  index <- ifelse(item$category == "elderly", 69, 2)
  row_start <- 5

  date <- strsplit(tabulizer::extract_text(item$url, pages = item$page), split = "\n")[[1]][index]
  date <- paste0(format(Sys.Date(), "%Y"), "年", gsub("（(.*)時点）", "\\1", date))
  date_new <- format(as.Date(date, format = "%Y年%m月%d日"), "%Y%m%d")

  # Remove same data if existed (for update exist data)
  vaccineByRegion <- vaccineByRegion[!(category == item$category & date == date_new)]

  # Extract table from PDF
  data <- tabulizer::extract_tables(item$url, pages = item$page)
  data <- data.table(data[[1]])[row_start:.N, ]

  if (item$category == "elderly") {
    pre_data <- data[, .(
      prefecture = V1,
      total = V2,
      first_p = V4,
      second_p = V5,
      first_m = V7,
      second_m = V8,
      first_a = V10,
      second_a = V11,
      category = item$category,
      date = date_new
    )]
    cols <- c("total", "first_p", "second_p", "first_m", "second_m", "first_a", "second_a")
    pre_data[, (cols) := lapply(.SD, function(x) {
      return(as.numeric(gsub(",", "", x)))
    }), .SDcols = cols]
    pre_data[, first := (first_p + first_m + first_a)]
    pre_data[, second := (second_p + second_m + second_a)]
    pre_data <- pre_data[, .(prefecture, total, first, second, category, date)]
  }
  if (item$category == "medical") {
    pre_data <- data[, .(
      prefecture = V1,
      total = V2,
      first = V3,
      second = V4,
      category = item$category,
      date = date_new
    )]
  }

  pre_data[, c("code", "prefecture") := tstrsplit(prefecture, " ", fixed = TRUE)]
  pre_data[, code := as.numeric(code)]

  cols <- c("total", "first", "second")
  pre_data[, (cols) := lapply(.SD, function(x) {
    return(gsub(",", "", x))
  }), .SDcols = cols]
  suppressWarnings(pre_data[, (cols) := lapply(.SD, as.numeric), .SDcols = cols])

  vaccineByRegion <- rbind(vaccineByRegion, pre_data)
}

fwrite(vaccineByRegion, file = data_path)

#### Update vaccine by date ####

data_path <- "50_Data/MHLW/vaccine.csv"

# Read exist data
vaccine <- fread(data_path)
vaccine$date <- as.character(vaccine$date)

# Define origion
definition <- list(
  list(
    category = "medical",
    url = "https://www.kantei.go.jp/jp/content/vaccination_data5.pdf",
    page = 6
  ),
  list(
    category = "elderly",
    url = "https://www.kantei.go.jp/jp/content/vaccination_data5.pdf",
    page = 4
  ),
  list(
    category = "elderly",
    url = "https://www.kantei.go.jp/jp/content/vaccination_data5.pdf",
    page = 5
  ),
  list(
    category = "worker",
    url = "https://www.kantei.go.jp/jp/content/vaccination_data5.pdf",
    page = 7
  ),
  list(
    category = "duplicate",
    url = "https://www.kantei.go.jp/jp/content/vaccination_data5.pdf",
    page = 8
  )
)

for (item in definition) {
  # Extract table
  data <- tabulizer::extract_tables(item$url, pages = item$page)
  if (item$category == "medical") {
    # data <- data.table(data[[1]])[4:.N, ]
    # data <- data[, .(V1, V4, V5, V6, V7)]
    ## Sometime using this pattern
    data <- data.table(data[[1]])[5:.N, ]
    data[, c("V1", "week", "total") := tstrsplit(V2, " ", fixed = TRUE)]
    data <- data[, .(V1, V5, V6, 0, V7, V8, 0)]
  }
  if (item$category == "elderly") {
    data <- data.table(data[[1]])[5:.N, ]
    # data[, c("V1", "week") := tstrsplit(V1, " ", fixed = TRUE)]
    # data[, c("m_first", "p_second") := tstrsplit(V5, " ", fixed = TRUE)]
    # data <- data[, .(V1, V4, m_first, p_second, V6)]
    data <- data[, .(V1, V4, V5, V6, V7, V8, V9)]
  }
  if (item$category == "worker") {
    data <- data.table(data[[1]])[3:.N, ]
    data <- data[, .(V1, 0, V6, 0, 0, V7, 0)]
  }
  if (item$category == "duplicate") {
    data <- data.table(data[[1]])[3:.N, ]
    data <- data[, .(V1, 0, V5, 0, 0, V6, 0)]
  }

  cols <- c(
    paste0(item$category, "_first_pfizer"),
    paste0(item$category, "_first_moderna"),
    paste0(item$category, "_first_astrazeneca"),
    paste0(item$category, "_second_pfizer"),
    paste0(item$category, "_second_moderna"),
    paste0(item$category, "_second_astrazeneca")
  )

  colnames(data) <- c(
    "date",
    cols
  )

  # Handle columns
  data$date <- format(as.Date(data$date), "%Y%m%d")
  data[, (cols) := lapply(.SD, function(x) {
    return(as.numeric(gsub(",", "", x)))
  }), .SDcols = cols]

  # Update data
  n <- names(data)
  if (item$category == "worker") {
    worker_first_moderna_first_day <- data[.N][["worker_first_moderna"]]
    worker_second_moderna_first_day <- data[.N][["worker_second_moderna"]]
    data[order(date), worker_first_moderna := worker_first_moderna - shift(worker_first_moderna)]
    data[order(date), worker_second_moderna := worker_second_moderna - shift(worker_second_moderna)]
    data[.N, worker_first_moderna := worker_first_moderna_first_day]
    data[.N, worker_second_moderna := worker_second_moderna_first_day]
  }
  if (item$category == "duplicate") {
    duplicate_first_moderna_first_day <- data[.N][["duplicate_first_moderna"]]
    duplicate_second_moderna_first_day <- data[.N][["duplicate_second_moderna"]]
    data[order(date), duplicate_first_moderna := duplicate_first_moderna - shift(duplicate_first_moderna)]
    data[order(date), duplicate_second_moderna := duplicate_second_moderna - shift(duplicate_second_moderna)]
    data[.N, duplicate_first_moderna := duplicate_first_moderna_first_day]
    data[.N, duplicate_second_moderna := duplicate_second_moderna_first_day]
  }
  vaccine[data, on = .(date), (n) := mget(paste0("i.", n))]
}

for (i in names(vaccine)) vaccine[is.na(get(i)), (i) := 0]

fwrite(vaccine, file = data_path)
