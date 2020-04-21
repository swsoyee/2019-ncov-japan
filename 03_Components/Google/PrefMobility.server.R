observeEvent(input$sideBarTab, {
  if (input$sideBarTab == "google" && is.null(GLOBAL_VALUE$Google[[1]])) {
    # GLOBAL_VALUE <- list(Google = list(
    #       mobility = fread(paste0(DATA_PATH, "Google/Global_Mobility_Report.Japan.csv"))
    #   )) # TEST
    GLOBAL_VALUE$Google <- list(
      mobility = fread(paste0(DATA_PATH, "Google/Global_Mobility_Report.Japan.csv")),
      table = fread(paste0(DATA_PATH, "Google/Global_Mobility_Report.Japan.Table.csv"), sep = "@")
    )
  }
})

createMobilityCalendar <- function(data, pref, serie, title) {
  data <- data[nameJa == pref]
  minValue <- min(data[[serie]])
  maxValue <- max(data[[serie]])
  scaleStandard <- ifelse(abs(minValue) >= abs(maxValue), abs(minValue), abs(maxValue))

  data %>%
    e_charts(date, height = 200) %>%
    e_calendar(
      range = c("2020-02-16", "2020-04-16"),
      left = 25, cellSize = 15,
      splitLine = list(show = F), itemStyle = list(borderWidth = 2, borderColor = "#FFFFFF"),
      dayLabel = list(nameMap = c("日", "月", "火", "水", "木", "金", "土")),
      monthLabel = list(nameMap = "cn")
    ) %>%
    e_heatmap_(serie, coord_system = "calendar") %>%
    # e_legend(show = T) %>%
    e_visual_map(
      top = "10%",
      right = "0%",
      max = scaleStandard,
      min = (0 - scaleStandard),
      show = T,
      inRange = list(color = c(middleGreen, middleYellow, middleRed)), # scale colors
    ) %>%
    e_title(text = title) %>%
    e_tooltip(formatter = htmlwidgets::JS("
        function(params) {
          return(`${params.value[0]}<br> ${params.value[1]}`)
        }
      ")) %>%
    e_group(paste0(pref, "_mobility_calendar"))
}

createMobilityCalendarGroup <- function(data, pref) {
  calendars <- list()
  mobilitySeries <- list(
    "retail_and_recreation_percent_change_from_baseline" = "娯楽関連施設",
    "grocery_and_pharmacy_percent_change_from_baseline" = "食料品やドラッグストア",
    "parks_percent_change_from_baseline" = "公園",
    "transit_stations_percent_change_from_baseline" = "公共交通機関",
    "workplaces_percent_change_from_baseline" = "職場",
    "residential_percent_change_from_baseline" = "住宅"
  )
  for (i in seq(mobilitySeries)) {
    calendars[[paste0(pref, "_", names(mobilitySeries[i]))]] <- createMobilityCalendar(
      data = data,
      pref = pref,
      serie = names(mobilitySeries[i]),
      title = mobilitySeries[i][[1]]
    )
    if (i == length(mobilitySeries)) {
      calendars[[paste0(pref, "_", names(mobilitySeries[i]))]] <-
        calendars[[paste0(pref, "_", names(mobilitySeries[i]))]] %>% e_connect_group(paste0(pref, "_mobility_calendar"))
    }
  }
  return(calendars)
}

output$mobilityCalendar <- renderUI({
  data <- GLOBAL_VALUE$Google$mobility
  if (!is.null(data)) {
    calendars <- createMobilityCalendarGroup(data, input$prefMobility)
    # calendars <- createMobilityCalendarGroup(data, "東京") # TEST
    # for (i in seq(length(calendars))) {
    # TODO なぜかループがいつも最後の一つの値をPickしている
    output[["mobility1"]] <- renderEcharts4r(calendars[[1]])
    output[["mobility2"]] <- renderEcharts4r(calendars[[2]])
    output[["mobility3"]] <- renderEcharts4r(calendars[[3]])
    output[["mobility4"]] <- renderEcharts4r(calendars[[4]])
    output[["mobility5"]] <- renderEcharts4r(calendars[[5]])
    output[["mobility6"]] <- renderEcharts4r(calendars[[6]])

    return(tagList(
      fluidRow(
        column(
          width = 4,
          echarts4rOutput("mobility1", height = "200px")
        ),
        column(
          width = 4,
          echarts4rOutput("mobility2", height = "200px")
        ),
        column(
          width = 4,
          echarts4rOutput("mobility3", height = "200px")
        )
      ),
      fluidRow(
        column(
          width = 4,
          echarts4rOutput("mobility4", height = "200px")
        ),
        column(
          width = 4,
          echarts4rOutput("mobility5", height = "200px")
        ),
        column(
          width = 4,
          echarts4rOutput("mobility6", height = "200px")
        )
      )
    ))
  }
})

output$googleMobilityTable <- renderDataTable({
  data <- GLOBAL_VALUE$Google$table
  # data <- fread(paste0(DATA_PATH, "Google/Global_Mobility_Report.Japan.Table.csv"), sep = "@")
  DT::datatable(data,
    escape = F, 
    caption = "数値は直近１週間（４月１１日時点）の基準値との比較の平均値。",
    options = list(
      dom = "t",
      scrollY = "540px",
      scrollX = T,
      paging = F,
      columnDefs = list(
        list(data = 1, 
             targets = 1, 
             className = "dt-center",
             title = as.character(icon("landmark"))
        ),
        list(data = 2, 
             targets = 2, 
             className = "dt-center",
             title = as.character(icon("umbrella-beach"))
        ),
        list(data = 3, 
             targets = 3, 
             className = "dt-center",
             title = as.character(icon("shopping-cart"))
        ),
        list(data = 4, 
             targets = 4, 
             className = "dt-center",
             title = as.character(icon("tree"))
        ),
        list(data = 5, 
             targets = 5, 
             className = "dt-center",
             title = as.character(icon("subway"))
        ),
        list(data = 6, 
             targets = 6, 
             className = "dt-center",
             title = as.character(icon("briefcase"))
        ),
        list(data = 7, 
             targets = 7, 
             className = "dt-center",
             title = as.character(icon("home"))
             )
      ),
      fnDrawCallback = htmlwidgets::JS("
        function() {
          HTMLWidgets.staticRender();
        }
      ")
    )
  ) %>% spk_add_deps()
})