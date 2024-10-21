#' @export
login_user <- function(path = "config.yml", userdata = list(
                         email = "drennanfreddy@gmail.com",
                         username = "fdrennan"
                       )) {
  box::use(shiny, . / cognito / cognito)
  if (isTRUE(as.logical(Sys.getenv("USE_COGNITO")))) {
    login <- cognito$server_cognito("cognito", path = path)
  } else {
    login <- shiny$reactive({
      list(
        userdata = userdata
      )
    })
  }
}
