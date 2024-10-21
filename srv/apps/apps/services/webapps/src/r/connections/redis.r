#' @export
setDefault <- function(value, default) {
  if (length(value) > 1) {
    return(value)
  }
  ifelse(is.null(value) | !length(nchar(value)), default, value)
}




#' @export
store_state <- function(id, data, use_redis = FALSE) {
  box::use(. / redis)
  box::use(shiny)
  box::use(storr)
  box::use(. / postgres)
  if (!length(data)) {
    return()
  }
  if (use_redis) {
    con <- postgres$connection_postgres()
    con <- storr$storr_dbi("tblData", "tblKeys", con)
    con$set(id, data)
  } else {
    con <- storr$storr_rds("cache")
    con$set(id, data)
  }
  data
}



#' @export
get_state <- function(id, use_redis = FALSE) {
  box::use(. / redis)
  box::use(shiny)
  box::use(storr)
  box::use(. / postgres)

  if (use_redis) {
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
  } else {
    con <- storr$storr_rds("cache")

    if (con$exists(id)) {
      out <- tryCatch(con$get(id), error = function(err) list())
    } else {
      out <- list()
    }
  }

  if (typeof(out) == "raw") {
    out <- redux$bin_to_object(out)
  }
  out
}


if (FALSE) {
  box::use(. / redis)
  box::use(purrr)
  con <- redis$connection_redis()
}
