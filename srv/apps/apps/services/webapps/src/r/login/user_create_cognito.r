#' @export
ui_user_create <- function(id = "user_create") {
  box::use(shiny = shiny[tags, HTML])

  if (isFALSE(getOption("require_login"))) {
    return(tags$div("Development mode"))
  }


  box::use(shinyjs)
  ns <- shiny$NS(id)
  jscode <- "Shiny.addCustomMessageHandler('redirect', function(url) { window.location = url;});"
  shiny$addResourcePath("css", "css")
  tags$div(
    class = "row",
    shinyjs$useShinyjs(),
    shiny$HTML('<div id="cognitor_loader"></div>'),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/cognitor/loader.css"),
    tags$head(tags$script(jscode))
    # cookie_ui(ns("cookiemod"))
  )
}

#' @export
server_user_create <- function(id = "user_create", with_cookie = FALSE, cookiename = "cognitor", cookie_expire = 7) {
  {
    box::use(utils)
    box::use(shinyjs)
    box::use(shiny)
    box::use(. / cognito / cognito_config)
    box::use(. / cognito / get_url_logout_redirect)
    box::use(. / cognito / get_url_auth_redirect)
    box::use(. / cognito / get_token_access)
    box::use(. / cognito / get_info_user)
    box::use(shiny)
  }

  if (isFALSE(getOption("require_login"))) {
    return()
  }


  shiny$moduleServer(
    id,
    function(input, output, session) {
      if (isFALSE(getOption("user_login"))) {
        return()
      }

      cognito_config <- cognito_config$get_config()
      if (!is.list(cognito_config)) {
        stop("Your configuration for Cognito Service is not correct.")
      }

      return <- shiny$reactiveValues(
        isLogged = FALSE,
        userdata = FALSE,
        logout = function() {
          session$sendCustomMessage("redirect", get_url_logout_redirect$get_url_logout_redirect(cognito_config))
        }
      )

      shiny$observeEvent(return$isLogged, {
        if (return$isLogged == TRUE) {
          shinyjs$runjs("document.getElementById('cognitor_loader').style.display = 'none';")
        }
      })

      shiny$observe(
        {
          # con
          if (!return$isLogged) {
            # We have support for "authorization code grant" (via code) and "Implicit grant" (via token).
            if (cognito_config$oauth_flow == "code") {
              query <- shiny$parseQueryString(session$clientData$url_search)
            }
            if (cognito_config$oauth_flow == "token") {
              query <- shiny$parseQueryString(session$clientData$url_hash)
            }

            if (!is.null(query$code) || !is.null(query$`#access_token`)) {
              # Recovery params url from Cognito redirection and remove token/code params.
              if (!is.null(query$state) && query$state != "") {
                query_params <- utils$URLdecode(query$state)
              } else {
                query_params <- "?"
              }
              if (!is.null(session$clientData$url_hash)) {
                # Keep the url_hash
                query_params <- paste0(query_params, session$clientData$url_hash)
              }

              session$updateQueryString(query_params, "push")

              token <- query$`#access_token`
              if (!is.null(query$code)) {
                # Get token with code.
                tokens <- get_token_access$get_token_access(query$code, cognito_config)
                token <- if (is.list(tokens)) tokens$access_token else NULL
              }

              if (!is.null(token)) {
                # Get userdata from Amazon and save in cookie.
                userdata <- get_info_user$get_info_user(token, cognito_config)
                return$isLogged <- TRUE
                return$userdata <- userdata
              } else {
                # User without access, something is happen with token.
                aws_auth_redirect <- get_url_auth_redirect$get_url_auth_redirect(cognito_config)
                session$sendCustomMessage("redirect", aws_auth_redirect)
              }
            } else {
              # con
              aws_auth_redirect <- get_url_auth_redirect$get_url_auth_redirect(cognito_config)
              session$sendCustomMessage("redirect", aws_auth_redirect)
            }
          }
        },
        priority = 100000
      )

      return
    }
  )
}
