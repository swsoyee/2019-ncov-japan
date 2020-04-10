Component.MainValueBox <-
    function(mainValue,
             mainValueSub,
             sparklineName,
             diffNumber,
             text,
             icon,
             color) {
        valueBox(
            width = 6,
            value = tagList(
                mainValue,
                tags$small(paste0('| ', mainValueSub),
                           style = 'color:white;font-size:16px;margin-top:10px;margin-right:10px;opacity:0.8')
            ),
            subtitle = tagList(
                '　',
                sparklineOutput(sparklineName),
                tags$span(
                    diffNumber,
                    getChangeIconWrapper(diffNumber),
                    text,
                    style =  'float:right;'
                )
            ),
            icon = icon(icon),
            color = color
        )
    }
