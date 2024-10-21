#' @export
log_http_headers <- function(request, msg = "") {
  cli::cli_inform("Starting log_http_headers function...")

  box::use(. / r / connections / postgres)

  request <- as.list(request)
  print(request)
  local_development <- is.null(request$HTTP_X_REAL_IP)

  cli::cli_inform("Site-Shared code")
  #
  http_headers <- data.frame(
    timestamp = Sys.time(),
    ip_address = if (local_development) {
      NA_real_
    } else {
      ifelse(is.null(request$HTTP_X_REAL_IP), "", request$HTTP_X_REAL_IP)
    },
    site_name = ifelse(is.null(request$HTTP_HOST), "", request$HTTP_HOST),
    host = ifelse(is.null(request$HTTP_HOST), "", request$HTTP_HOST),
    user_agent = ifelse(is.null(request$HTTP_USER_AGENT), "", request$HTTP_USER_AGENT),
    accept = ifelse(is.null(request$HTTP_ACCEPT), "", request$HTTP_ACCEPT),
    accept_encoding = ifelse(is.null(request$HTTP_ACCEPT_ENCODING), "", request$HTTP_ACCEPT_ENCODING),
    accept_language = ifelse(is.null(request$HTTP_ACCEPT_LANGUAGE), "", request$HTTP_ACCEPT_LANGUAGE),
    connection = ifelse(is.null(request$HTTP_CONNECTION), "", request$HTTP_CONNECTION),
    cookie = ifelse(is.null(request$HTTP_COOKIE), "", request$HTTP_COOKIE),
    # x_forwarded_for = NA_real_,
    # x_forwarded_proto = NA_real_
    x_forwarded_for = ifelse(is.null(request$HTTP_X_FORWARDED_FOR), NA_real_, request$HTTP_X_FORWARDED_FOR),
    x_forwarded_proto = ifelse(is.null(request$HTTP_X_FORWARDED_PROTO), NA_real_, request$HTTP_X_FORWARDED_PROTO)
  )
  cli::cli_inform("http_headers dataframe created:")

  # Assuming postgres$table_append() is correct, you would insert the tibble
  http_headers <- dplyr::as_tibble(http_headers)
  postgres$table_append(http_headers)

  cli::cli_inform("Preparing user data...")
  userdata <- list(
    email = getOption("user.email", default = "default_email@example.com"),
    username = getOption("user.username", default = "default_username")
  )
  cli::cli_inform("User data prepared:")

  if (http_headers$host == "") {
    cli::cli_inform("Host is empty, setting to default site...")
    http_headers$host <- getOption("ndexr_site", "ndexr.io")
  }
  cli::cli_inform(paste("Final host set to:", http_headers$host))

  cli::cli_inform("Returning http_headers and userdata...")
  return(list(http_headers = http_headers, userdata = userdata))
}
