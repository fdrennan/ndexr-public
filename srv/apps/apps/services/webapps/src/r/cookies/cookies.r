#' @export
server_cookies <- function(id, username) {
  box::use(shinyjs[js])
  box::use(shiny)
  box::use(.. / inputs / inputs)
  shiny$moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns

      cookieStored <- shiny$reactive({
        #
        session$sendCustomMessage("cookie-get", list(id = "cookie"))
        shiny$req(length(input$cookie) > 0)
      })

      shiny$observe({
        msg <- list(
          name = "logintime",
          value = as.numeric(Sys.time()),
          id = "cookie"
        )
        session$sendCustomMessage("cookie-set", msg)
      })

      shiny$observe({
        shiny$req(cookieStored())
        shiny$showModal(
          inputs$modalDialog(
            "We use cookies on our website to enhance your browsing experience.
            By continuing to use our website, you consent to our use of cookies. "
          )
        )
      })
    }
  )
}
