# データの読み込み
loadDataFromFile <- function(fileList, FilePath, fileName, object, index) {
  # 実際のファイル名を取得
  dataName <- fileList[sapply(fileList, function(x) {grepl(fileName, x)})]
  # 保存
  object[[index]] <- fread(file = paste0(DATA_PATH, FilePath, dataName))
  return(object)
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

# データ更新時間変換
getUpdateTimeDiff <- function(dataUpdateTime) {
  latestUpdateDuration <- difftime(Sys.time(), dataUpdateTime)
  updateTime <- paste0(
    round(latestUpdateDuration[[1]], 0), 
    convertUnit2Ja(latestUpdateDuration)
  )
  return(updateTime)
}

# ValueBox内部のSparklineを作成
createSparklineInValueBox <-
  function(data,
           column,
           barColor = 'white',
           negBarColor = 'white',
           length = 30) {
    if (!is.null(data) && nrow(data) > 0) {
      sparkline(
        data[[column]][(nrow(data) - length):nrow(data)],
        type = 'bar',
        barColor = barColor,
        negBarColor = negBarColor,
        width = 160
      )
    } else {
      sparkline(
        rep(0, length),
        type = 'bar',
        barColor = barColor,
        negBarColor = negBarColor,
        width = 160
      )
    }
  }

# ValueBox作成
createValueBox <-
  function(value,
           subValue,
           subtitle,
           sparkline,
           icon,
           color,
           width = 6,
           diff = 0) {
    value <- ifelse(is.null(value), '情報なし', value)
    subValue <- ifelse(is.null(subValue), '情報なし', subValue)
    
    diffIcon <- ''
    if (!is.null(diff)) {
      if (diff > 0) {
        diffIcon <- icon('caret-up')
      } else if (diff < 0) {
        diffIcon <- icon('caret-down')
      } else {
        diffIcon <- icon('lock')
      }
    } else {
      diff <- '-'
    }
    
    return(
      valueBox(
        value = tagList(
          countup(value),
          tags$small(paste0('| ' , subValue),
                     style = 'color:white;font-size:16px;margin-top:10px;margin-right:10px;opacity:0.8')
        ),
        subtitle = tagList(
          sparkline,
          tags$span(countup(diff), diffIcon, subtitle, style = 'float:right')
        ),
        icon = icon(icon),
        color = color,
        width = width
      )
    )
  }