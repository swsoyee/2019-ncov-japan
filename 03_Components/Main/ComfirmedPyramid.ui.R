Component.ComfirmedPyramid <- function() {
  boxPlus(
    title = tagList(icon("venus-mars"), i18n$t("歳代・性別")),
    width = 4,
    enable_label = T,
    collapsible = T,
    collapsed = T,
    # 集計時間：
    # label_text = paste(lang[[langCode]][123], max(as.Date(
    #   positiveDetail$発表日
    # ), na.rm = T)),
    uiOutput("ageGenderOption"),
    echarts4rOutput("genderBar"),
    closable = F,
    footer = tags$small(
      i18n$t("データ提供："),
      tags$a(icon("database"), "SIGNATE COVID-19 Dataset",
        # https://twitter.com/kenmo_economics
        href = "https://drive.google.com/drive/folders/1EcVW5JQKMB6zoyfHm8_zLVj---t_hccF"
      )
    )
  )
}
