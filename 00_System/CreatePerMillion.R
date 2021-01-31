
getLatestWeekValue <- function(data, type = "week") {
  if (type == "day") {
    span <- 1
  } else if (type == "week") {
    span <- 6
  } else {
    stop("Unknown span type.")
  }

  index <- (nrow(data) - 6):nrow(data)
  indexBefore <- index - 1

  value <- colSums(data[index, 2:ncol(data)])
  valueBefore <- colSums(data[indexBefore, 2:ncol(data)])

  list(
    yesterday = valueBefore,
    today = value,
    difference = value - valueBefore
  )
}

diff2Icon <- function(x) {
  if (is.na(x)) {
    return(NA)
  }
  if (x >= 1) {
    return(" <i style='color:#DD4B39;' class=\"fa fa-angle-double-up\"></i>")
  }
  if (x <= 1 && x > 0) {
    return(" <i style='color:#DD4B39;' class=\"fa fa-angle-up\"></i>")
  }
  if (x == 0) {
    return(" <i style='color:#001f3f;' class=\"fa fa-lock\"></i>")
  }
  if (x < 0 && x >= -1) {
    return(" <i style='color:#00a65a;' class=\"fa fa-angle-down\"></i>")
  }
  if (x < -1) {
    return(" <i style='color:#00a65a;' class=\"fa fa-angle-double-down\"></i>")
  }
}
