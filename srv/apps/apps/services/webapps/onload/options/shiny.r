options(
  shiny.port = 8000,
  shiny.host = "0.0.0.0",
  shiny.maxRequestSize = 200,
  shiny.json.digits = 7,
  shiny.suppressMissingContextError = FALSE,
  shiny.table.class = NULL,
  shiny.fullstacktrace = FALSE,
  shiny.maxRequestSize = 30 * 1024^2,
  port = 8000,
  docs = getOption("plumber.docs"),
  docs.callback = getOption("plumber.docs.callback"),
  trailingSlash = getOption("plumber.trailingSlash"),
  methodNotAllowed = getOption("plumber.methodNotAllowed"),
  apiURL = getOption("plumber.apiURL"),
  apiScheme = getOption("plumber.apiScheme"),
  apiHost = "0.0.0.0",
  apiPort = "8000",
  apiPath = getOption("plumber.apiPath"),
  maxRequestSize = getOption("plumber.maxRequestSize"),
  sharedSecret = getOption("plumber.sharedSecret"),
  legacyRedirects = getOption("plumber.legacyRedirects")
)

if (isFALSE(getOption("docker"))) {
  message("Shiny Development Mode")
  options(
    apiHost = "127.0.0.1",
    shiny.host = "127.0.0.1",
    shiny.autoreload = FALSE,
    shiny.reactlog = FALSE,
    shiny.minified = FALSE,
    # shiny.error = utils::recover,
    shiny.deprecation.messages = TRUE,
    shiny.sanitize.errors = FALSE
  )
}
