getFinalAndDiff <- function(vector) {
  index <- length(vector)
  return(list("final" = vector[index], "diff" = vector[index] - vector[index - 1]))
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
    return("fa fa-caret-up")
  } else if (number < 0) {
    return("fa fa-caret-down")
  } else {
    return("fa fa-lock")
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