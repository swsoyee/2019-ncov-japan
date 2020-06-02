observeEvent(input$sideBarTab, {
  if (input$sideBarTab == "world" && is.null(GLOBAL_VALUE$World)) {
    # GLOBAL_VALUE <- list(
    #   World = NULL
    # ) # TEST

    GLOBAL_VALUE$World <- fread(paste0(DATA_PATH, "FIND/world.csv"))
    GLOBAL_VALUE$World[, date := as.Date(date)]
  }
})

output$worldConfirmedDateSelector <- renderUI({
  dateRangeInput(
    inputId = "selectWorldDay",
    label = i18n$t("日付選択"),
    min = min(GLOBAL_VALUE$World$date),
    max = max(GLOBAL_VALUE$World$date),
    start = max(GLOBAL_VALUE$World$date) - 30,
    end = max(GLOBAL_VALUE$World$date),
    separator = " - ",
    format = "yyyy年m月d日",
    language = languageSetting
  )
})

worldData <- reactive({
  if (length(input$selectWorldDay) > 0) {
    return(
      GLOBAL_VALUE$World[date >= as.Date(input$selectWorldDay[1]) & date <= as.Date(input$selectWorldDay[2])]
    )
  } else {
    return(NULL)
  }
})

output$worldConfirmed <- renderEcharts4r({
  # print(input$selectWorldDay[1])
  if (!is.null(worldData())) {
    coronavirus <- worldData()
    coronavirus %>%
      group_by(date) %>%
      e_charts(country_name_id, timeline = TRUE) %>%
      e_map(casesPer100k,
        name = "Number of cases/100k population",
        itemStyle = list(
          borderWidth = 0.2,
          borderColor = "#9C9C9C"
        ),
        scaleLimit = list(max = 2.5, min = 1),
        roam = TRUE
      ) %>%
      e_visual_map(
        casesPer100k,
        type = "piecewise",
        bottom = "20%",
        left = "0%",
        inRange = list(color = c("#FFFFFF", "#B03C2D")),
        splitList = list(
          list(min = 500),
          list(min = 200, max = 500),
          list(min = 100, max = 200),
          list(min = 50, max = 100),
          list(min = 20, max = 50),
          list(min = 10, max = 20),
          list(min = 5, max = 10),
          list(min = 0, max = 5),
          list(min = 0, max = 1),
          list(value = 0)
        )
      ) %>%
      e_timeline_opts(
        playInterval = 500,
        loop = F,
        left = "0%",
        right = "0%",
        currentIndex = length(unique(coronavirus$date)) - 1
      ) %>%
      e_title(text = "Number of cases/100k population") %>%
      e_tooltip()
  }
})
