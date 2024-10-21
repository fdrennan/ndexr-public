#' @export
ui_body <- function(id = "body", ..., request = NULL) {
  box::use(shiny = shiny[tags])
  box::use(.. / connections / postgres)
  ns <- shiny$NS(id)

  tags$div(
    tags$div(
      class = "row",
      tags$div(
        class = "col text-center",
        tags$h3("ndexr")
      )
    ),
    tags$div(
      class = "bouncing-emoji",
      tags$a(
        href = "https://console.ndexr.io",
        tags$span("😊", class = "mirror")
      )
    ),
    ...
  )
}

#' @export
server_body <- function(id = "body", ...) {
  box::use(shiny = shiny[tags])
  shiny$moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
    }
  )
}
