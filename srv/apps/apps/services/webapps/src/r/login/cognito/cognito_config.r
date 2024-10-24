#' @export
get_config <- function(path = "config.yml") {
  box::use(config)

  tryCatch(
    {
      result <- config$get(file = path)$cognito
      config_names <- names(unlist(result))
      required_names <- c(
        "group_name",
        "group_id",
        "oauth_flow",
        "base_cognito_url",
        "app_client_id",
        "redirect_uri",
        "redirect_uri_logout",
        "app_client_secret"
      )

      missing_args <- setdiff(required_names, config_names)

      if (length(missing_args) > 0 || isFALSE(result$oauth_flow %in% c("code", "token"))) {
        stop("Missing params in config")
      }
      result
    },
    error = function(e) {
      return(FALSE)
    }
  )
}
