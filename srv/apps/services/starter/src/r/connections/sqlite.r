#' @export connection_sqlite
connection_sqlite <- function(dbname) {
  box::use(RSQLite, DBI)
  DBI$dbConnect(RSQLite$SQLite(), dbname)
}
