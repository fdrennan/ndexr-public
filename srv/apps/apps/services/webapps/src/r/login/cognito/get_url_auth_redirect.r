#' @export
get_url_auth_redirect <- function(cognito_config, session = shiny::getDefaultReactiveDomain()) {
  box::use(utils)

  if (!is.list(cognito_config) ||
    is.null(cognito_config$base_cognito_url) ||
    is.null(cognito_config$oauth_flow) ||
    is.null(cognito_config$app_client_id) ||
    is.null(cognito_config$redirect_uri)) {
    return(FALSE)
  }
  params <- ""


  if (!is.null(session) && session[["clientData"]]$url_search != "") {
    params <- paste0(params, utils$URLencode(session[["clientData"]]$url_search, TRUE))
  }
  if (!is.null(session) && session[["clientData"]]$url_hash != "") {
    params <- paste0(params, utils$URLencode(session[["clientData"]]$url_hash, TRUE))
  }

  aws_auth_redirect <- paste0(
    cognito_config$base_cognito_url,
    "/oauth2/authorize?",
    "response_type=", cognito_config$oauth_flow, "&",
    "client_id=", cognito_config$app_client_id, "&",
    "redirect_uri=", cognito_config$redirect_uri, "&",
    paste0("state=", params)
  )
}
