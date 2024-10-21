#' @export
ui_navigation <- function(id = "navigation") {
  box::use(shiny = shiny[tags])
  ns <- shiny$NS(id)
  shiny$uiOutput(ns("ui"))
}

#' @export
server_navigation <- function(id = "navigation") {
  box::use(shiny = shiny[tags])
  shiny$moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
      output$ui <- shiny$renderUI({
        shiny$div("navigation")
      })
    }
  )
}
