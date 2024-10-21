#' @export
ui_footer <- function(id) {
  {
    box::use(shiny = shiny[tags, HTML])
    box::use(.. / router / route_link[route_link])
    box::use(glue)
  }
  ns <- shiny$NS(id)
  shiny$uiOutput(ns("ui"))
}

#' @export
server_footer <- function(id, credentials) {
  {
    box::use(glue)
    box::use(shiny = shiny[tags, HTML])
    box::use(.. / router / route_link[route_link])
    box::use(.. / sidebar / site_sidebar)
    box::use(.. / inputs / inputs)
    box::use(.. / gmail / gmail)
    box::use(.. / documentation / documentation)
  }
  shiny$moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns

      output$sendMessage <- shiny$renderUI({
        tags$div(
          class = "row",
          tags$div(
            class = "col-12 ",
            inputs$textAreaInput(ns("message"), tags$h5("Send us a message."))
          ),
          tags$div(
            class = " col-12 d-flex justify-content-end",
            shiny$actionButton(ns("submitMessage"), "Submit", class = "btn-primary")
          )
        )
      })

      shiny$observeEvent(input$submitMessage, {
        box::use(.. / aws / sns / sns)
        ns_common_store_admin <- shiny$NS("fdrennan")

        sns$sns_send(ns_common_store_admin, Message = input$message)
      })



      output$ui <- shiny$renderUI({
        tags$footer(
          class = "row justify-content-center m-3 border-3 border-top",
          tags$div(
            class = "col-sm-8",
            shiny$uiOutput(ns("sendMessage"))
          ),
          tags$div(
            class = "col-12 d-flex justify-content-center align-items-center",
            tags$p(
              "© 2023 NDEXR. All rights reserved."
            )
          )
        )
      })

      site_sidebar$server_site_sidebar("site_sidebar")
    }
  )
}
