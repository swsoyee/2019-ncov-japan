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
    e_title(text = paste0("集計時間：", value), 
            subtext = "データソース：@kenmo_economics", sublink = "https://twitter.com/kenmo_economics")
}

output$confirmedCityTreemap <- renderEcharts4r({
  createConfirmedCityTreemap(confirmedCityTreemapData)
})