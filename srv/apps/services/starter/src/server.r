#' @export
server <- function(input, output, session) {
  box::use(
    shiny = shiny[tags],
    . / site_shared,
    . / r / connections / postgres,
    . / r / inputs / inputs,
    . / r / home
  )

  session_home <- as.list.environment(session)

  if (interactive()) {
    session_home$request$HTTP_HOST <- getOption("ndexr_site", request$HTTP_HOST)
  }

  cli::cli_inform("Running home server...")
  home$server_home("home", session_home)
}
