output$user <- renderUser({
  dashboardUser(
    name = "Su Wei",
    image = "profile.png",
    title = "Developer",
    subtitle = "Front-End Engineer | ex-Bioinformatician",
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
