#' @export
get_info_user <- function(token, cognito_config) {
  box::use(httr)



  if (!is.list(cognito_config) || is.null(cognito_config$base_cognito_url)) {
    return(FALSE)
  }

  tryCatch(
    {
      url <- paste0(cognito_config$base_cognito_url, "/oauth2/userInfo")

      headers <- httr$add_headers(Authorization = paste("Bearer", token))

      request <- httr$GET(
        url = url,
        headers
      )

      userinfo <- httr$content(request)

      if (!is.null(userinfo$error)) {
        stop(userinfo$error)
      }

      return(c(userinfo, list("access_token" = token)))
    },
    error = function(e) {
      return(FALSE)
    }
  )
}
