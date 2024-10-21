#' @export setDefault
setDefault <- function(value, default) {
  warning("setDefault in state module deprecated, use redis module")
  if (length(value) > 1) {
    return(value)
  }
  ifelse(is.null(value) | !length(nchar(value)), default, value)
}
