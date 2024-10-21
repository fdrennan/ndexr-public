#' @export
ui_footer <- function(id = "footer", links) {
  box::use(shiny = shiny[tags, HTML], glue)
  ns <- shiny$NS(id)
  footer_tags <- lapply(links, function(link) {
    tags$a(
      class = "btn btn-link btn-floating btn-med text-dark",
      href = link$href,
      role = "button",
      target = "_blank",
      if (!is.null(link$img_src)) {
        tags$img(
          src = link$img_src,
          alt = link$alt,
          width = link$width,
          height = link$height
        )
      } else {
        tags$i(class = link$icon_class)
      }
    )
  })

  tags$div(
    class = "text-center p-1",
    style = "position: fixed; bottom: 0; width: 100%; background-color: #f8f9fa;",
    footer_tags
  )
}

#' @export
server_footer <- function(id, credentials) {
  box::use(shiny = shiny[tags, HTML])
  shiny$moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
    }
  )
}
