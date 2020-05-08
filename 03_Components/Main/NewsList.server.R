# ====感染確認情報====
output$news <- renderDataTable({
  newsData <-
    data.table(
      paste0(
        "<small>",
        as.POSIXct(as.character(news$date), format = "%Y%m%d"),
        "</small><br><a href='",
        news$link,
        "'>",
        news$title,
        "</a>"
      )
    )
  datatable(
    newsData[order(-V1)],
    options = list(
      dom = "tp",
      scrollY = "360px"
    ),
    rownames = F,
    colnames = i18n$t("感染確認情報"),
    escape = F
  )
})