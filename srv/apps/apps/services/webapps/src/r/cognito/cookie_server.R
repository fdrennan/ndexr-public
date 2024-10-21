#' @export
cookie_server <- function(input, output, session, cookie_name = "user", cookie_expire = 7) {
  # Return a reactive element (getCookie) and methods to remove/set cookie ####
  box::use(shiny = shiny[tags])
  box::use(shinyjs)
  functions <- list(
    # IF cookie exist return the cookie data as list.
    # If cookie dont exist, else return FALSE
    # IF input$cookie was not set yet (initial state), return NULL.
    getCookie = shiny$reactive({
      shinyjs$js$getCookie(cookie_name)
      cookiedata <- input$cookie
      if (!is.null(cookiedata) && cookiedata != "") {
        # Decode cookie
        cookiedata <- cookiedata %>%
          base64enc::base64decode() %>%
          rawToChar() %>%
          jsonlite::fromJSON(cookiedata, TRUE)
      } else {
        if (is.null(cookiedata)) {
          # Input is not set to init.
          cookiedata <- NULL
        } else {
          cookiedata <- FALSE
        }
      }
      cookiedata
    }),
    # Allow remove the cookie.
    rmCookie = function() {
      shinyjs$js$rmCookie(cookie_name)
    },
    # Allow to save data in cookie.
    setCookie = function(data) {
      if (is.list(data) && length(data) > 0) {
        # Encode data for cookie (as is done by plumbeR package)
        encodecookie <- data %>%
          jsonlite::toJSON() %>%
          charToRaw() %>%
          base64enc::base64encode()
        shinyjs$js$setCookie(cookie_name, encodecookie, cookie_expire)
        return(TRUE)
      }
      return(FALSE)
    }
  )
  functions
}
