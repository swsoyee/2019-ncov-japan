observeEvent(input$sideBarTab, {
  if (input$sideBarTab == "world" && is.null(GLOBAL_VALUE$World$PositiveAndDeath)) {
    # GLOBAL_VALUE <- list(
    #   World = list(
    #     Summary = NULL
    #   )
    # ) # TEST
    GLOBAL_VALUE$World$Summary <- fread(paste0(DATA_PATH, "FIND/worldSummary.csv"))
    GLOBAL_VALUE$World$Summary[, date := as.Date(date)]
  }
})

output$worldConfirmedDateSelector <- renderUI({
  dateRangeInput(
    inputId = "selectWorldDay",
    label = i18n$t("日付選択"),
    min = min(GLOBAL_VALUE$World$Summary$date),
    max = max(GLOBAL_VALUE$World$Summary$date),
    start = max(GLOBAL_VALUE$World$Summary$date) - 30,
    end = max(GLOBAL_VALUE$World$Summary$date),
    separator = " - ",
    format = "yyyy年m月d日",
    language = languageSetting
  )
})

worldData <- reactive({
  if (length(input$selectWorldDay) > 0) {
    return(
      GLOBAL_VALUE$World$Summary[date >= as.Date(input$selectWorldDay[1]) & date <= as.Date(input$selectWorldDay[2])]
    )
  } else {
    return(NULL)
  }
})

selectedCountryNameForLineChart <- reactive({
  if (length(input$worldConfirmed_clicked_data) == 2) {
    data <- GLOBAL_VALUE$World$Summary[country_name_id == input$worldConfirmed_clicked_data$name]
  } else {
    data <- GLOBAL_VALUE$World$Summary
  }
  return(data)
})

output$worldConfirmed <- renderEcharts4r({
  if (!is.null(worldData())) {
    worldMapSelector <- input$switchWorldMap
    coronavirus <- worldData()
    columnNameForMap <- switch(worldMapSelector,
      worldCase = "casesPer100k",
      worldTest = "testsPer100k",
      worldRate = "positiveRate"
    )
    mapName <- switch(worldMapSelector,
      worldCase = "Number of Cases/100k Population",
      worldTest = "Number of Test/100k Population",
      worldRate = "Number of Cases/Test"
    )
    colorScale <- switch(worldMapSelector,
      worldCase = c("#ffffff", "#cd4652"),
      worldTest = c("#ffffff", "#43abb6", "#602B59"),
      worldRate = c("#ffffff", "#43abb6", "#602B59")
    )
    splitList <- switch(worldMapSelector,
      worldCase = list(
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
      ),
      worldTest = list(
        list(min = 5000),
        list(min = 2500, max = 5000),
        list(min = 1200, max = 2500),
        list(min = 600, max = 1200),
        list(min = 300, max = 600),
        list(min = 200, max = 300),
        list(min = 60, max = 200),
        list(min = 30, max = 60),
        list(min = 0, max = 30),
        list(value = 0)
      ),
      worldRate = list(
        list(min = 60),
        list(min = 40, max = 60),
        list(min = 20, max = 40),
        list(min = 12, max = 20),
        list(min = 8, max = 12),
        list(min = 4, max = 6),
        list(min = 2, max = 4),
        list(min = 1, max = 2),
        list(min = 0, max = 1),
        list(min = 0, max = 0)
      ),
    )
    legendFormatter <- switch(worldMapSelector,
      worldCase = NULL,
      worldTest =  NULL,
      worldRate = "{value}% - {value2}%"
    )

    coronavirus %>%
      group_by(date) %>%
      e_charts(country_name_id, timeline = TRUE) %>%
      e_map_(columnNameForMap,
        name = mapName,
        itemStyle = list(
          borderWidth = 0.2,
          borderColor = "#9C9C9C"
        ),
        scaleLimit = list(max = 2.5, min = 1),
        zoom = 1.2,
        roam = TRUE
      ) %>%
      e_visual_map_(
        columnNameForMap,
        type = "piecewise",
        bottom = "20%",
        left = "0%",
        inRange = list(color = colorScale),
        splitList = splitList,
        formatter = legendFormatter
      ) %>%
      e_timeline_opts(
        playInterval = 500,
        left = "0%",
        right = "0%",
        currentIndex = length(unique(coronavirus$date)) - 1
      ) %>%
      e_title(text = mapName) %>%
      e_tooltip()
  }
})

output$countryLine <- renderEcharts4r({
  data <- selectedCountryNameForLineChart()
  world <- data[, .(
    cases = sum(cases),
    new_cases = sum(new_cases),
    deaths = sum(deaths),
    new_deaths = sum(new_deaths)
  ),
  by = "date"
  ][order(date)]

  totalConfirmed <- tail(world$cases, n = 1)
  totalDeaths <- tail(world$deaths, n = 1)
  lineTitle <- ifelse(
    "name" %in% names(input$worldConfirmed_clicked_data),
    input$worldConfirmed_clicked_data$name,
    "World"
  )

  world[deaths == 0, deaths := NA] %>%
    e_chart(date) %>%
    e_line(cases, name = "Positive", symbol = "circle", smooth = T, symbolSize = 1, itemStyle = list(color = darkRed)) %>%
    e_line(deaths, name = "Death", symbol = "circle", smooth = T, symbolSize = 1, itemStyle = list(color = darkNavy)) %>%
    e_bar(new_deaths, name = "New Death", itemStyle = list(color = darkNavy), y_index = 1, stack = 1) %>%
    e_bar(new_cases, name = "New positive", itemStyle = list(color = darkRed), y_index = 1, stack = 1) %>%
    e_x_axis(
      splitLine = list(lineStyle = list(opacity = 0.2))
    ) %>%
    e_y_axis(
      splitLine = list(lineStyle = list(opacity = 0.2)),
      name = "Cumulative",
      axisLabel = list(inside = T),
      nameTextStyle = list(padding = c(0, 0, 0, 40)),
      axisTick = list(show = F),
      type = "log"
    ) %>%
    e_y_axis(
      splitLine = list(lineStyle = list(opacity = 0.2)),
      name = "New",
      axisTick = list(show = F),
      index = 1
    ) %>%
    e_legend(
      type = "scroll",
      left = "1%",
      bottom = "1%"
    ) %>%
    e_tooltip(trigger = "axis") %>%
    e_grid(left = "5%", right = "15%", top = "25%") %>%
    e_title(
      text = sprintf(
        "%s",
        lineTitle
      ),
      subtext = sprintf(
        "Total Positive: %s\nTotal Deaths: %s (%s%%)",
        totalConfirmed,
        totalDeaths,
        round(totalDeaths / totalConfirmed * 100, 2)
      )
    )
})
