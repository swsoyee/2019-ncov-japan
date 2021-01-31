output$user <- renderUser({
  dashboardUser(
    name = "Su Wei",
    image = "Icon/wei_su.jpg",
    title = "Developer",
    subtitle = "Front-End Engineer | ex-Bioinformatician",
    footer = tagList(
      actionButton(
        inputId = "sponsorMe",
        label = i18n$t("スポンサー"),
        icon = icon("heart"),
        style = sprintf("background-color:%s;color:white;", middleRed),
        onclick = sprintf(
          "window.open('%s')",
          "https://github.com/sponsors/swsoyee"
        )
      ),
      actionButton(
        inputId = "feedback",
        label = i18n$t("コメント"),
        icon = icon("comments"),
        style = sprintf("background-color:%s;color:white;", middleBlue),
        onclick = sprintf(
          "window.open('%s')",
          "https://github.com/swsoyee/2019-ncov-japan/discussions"
        )
      )
    ),
    fluidRow(
      tags$div(
        style = "font-size:30px;letter-spacing:.5rem;text-align:center",
        tags$a(href = "https://github.com/swsoyee/2019-ncov-japan", icon("github")),
        tags$a(href = "https://twitter.com/swsoyee", icon("twitter")),
        tags$a(href = "https://www.linkedin.com/in/infinityloop/", icon("linkedin"))
      )
    )
  )
})
