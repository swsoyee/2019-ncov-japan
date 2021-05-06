library(data.table)
library(tabulizer)

# Define data path
data_path <- "50_Data/MHLW/vaccineByRegion.csv"

# Read exist data
vaccineByRegion <- fread(data_path)

# Define origion
definition <- list(
  list(
    category = "medical",
    url = "https://www.kantei.go.jp/jp/content/IRYO-kenbetsu-vaccination_data.pdf"
  ),
  list(
    category = "elderly",
    url = "https://www.kantei.go.jp/jp/content/KOREI-kenbetsu-vaccination_data.pdf"
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

  pre_data <- data[, .(
    prefecture = V1,
    total = V2,
    first = V3,
    second = V4,
    category = item$category,
    date = date_new
  )]

  pre_data[, c("code", "prefecture") := tstrsplit(prefecture, " ", fixed = TRUE)]

  cols <- c("total", "first", "second")
  pre_data[, (cols) := lapply(.SD, function(x) {
    return(gsub(",", "", x))
  }), .SDcols = cols]
  suppressWarnings(pre_data[, (cols) := lapply(.SD, as.numeric), .SDcols = cols])

  vaccineByRegion <- rbind(vaccineByRegion, pre_data)
}

fwrite(vaccineByRegion, file = data_path)
