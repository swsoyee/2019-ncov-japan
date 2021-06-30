library(data.table)
library(tabulizer)

#### Update vaccine data by prefecture ####

# Define data path
data_path <- "50_Data/MHLW/vaccineByRegion.csv"

# Read exist data
vaccineByRegion <- fread(data_path)

# Define origion
definition <- list(
  list(
    category = "medical",
    url = "https://www.kantei.go.jp/jp/content/IRYO-kenbetsu-vaccination_data2.pdf"
  ),
  list(
    category = "elderly",
    url = "https://www.kantei.go.jp/jp/content/KOREI-kenbetsu-vaccination_data2.pdf"
  )
)

for (item in definition) {
  # Extract update date in PDF file
  date <- strsplit(tabulizer::extract_text(item$url), split = "\n")[[1]][2]
  date <- paste0(format(Sys.Date(), "%Y"), "年", gsub("（(.*)時点）", "\\1", date))
  date_new <- format(as.Date(date, format = "%Y年%m月%d日"), "%Y%m%d")

  # Remove same data if existed (for update exist data)
  vaccineByRegion <- vaccineByRegion[!(category == item$category & date == date_new)]

  # Extract table from PDF
  data <- tabulizer::extract_tables(item$url)
  data <- data.table(data[[1]])[3:.N, ]

  if (item$category == "elderly") {
    pre_data <- data[, .(
      prefecture = V1,
      total = V2,
      first = V3,
      second = V4,
      category = item$category,
      date = date_new
    )]
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
    url = "https://www.kantei.go.jp/jp/content/IRYO-vaccination_data3.pdf"
  ),
  list(
    category = "elderly",
    url = "https://www.kantei.go.jp/jp/content/KOREI-vaccination_data3.pdf"
  )
)

for (item in definition) {
  # Extract table
  data <- tabulizer::extract_tables(item$url)
  if (item$category == "medical") {
    # data <- data.table(data[[1]])[4:.N, ]
    # data <- data[, .(V1, V4, V5, V6, V7)]
    ## Sometime using this pattern
    data <- data.table(data[[1]])[5:.N, ]
    data[, c("V1", "week", "total") := tstrsplit(V2, " ", fixed = TRUE)]
    data <- data[, .(V1, V3, V4, V5, V6)]
  } else {
    data <- data.table(data[[1]])[5:.N, ]
    data[, c("V1", "week") := tstrsplit(V1, " ", fixed = TRUE)]
    data[, c("m_first", "p_second") := tstrsplit(V5, " ", fixed = TRUE)]
    data <- data[, .(V1, V4, m_first, p_second, V6)]
  }

  cols <- c(
    paste0(item$category, "_first_pfizer"),
    paste0(item$category, "_first_moderna"),
    paste0(item$category, "_second_pfizer"),
    paste0(item$category, "_second_moderna")
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
  vaccine[data, on = .(date), (n) := mget(paste0("i.", n))]
}

for (i in names(vaccine)) vaccine[is.na(get(i)), (i):=0]

fwrite(vaccine, file = data_path)
