getFinalAndDiff <- function(vector) {
  index <- length(vector)
  return(list('final' = vector[index], 'diff' = vector[index] - vector[index - 1]))
}

convertUnit2Ja <- function(x) {
  x <- as.character(units(x))
  if (x == 'secs') {
    return('秒前')
  } else if (x == 'mins') {
    return('分前')
  } else if (x == 'hours') {
    return('時間前')
  } else if (x == 'days') {
    return('日前')
  } else if (x == 'weeks') {
    return('週前')
  } else {
    return(paste(x, 'ago'))
  }
}

getChangeIcon <- function(number) {
  if (number > 0) {
    return('fa fa-caret-up')
  } else if (number < 0) {
    return('fa fa-caret-down')
  } else {
    return('fa fa-lock')
  }
}

getDiffValueAndSign <- function(number) {
  if (number >= 0) {
    return(paste0('+', number))
  } else {
    return(number)
  }
}

getChangeIcon_ <- function(number) {
  if (number > 0) {
    return(icon('caret-up'))
  } else if (number < 0) {
    return(icon('caret-down'))
  } else {
    return(icon('lock'))
  }
}