Component.ComfirmedPyramid <- function() {
  boxPlus(
    # 歳代・性別
    title = tagList(icon("venus-mars"), lang[[langCode]][124]),
    width = 4,
    enable_label = T,
    collapsible = T,
    collapsed = T,
    # 集計時間：
    # label_text = paste(lang[[langCode]][123], max(as.Date(
    #   positiveDetail$発表日
    # ), na.rm = T)),
    echarts4rOutput("genderBar") %>% withSpinner(),
    closable = F,
    # データ提供：
    footer = tags$small(
      lang[[langCode]][125],
      # @kenmo_economics
      tags$a(icon("database"), "SIGNATE COVID-19 Dataset",
        # https://twitter.com/kenmo_economics
        href = "https://drive.google.com/drive/folders/1EcVW5JQKMB6zoyfHm8_zLVj---t_hccF"
      )
    )
  )
}