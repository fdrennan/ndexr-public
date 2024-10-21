#' @export
ui_cognito <- function(id, img_src = "./images/spinners/fire.svg") {
  box::use(. / cognito)
  box::use(shiny = shiny[tags])
  ns <- shiny$NS(id)
  tags$div(
    class = "row",
    shiny$uiOutput(ns("who"), inline = TRUE),
    class = "user-logged",
    cognito$cognito_ui(ns("cognito"), img_src = img_src),
    cognito$logout_ui(ns("logout"))
  )
}

#' @export
server_cognito <- function(id, path = "config.yml") {
  box::use(shiny)
  box::use(. / cognito)

  shiny$moduleServer(
    id,
    function(input, output, session) {
      cognitomod <- shiny$callModule(cognito$cognito_server, "cognito", path = path)

      logoutmod <- shiny$callModule(
        cognito$logout_server,
        "logout",
        shiny$reactive(cognitomod$isLogged)
      )

      shiny$observeEvent(logoutmod(), {
        cognitomod$logout()
      })

      shiny$observeEvent(cognitomod$isLogged, {
        if (cognitomod$isLogged) {
          userdata <- cognitomod$userdata
        }
      })

      cognitomod
    }
  )
}

#' @export
logout_server <- function(input, output, session, isLogged = shiny::reactive(FALSE),
                          textlogged = "You are logged in") {
  box::use(shiny = shiny[tags])
  box::use(shinyjs)
  shiny$observeEvent(isLogged(), {
    if (isLogged()) {
      shinyjs$show("logout")
    } else {
      shinyjs$hide("logout")
    }
  })
  output$who <- shiny$renderUI({
    if (isLogged()) {
      textlogged
    }
  })
  shiny$reactive(input$logout)
}


#' @export
cognito_server <- function(input, output, session, with_cookie = FALSE, cookiename = "cognitor", cookie_expire = 7, path = "config.yml") {
  box::use(
    shiny = shiny[tags],
    . / cognito,
    .. / inputs / inputs,
    .. / login / cognito / cognito_config,
    .. / login / cognito / get_url_logout_redirect,
    .. / login / cognito / get_url_auth_redirect,
    .. / login / cognito / get_token_access,
    .. / login / cognito / get_info_user
  )


  cognito_config <- cognito_config$get_config(path = path)
  box::use(.. / cognito / cookie_server)
  if (!is.list(cognito_config)) {
    stop("Your configuration for Cognito Service is not correct.")
  }

  # Reactive values that return this module. ####
  return <- shiny::reactiveValues(
    isLogged = FALSE,
    userdata = FALSE,
    logout = function() {
      session$sendCustomMessage("redirect", get_url_logout_redirect$get_url_logout_redirect(cognito_config))
    }
  )

  shiny::observeEvent(return$isLogged, {
    if (return$isLogged == TRUE) {
      shinyjs::runjs("document.getElementById('cognitor_loader').style.display = 'none';")
    }
  })

  shiny::observe(
    {
      if (!return$isLogged) {
        shiny$showNotification(duration = 1, "User not logged")
        if (cognito_config$oauth_flow == "code") {
          query <- shiny::parseQueryString(session$clientData$url_search)
        }


        if (cognito_config$oauth_flow == "token") {
          shiny$showNotification(duration = 1, "Using token flow")
          query <- shiny::parseQueryString(session$clientData$url_hash)
        }

        if (!is.null(query$code) || !is.null(query$`#access_token`)) {
          if (!is.null(query$state) && query$state != "") {
            shiny$showNotification(duration = 1, "Decoding query")
            query_params <- utils::URLdecode(query$state)
          } else {
            query_params <- "?"
          }
          if (!is.null(session$clientData$url_hash)) {
            shiny$showNotification(duration = 1, "Query Params")
            query_params <- paste0(query_params, session$clientData$url_hash)
          }
          session$updateQueryString(query_params, "push")
          token <- query$`#access_token`
          if (!is.null(query$code)) {
            tokens <- get_token_access$get_token_access(query$code, cognito_config)
            token <- if (is.list(tokens)) tokens$access_token else NULL
          }

          if (!is.null(token)) {
            shiny$showNotification(duration = 1, "Getting user info")
            userdata <- get_info_user$get_info_user(token, cognito_config)
            return$isLogged <- TRUE
            return$userdata <- userdata
          } else {
            shiny$showNotification(duration = 1, "Redirect to aws")
            aws_auth_redirect <- get_url_auth_redirect$get_url_auth_redirect(cognito_config)
            session$sendCustomMessage("redirect", aws_auth_redirect)
          }
        } else {
          shiny$showNotification(duration = 1, "Redirect to aws")
          aws_auth_redirect <- get_url_auth_redirect$get_url_auth_redirect(cognito_config)
          session$sendCustomMessage("redirect", aws_auth_redirect)
        }
      }
    },
    priority = 100000
  )

  return
}

#' @export
logout_ui <- function(id) {
  box::use(shiny = shiny[tags])
  ns <- shiny$NS(id)
  tags$div(
    class = "row",
    tags$div(
      class = "col-12",
      shinyjs::hidden(
        shiny$actionButton(ns("logout"), shiny$icon("sign-out"), class = "btn-danger")
      )
    ),
    class = "user-logged"
  )
}


#' @export
cognito_ui <- function(id, img_src = "./images/spinners/fire.svg") {
  #
  box::use(shiny = shiny[tags])
  box::use(. / cognito)
  box::use(.. / inputs / inputs)
  box::use(purrr, fs)
  # shiny$showNotification(duration=1, )
  ns <- shiny$NS(id)
  jscode <- "Shiny.addCustomMessageHandler('redirect', function(url) { window.location = url;});"



  tags$div(
    tags$div(
      id = "cognitor_loader",
      class = "text-primary text-end",
      # tags$div(message, class = "lead"),
      tags$img(
        src = img_src,
        # class='img img-fluid',
        width = "64px",
        height = "64px"
      )
    ),
    tags$div(tags$script(jscode)), cognito$cookie_ui(ns("cookiemod"))
  )
}

#' @export
cookie_ui <- function(id) {
  box::use(shiny = shiny[tags])
  box::use(shinyjs)
  ns <- shiny::NS(id)
  # addResourcePath("cognitoR", system.file("", package = "cognitoR"))
  jsCode <- paste0(
    "shinyjs.getCookie = function(params) {\n\n                        cookiename = \"user\";\n                        if(typeof params[0] === \"string\"){\n                          cookiename = params[0];\n                        }\n\n                        var my_cookie = Cookies.get(cookiename);\n                        if(my_cookie == undefined) {\n                          my_cookie = \"\";\n                        }\n                        Shiny.onInputChange(\"",
    ns("cookie"), "\", my_cookie);\n                      }\n                      shinyjs.setCookie = function(params) {\n                        cookiename = \"user\";\n                        if(typeof params[0] === \"string\"){\n                          cookiename = params[0];\n                        }\n                        cookiecontent = \"\";\n                        if(typeof params[1] === \"string\"){\n                          cookiecontent = params[1];\n                        }\n                        cookietime = 0.5;\n                        if(typeof params[2] === \"number\"){\n                          cookietime = params[2];\n                        }\n                        Cookies.set(cookiename, cookiecontent, {expires: cookietime});\n                        Shiny.onInputChange(\"",
    ns("cookie"), "\", params[1]);\n                      }\n                      shinyjs.rmCookie = function(params) {\n                        cookiename = \"user\";\n                        if(typeof params[0] === \"string\"){\n                          cookiename = params[0];\n                        }\n                        Cookies.remove(cookiename);\n                        Shiny.onInputChange(\"",
    ns("cookie"), "\", \"\");\n                      }"
  )
  tags$div(
    shinyjs$useShinyjs(), tags$head(tags$script(src = "cognito/js/jscookie/js.cookie.js")),
    shinyjs$extendShinyjs(text = jsCode, functions = c(
      "getCookie",
      "setCookie", "rmCookie"
    ))
  )
}
