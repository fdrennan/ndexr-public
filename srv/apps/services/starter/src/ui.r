#' @export
ui <- function(request) {
  box::use(shiny = shiny[tags], cli)
  box::use(. / r / home)

  request <- as.list.environment(request)

  print(request)

  home$ui_home("home", request)
}
