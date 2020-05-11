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
        tags$small(paste0("| ", mainValueSub),
          style = "color:white;font-size:16px;margin-top:10px;margin-right:10px;opacity:0.8"
        )
      ),
      subtitle = tagList(
        "　",
        sparklineOutput(sparklineName),
        tags$span(
          diffNumber,
          getChangeIconWrapper(diffNumber),
          text,
          style = "float:right;"
        )
      ),
      icon = icon(icon),
      color = color
    )
  }

# 退院数の突合作業による影響の説明
Component.MainValueBox.Info <-
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
        tags$small(paste0("| ", mainValueSub),
                   tags$span(id = "discharged_info", icon("info-circle")),
                   bsTooltip(id = "discharged_info",
                             title = sprintf(i18n$t("確定済みの退院者数は%s名、他にも%s名の退院者は個々の陽性者との突合作業中。従って、入退院等の状況の合計とPCR検査陽性者数は一致しない。<br><br>※令和２年４月２２日から厚労省公開している退院者数の基準が変わりました。"),
                             mainValueSub, (mainValue - mainValueSub)),
                             placement = "right"),
                   style = "color:white;font-size:16px;margin-top:10px;margin-right:10px;opacity:0.8"
        )
      ),
      subtitle = tagList(
        "　",
        sparklineOutput(sparklineName),
        tags$span(
          diffNumber,
          getChangeIconWrapper(diffNumber),
          text,
          style = "float:right;"
        )
      ),
      icon = icon(icon),
      color = color
    )
  }
