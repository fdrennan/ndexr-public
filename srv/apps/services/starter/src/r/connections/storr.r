#' @export
connection_storr <- function() {
  box::use(. / sqlite, storr)
  suppressWarnings(con <- sqlite$connection_sqlite(getOption("ndexr_sqlite_path")))
  st <- storr$storr_dbi("tblData", "tblKeys", con)
}
