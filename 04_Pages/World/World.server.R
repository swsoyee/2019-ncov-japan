observeEvent(input$sideBarTab, {
  if (input$sideBarTab == "world" && is.null(GLOBAL_VALUE$World$PositiveAndDeath)) {
    # GLOBAL_VALUE <- list(
    #   World = list(
    #     Summary = NULL,
    #     SummaryTable = NULL
    #   )
    # ) # TEST
    GLOBAL_VALUE$World$Summary <- fread(paste0(DATA_PATH, "FIND/worldSummary.csv"))
    GLOBAL_VALUE$World$Summary[, date := as.Date(date)]
    GLOBAL_VALUE$World$SummaryTable <- fread(paste0(DATA_PATH, "FIND/worldSummaryTable.csv"), sep = "@")
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
      worldTest = NULL,
      worldRate = "{value}% - {value2}%"
    )

    if (!input$switchWorldMapVersion) {
      coronavirus <- coronavirus %>%
        group_by(date)
    } else {
      coronavirus <- coronavirus[date == max(date)]
    }

    map <- coronavirus %>%
      e_charts(country_name_id, timeline = !input$switchWorldMapVersion) %>%
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
      e_title(text = mapName) %>%
      e_tooltip()

    if (!input$switchWorldMapVersion) {
      timeSeriesTitle <- lapply(unique(coronavirus$date), function(i) {
        return(
          list(
            text = mapName,
            subtext = i
          )
        )
      })

      map %>%
        e_timeline_opts(
          playInterval = 500,
          left = "0%",
          right = "0%",
          currentIndex = length(unique(coronavirus$date)) - 1
        ) %>%
        e_timeline_serie(
          title = timeSeriesTitle
        )
    } else {
      map %>%
        e_title(
          text = mapName,
          subtext = max(coronavirus$date)
        )
    }
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
    ) %>%
    e_group("worldLine")
})

output$countryTestLine <- renderEcharts4r({
  data <- selectedCountryNameForLineChart()
  world <- data[, .(
    test = sum(tests_cumulative, na.rm = T),
    new_tests = sum(new_tests, na.rm = T)
  ),
  by = "date"
  ][order(date)]

  totalTest <- tail(world$tests_cumulative, n = 1)

  lineTitle <- ifelse(
    "name" %in% names(input$worldConfirmed_clicked_data),
    input$worldConfirmed_clicked_data$name,
    "World"
  )

  world[test == 0, test := NA] %>%
    e_chart(date) %>%
    e_line(test, name = "Tests (Total)", symbol = "circle", smooth = T, symbolSize = 1, itemStyle = list(color = darkYellow)) %>%
    e_bar(new_tests, name = "New Tests", itemStyle = list(color = lightYellow), y_index = 1, stack = 1) %>%
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
    e_grid(left = "5%", right = "15%") %>%
    e_title(
      text = sprintf(
        "%s",
        lineTitle
      ),
      subtext = sprintf(
        "Total Test: %s",
        totalTest
      )
    ) %>%
    e_group("worldLine") %>%
    e_connect_group("worldLine")
})

output$worldSummaryTable <- renderDataTable({
  coronavirusSummary <- GLOBAL_VALUE$World$SummaryTable
  sketch_summary <- htmltools::withTags(table(
    class = "display",
    thead(
      tr(
        th(rowspan = 2, "Rank"),
        th(rowspan = 2, "Country"),
        th(colspan = 3, tagList(icon("vials"), "Tests")),
        th(colspan = 4, tagList(icon("procedures"), "Cases")),
        th(colspan = 4, tagList(icon("bible"), "Deaths")),
        th(rowspan = 2, tagList("Cases/Tests"))
      ),
      tr(
        lapply(
          c(
            c("Total", "Trends", "Per 100K pop"),
            rep(c("Total", "Trends", "New", "Per 100K pop"), 2)
          ),
          th
        )
      )
    )
  ))

  datatable(
    coronavirusSummary[, .(Country,
                           Tests, `Test Trends`, `Tests/100K pop`,
                           Cases, `Cases Trends`, `New Cases`, `Cases/100K pop`,
                           Deaths, `Deaths Trends`, `New Deaths`, `Deaths/100K pop`,
                           `Cases/Tests`)],
    container = sketch_summary,
    escape = F,
    options = list(
      # paging = F,
      # scrollY = "540px",
      scrollX = T,
      fnDrawCallback = htmlwidgets::JS("
            function() {
              HTMLWidgets.staticRender();
            }
          ")
    )
  ) %>%
    spk_add_deps() %>%
    formatRound(
      columns = c("Tests", "Cases", "New Cases", "Deaths", "New Deaths"),
      digits = 0
    ) %>%
    formatRound(
      columns = c("Tests/100K pop", "Cases/100K pop", "Deaths/100K pop"),
      digits = 0
    ) %>%
    formatStyle(
      columns = "Tests",
      color = do.call(
        styleInterval,
        generateColorStyle(data = coronavirusSummary$Tests, colors = c(lightYellow, darkYellow), by = 10^6),
      ),
      background = styleColorBar(c(0, max(coronavirusSummary$Tests, na.rm = T)), middleYellow, angle = -90),
      backgroundSize = "98% 18%",
      backgroundRepeat = "no-repeat",
      backgroundPosition = "bottom",
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "Cases",
      background = styleColorBar(c(0, max(coronavirusSummary$Cases, na.rm = T)), middleRed, angle = -90),
      color = do.call(
        styleInterval,
        generateColorStyle(data = coronavirusSummary$Cases, colors = c(lightRed, darkRed), by = 10^6),
      ),
      backgroundSize = "98% 18%",
      backgroundRepeat = "no-repeat",
      backgroundPosition = "bottom",
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "New Cases",
      color = do.call(
        styleInterval,
        generateColorStyle(data = coronavirusSummary$`New Cases`, colors = c(lightRed, darkRed), by = 100),
      ),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = "Deaths",
      background = styleColorBar(c(0, max(coronavirusSummary$Deaths, na.rm = T)), darkNavy, angle = -90),
      backgroundSize = "98% 18%",
      backgroundRepeat = "no-repeat",
      backgroundPosition = "bottom"
    ) %>%
    formatStyle(
      columns = c("Tests/100K pop"),
      backgroundColor = do.call(
        styleInterval,
        generateColorStyle(data = coronavirusSummary$`Tests/100K pop`, colors = c("#FFFFFF", darkYellow), by = 10^4)
      ),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = c("Cases/100K pop"),
      backgroundColor = do.call(
        styleInterval,
        generateColorStyle(data = coronavirusSummary$`Cases/100K pop`, colors = c("#FFFFFF", darkRed), by = 100)
      ),
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns = c("Deaths/100K pop"),
      backgroundColor = do.call(
        styleInterval,
        generateColorStyle(data = coronavirusSummary$`Deaths/100K pop`, colors = c("#FFFFFF", darkNavy), by = 1)
      ),
      fontWeight = "bold"
    )
})
