#' @export
get_token_access <- function(code, cognito_config) {
  box::use(httr)

  if (!is.list(cognito_config) ||
    is.null(cognito_config$group_name) ||
    is.null(cognito_config$base_cognito_url) ||
    is.null(cognito_config$app_client_id) ||
    is.null(cognito_config$app_client_secret) ||
    is.null(cognito_config$redirect_uri)) {
    return(FALSE)
  }

  app_oauth <- httr$oauth_app(
    appname = cognito_config$group_name,
    key = cognito_config$app_client_id,
    secret = cognito_config$app_client_secret,
    redirect_uri = cognito_config$redirect_uri
  )

  endpoint_oauth <- httr$oauth_endpoint(
    authorize = "authorize",
    access = "token",
    base_url = paste0(cognito_config$base_cognito_url, "/oauth2")
  )

  # Get All tokens
  failed_token <- FALSE
  tryCatch(
    {
      tokens <- httr$oauth2.0_access_token(
        endpoint = endpoint_oauth,
        app = app_oauth,
        code = code,
        user_params = list(
          client_id = cognito_config$app_client_id,
          grant_type = "authorization_code"
        ),
        use_basic_auth = TRUE
      )
    },
    error = function(e) {
      failed_token <<- TRUE
    }
  )

  # check result status, make sure token is valid and that the process did not fail
  if (failed_token) {
    return(FALSE)
  }

  tokens
}
