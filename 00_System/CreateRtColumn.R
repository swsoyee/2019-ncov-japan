library(EpiEstim)
library(incidence)
library(data.table)

createRtColumn <- function(data) {
  RtTable <- t(data.frame(sapply(
    colnames(data)[2:ncol(data)],
    function(pref) {
      createRtValue(data, pref)
    }
  )))

  colnames(RtTable) <- c("Rt", "display")
  RtTable <- data.table(RtTable, keep.rownames = TRUE)
  RtTable[48:51, Rt := 0]
  RtTable[48:51, display := "0 <i style='color:#001f3f;' class='fa fa-lock'></i>"]

  RtTable[, rank := sprintf("%02d", rank(Rt, ties.method = "first"))]
  RtTable[, display := paste0(rank, "|", display)]
  RtTable
}

createRtValue <- function(data, region) {
  # Nishiura, Hiroshi et al., 2020
  mean_si <- 4.6
  std_si <- 2.6

  tryCatch(expr = {
    incid <- createRegionIncidence(data, region)
    res <- createEstimatedResultFromIncid(incid, mean_si, std_si)
    values <- createLatestRtFromEstimated(res)
    displayValue <- paste(values[2], createSymbolFromDifferenceValue(values))
    c(values[2], displayValue)
  }, error = function(e) {
    NA
  })
}

createRegionIncidence <- function(data, region) {
  setDT(data)

  incid <- incidence::as.incidence(
    rowSums(data[, region, with = FALSE]),
    dates = byDate$date
  )

  incid
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

createEstimatedResultFromIncid <- function(incid, mean_si, std_si) {
  # handling ending date
  continuous <- continuousZero(incid$counts)
  index <- length(incid$counts) - continuous
  
  res <- suppressMessages(
    suppressWarnings(
      EpiEstim::estimate_R(incid,
        method = "parametric_si",
        config = make_config(list(
          mean_si = mean_si,
          std_si = std_si,
          t_end = max(incid$dates)
        ))
      )
    )
  )

  dt <- data.table::as.data.table(res$R)

  cols <- colnames(dt)
  dt[, (cols) := lapply(.SD, function(x) {
    return(round(x, 2))
  }), .SDcols = cols]

  dt$dates <- res$dates[res$R$t_end]
  dt$Incidence <- res$I[res$R$t_end]

  if (continuous > 7) {
    dt <- dt[1:(index + 1)]
    dt[nrow(dt), 3] <- 0
  }
  dt
}

createLatestRtFromEstimated <- function(res) {
  tail(res$`Mean(R)`, n = 2)
}

createSymbolFromDifferenceValue <- function(values) {
  difference <- values[2] - values[1]
  upColor <- "#DD4B39"
  tieColor <- "#001f3f"
  downColor <- "#00a65a"

  if (difference >= 0.2) {
    return(
      sprintf(
        "<i style='color:%s;' class='fa fa-angle-double-up'></i>",
        upColor
      )
    )
  }
  if (difference > 0 && difference < 0.2) {
    return(
      sprintf(
        "<i style='color:%s;' class='fa fa-angle-up'></i>",
        upColor
      )
    )
  }
  if (difference == 0) {
    return(
      sprintf(
        "<i style='color:%s;' class='fa fa-lock'></i>",
        tieColor
      )
    )
  }
  if (difference > -0.2 && difference < 0) {
    return(
      sprintf(
        "<i style='color:%s;' class='fa fa-angle-down'></i>",
        downColor
      )
    )
  }
  if (difference <= 0.2) {
    return(
      sprintf(
        "<i style='color:%s;' class='fa fa-angle-double-down'></i>",
        downColor
      )
    )
  }
}
