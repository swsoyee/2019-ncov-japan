UserListItemWrappter <- function(image = NULL,
                                 href = NULL,
                                 icon = NULL,
                                 title = NULL,
                                 subtitle = NULL) {
  titleWrapper <- if (is.null(href)) {
    title
  } else {
    tags$a(
      href = href,
      icon(icon),
      tags$b(title)
    )
  }
  
  userListItem(
    image = image,
    title = titleWrapper,
    subtitle = subtitle
  )
}
