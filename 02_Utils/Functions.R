getFinalAndDiff <- function(vector) {
  index <- length(vector)
  return(list("final" = vector[index], "diff" = vector[index] - vector[index - 1]))
}

getFileUpdateTime <- function(file) {
  fileUpdateTime <- file.info(file)$mtime
  latestUpdateDuration <- difftime(Sys.time(), fileUpdateTime)
  return(paste0(
    round(latestUpdateDuration[[1]], 0),
    convertUnit2Ja(latestUpdateDuration)
  ))
}

convertUnit2Ja <- function(x) {
  x <- as.character(units(x))
  if (x == "secs") {
    return(i18n$t("秒前"))
  } else if (x == "mins") {
    return(i18n$t("分前"))
  } else if (x == "hours") {
    return(i18n$t("時間前"))
  } else if (x == "days") {
    return(i18n$t("日前"))
  } else if (x == "weeks") {
    return(i18n$t("週前"))
  } else {
    return(paste(x, "ago"))
  }
}

getChangeIcon <- function(number) {
  if (number > 0) {
    return("caret-up")
  } else if (number < 0) {
    return("caret-down")
  } else {
    return("lock")
  }
}

getChangeIcon_ <- function(number) {
  if (number > 0) {
    return(icon("caret-up"))
  } else if (number < 0) {
    return(icon("caret-down"))
  } else {
    return(icon("lock"))
  }
}

getChangeIconWrapper <- function(number, type = "icon") {
  if (type == "icon") {
    return(getChangeIcon_(number))
  } else {
    return(getChangeIcon(number))
  }
}

getDiffValueAndSign <- function(number) {
  if (number >= 0) {
    return(paste0("+", number))
  } else {
    return(number)
  }
}

generateColorStyle <- function(data, colors, by) {
  breaks <- seq(0, max(ifelse(is.na(data), 0, data), na.rm = T), by = by)
  colorPanel <- colorRampPalette(colors)(length(breaks) + 1)
  return(list(cuts = breaks, values = colorPanel))
}

calendarDateRangePicker <- function(inputId) {
  dateRangeInput(
    inputId,
    label = "",
    start = Sys.Date() - 120,
    end = Sys.Date(),
    min = "2020-01-01",
    max = Sys.Date(),
    separator = " - ",
    format = i18n$t("yyyy年m月d日"),
    language = i18n$translation_language
  )
}

continuousZero <- function(data) {
  count <- 0
  for (index in seq(length(data))) {
    if (data[index] == 0) {
      count <- count + 1
    } else {
      count <- 0
    }
  }
  count
}
