#' @export
ui_site_sidebar <- function(id = "site_sidebar") {
  box::use(shiny = shiny[tags, HTML])
  ns <- shiny$NS(id)
  shiny$uiOutput(ns("ui"))
}

#' @export
server_site_sidebar <- function(id = "site_sidebar") {
  box::use(shiny = shiny[tags, HTML])
  box::use(. / site_sidebar)
  shiny$moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
      output$ui <- shiny$renderUI({
        tags$div(
          class = "d-flex flex-column justify-content-between align-items-center",
          tags$table(
            class = "table table-hover table-dark",
            tags$tbody(
              tags$tr(
                tags$td(
                  tags$a(
                    href = "./#!/user_login",
                    class = " nav-link p-1 m-3",
                    "login"
                  )
                )
              ),
              tags$tr(
                tags$td(
                  tags$a(
                    href = "./#!/aws",
                    class = " nav-link p-1 m-3",
                    "ndexr console"
                  )
                )
              ),
              tags$tr(
                tags$td(
                  tags$a(
                    href = "./#!/management",
                    class = " nav-link p-1 m-3",
                    "user management"
                  )
                )
              ),
              tags$tr(
                tags$td(
                  tags$a(
                    href = "https://ndexr.io",
                    class = " nav-link p-1 m-3",
                    "ndexr.io"
                  )
                )
              )
            )
          )
        )
      })
    }
  )
}
