#' @export
ui_postgres <- function(id = "postgres") {
  box::use(shiny = shiny[tags, HTML])
  ns <- shiny$NS(id)
  shiny$uiOutput(ns("ui"))
}

#' @export
server_postgres <- function(id = "postgres", data) {
  {
    box::use(shiny = shiny[tags, HTML])
    box::use(.. / postgres)
    box::use(DBI)
    box::use(purrr)
    box::use(.. / postgres)
  }

  shiny$moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
      output$ui <- shiny$renderUI({
        tables <- postgres$tables_list()
        out <- purrr$map(tables, function(x) {
          tags$div(
            class = "col-lg-2 col-md-3", x
          )
        })

        shiny$tagAppendAttributes(out, class = "row")
      })
    }
  )
}
