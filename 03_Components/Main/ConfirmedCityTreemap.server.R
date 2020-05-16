createConfirmedCityTreemap <- function(dataset) {
  parent <- "県名"
  child <- "市名"
  value <- colnames(dataset)[ncol(dataset)]
  setnames(dataset, value, "累計")
  dataset %>%
    e_charts() %>%
    e_treemap(県名, 市名, 累計,
      upperLabel = list(show = T, color = "#222"),
      left = "1%", right = "1%", bottom = "10%"
    ) %>%
    e_tooltip() %>%
    e_title(text = i18n$t("5月9までの市区町村の感染者数"), 
            subtext = i18n$t("データソース：@kenmo_economics\n※陽性者数は居住地が判明した方のみを集計しているので、県の総計と一致しません。\n※5月9日以後のデータは収集されないため、グラフの更新も中止となります。"),
            sublink = "https://twitter.com/kenmo_economics")
}

output$confirmedCityTreemap <- renderEcharts4r({
  createConfirmedCityTreemap(confirmedCityTreemapData)
})