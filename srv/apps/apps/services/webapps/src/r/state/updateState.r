#' updateState
#' @export updateState
updateState <- function(input, id) {
  box::use(shiny[is.reactivevalues, showNotification, tags, reactiveValuesToList])
  box::use(
    .. / connections / sqlite,
    .. / connections / storr
  )
  box::use(. / update.list[update.list])



  if (is.reactivevalues(input)) {
    input <- reactiveValuesToList(input)
  }

  if (!length(input)) {
    return()
  }

  con <- storr$connection_storr()
  state <- tryCatch(con$get(id), error = function(err) list())
  state <- update.list(state, input)
  con$set(id, state)
  if (getOption("state.verbose")) {
    box::use(jsonlite)
    showNotification(
      closeButton = TRUE, duration = 10,
      tags$pre(style = "max-height: 25vh; overflow-y: auto;", tags$code(
        jsonlite$toJSON(state, pretty = TRUE)
      ))
    )
  }
}
