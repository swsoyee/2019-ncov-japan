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
           width = 6) {
    value <- ifelse(is.null(value), '情報なし', value)
    subValue <- ifelse(is.null(subValue), '情報なし', subValue)
    return(
      valueBox(
        value = tagList(
          value,
          tags$small(paste0('| ' , subValue),
                     style = 'color:white;font-size:16px;margin-top:10px;margin-right:10px;opacity:0.8')
        ),
        subtitle = tagList(
          sparkline,
          tags$span(subtitle, style = 'float:right')
        ),
        icon = icon(icon),
        color = color,
        width = width
      )
    )
  }