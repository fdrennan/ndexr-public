#' @export
setDefault <- function(value, default) {
  if (length(value) > 1) {
    return(value)
  }
  ifelse(is.null(value) | !length(nchar(value)), default, value)
}

#' @export
store_state <- function(id, data) {
  box::use(
    shiny = shiny[tags],
    storr,
    . / postgres,
    .. / inputs / inputs
  )

  if (!length(data)) {
    return()
  }


  con <- postgres$connection_postgres()
  con <- storr$storr_dbi("tblData", "tblKeys", con)
  con$set(id, data)
  inputs$pan(tags$sm(paste("Stored:", id)))
  data
}

#' @export
key_exists <- function(id) {
  box::use(
    shiny,
    storr,
    . / postgres
  )


  con <- postgres$connection_postgres()
  con <- storr$storr_dbi("tblData", "tblKeys", con)


  con$exists(id)
}


#' @export
get_state <- function(id) {
  box::use(
    shiny = shiny[tags],
    storr,
    . / postgres,
    .. / inputs / inputs
  )


  inputs$pan("Connecting to postgres")
  con <- postgres$connection_postgres()
  con <- storr$storr_dbi("tblData", "tblKeys", con)

  out <- tryCatch(
    {
      con$get(id)
    },
    error = function(err) {
      NULL
    }
  )

  if (is.null(out)) {
    return(list())
  }
  inputs$pan(tags$sm(paste("Got:", id)))
  out
}
