observeEvent(input$linePlot, {
  if ((input$linePlot == "vaccine") && is.null(GLOBAL_VALUE$vaccine)) {
    vaccine <- fread(file = "50_Data/MHLW/vaccine.csv")
    vaccine$date <- as.Date(as.character(vaccine$date), format = "%Y%m%d")
    vaccine$total <- rowSums(vaccine[, 2:ncol(vaccine)])
    vaccine[, `:=` (
      medical_first = medical_first_pfizer + medical_first_moderna,
      medical_second = medical_second_pfizer + medical_second_moderna,
      elderly_first = elderly_first_pfizer + elderly_first_moderna,
      elderly_second = elderly_second_pfizer + elderly_second_moderna
    )]
    GLOBAL_VALUE$vaccine <- vaccine
  }
})

output$vaccine_line_plot <- renderEcharts4r({
  if (!is.null(GLOBAL_VALUE$vaccine)) {
    vaccine <- GLOBAL_VALUE$vaccine
    vaccine %>%
      e_chart(x = date) %>%
      e_bar(
        total,
        name = "合計",
        barGap = "-100%",
        itemStyle = list(
          color = darkBlue
        )
      ) %>%
      e_bar(
        medical_first,
        name = "医療従事者（１回目）",
        itemStyle = list(
          color = lightGreen
        ),
        stack = 1
      ) %>%
      e_bar(
        medical_second,
        name = "医療従事者（２回目）",
        itemStyle = list(
          color = darkGreen
        ),
        stack = 1
      ) %>%
      e_bar(
        elderly_first,
        name = "高齢者（１回目）",
        itemStyle = list(
          color = superDarkGreen
        ),
        stack = 1
      ) %>%
      e_bar(
        elderly_second,
        name = "高齢者（２回目）",
        itemStyle = list(
          color = superDarkGreen2
        ),
        stack = 1
      ) %>%
      e_grid(
        left = "3%",
        top = "18%"
      ) %>%
      e_x_axis(
        minInterval = 3600 * 24 * 1000,
        axisLabel = list(
          formatter = "{yyyy}-{MM}-{dd}"
        ),
        splitLine = list(
          lineStyle = list(opacity = 0.2)
        )
      ) %>%
      e_y_axis(
        name = "回数",
        nameGap = 10,
        nameTextStyle = list(padding = c(0, 0, 0, 50)),
        splitLine = list(lineStyle = list(opacity = 0.2)),
        z = 999,
        axisLabel = list(inside = T),
        axisTick = list(show = F)
      ) %>%
      e_title(
        text = "先行接種の接種実績",
        subtext = sprintf(
          "ソース：厚生労働省（最終更新日：%s）",
          tail(vaccine$date, n = 1)
        ),
        sublink = "https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/vaccine_sesshujisseki.html"
      ) %>%
      e_legend(
        type = "scroll",
        orient = "vertical",
        left = "18%",
        top = "15%",
        right = "15%"
      ) %>%
      e_tooltip(trigger = "axis") %>%
      e_datazoom(
        minValueSpan = 604800000, # 3600 * 24 * 1000 * 7,
        startValue = max(vaccine$date, na.rm = T) - 28
      )
  }
})

output$vaccine_medical_total <- renderUI({
  if (!is.null(GLOBAL_VALUE$vaccine)) {
    vaccine <- GLOBAL_VALUE$vaccine
    # Calculate number by date
    total_number_by_date <- vaccine[, medical_first + medical_second]
    diff <- tail(total_number_by_date, n = 1)
    descriptionBlock(
      number = countup(diff),
      numberIcon = getChangeIconWrapper(diff),
      header = countup(sum(total_number_by_date)),
      numberColor = "olive",
      rightBorder = TRUE,
      text = "医療従事者等"
    )
  }
})

output$vaccine_elderly_total <- renderUI({
  if (!is.null(GLOBAL_VALUE$vaccine)) {
    vaccine <- GLOBAL_VALUE$vaccine
    # Calculate number by date
    total_number_by_date <- vaccine[, elderly_first + elderly_second]
    diff <- tail(total_number_by_date, n = 1)
    descriptionBlock(
      number = countup(diff),
      numberIcon = getChangeIconWrapper(diff),
      header = countup(sum(total_number_by_date)),
      numberColor = "black",
      rightBorder = FALSE,
      text = "高齢者等"
    )
  }
})

output$vaccine_progress <- renderUI({
  if (!is.null(GLOBAL_VALUE$vaccine)) {
    vaccine <- GLOBAL_VALUE$vaccine
    progressBar(
      id = "vaccine_progress",
      value = sum(vaccine$medical_second + vaccine$elderly_second),
      total = sum(vaccine$medical_first + vaccine$elderly_first),
      display_pct = TRUE,
      striped = TRUE,
      status = "success",
      title = "２回目 / １回目"
    )
  }
})

output$vaccineTwitterShare <- renderUI({
  vaccine <- GLOBAL_VALUE$vaccine
  if (!is.null(vaccine)) {
    total_first <- sum(colSums(vaccine[, .(medical_first, elderly_first)]))
    total_second <- sum(colSums(vaccine[, .(medical_second, elderly_second)]))
    vaccineTwitterShareUrl <- sprintf(
      paste0(
        "https://twitter.com/intent/tweet?text=",
        "%sまで、新型コロナウイルスワクチンの合計接種数は%s、",
        "うち１回目の接種は%s回、２回目のは%s回。",
        "接種した人の２回接種完成率は%s%%25。",
        "詳しくは「新型コロナウイルス感染速報」まで",
        "&url=https://covid-2019.live/&hashtags=新型コロナ,新型コロナワクチン"
      ),
      tail(vaccine$date, n = 1),
      prettyNum(sum(vaccine$total), big.mark = ","),
      prettyNum(total_first, big.mark = ","),
      prettyNum(total_second, big.mark = ","),
      round(total_second / total_first * 100, 2)
    )

    actionButton(
      inputId = "vaccineTwitterShare",
      label = "現状をシェア",
      icon = icon("twitter"),
      style = "background-color:#1DA1F2;color:white;",
      onclick = sprintf(
        "window.open('%s')",
        vaccineTwitterShareUrl
      )
    )
  }
})
