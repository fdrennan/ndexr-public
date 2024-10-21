#' @export
connection_postgres <- function(host = Sys.getenv("POSTGRES_HOST"),
                                port = Sys.getenv("POSTGRES_PORT"),
                                user = Sys.getenv("POSTGRES_USER"),
                                password = Sys.getenv("POSTGRES_PASSWORD"),
                                dbname = Sys.getenv("POSTGRES_DB"),
                                cache_dir = "../cache/") {
  box::use(glue, DBI = DBI[dbConnect], RPostgres[Postgres])

  con_default <- dbConnect(Postgres(), host = host, port = port, user = user, password = password, dbname = "postgres")
  on.exit(DBI$dbDisconnect(con_default))


  db_exists <- DBI$dbGetQuery(con_default, sprintf("SELECT 1 FROM pg_database WHERE datname = '%s'", dbname))
  if (nrow(db_exists) == 0) {
    DBI$dbExecute(con_default, glue$glue("CREATE DATABASE {dbname}"))
  }


  dbConnect(Postgres(), host = host, port = port, user = user, password = password, dbname = dbname)
}


#' @export
table_exists <- function(dataname, ...) {
  box::use(DBI)
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  DBI$dbExistsTable(con, dataname)
}


#' @export
table_drop <- function(dataname, ...) {
  box::use(DBI)
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  DBI$dbRemoveTable(con, dataname)
}

#' @export
tables_list <- function(...) {
  box::use(DBI)
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  DBI$dbListTables(con)
}

#' @export
tables_row_retrieve <- function(where_cols, id, table, showNotification = FALSE, ...) {
  box::use(DBI)
  box::use(glue)
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  cmd <- glue$glue("SELECT * FROM {table} WHERE {where_cols} = '{id}'")
  out <- DBI$dbGetQuery(con, cmd)
  if (showNotification) {
    box::use(shiny)
  }
  out
}

#' @export
tables_row_remove <- function(where_cols, id, table, showNotification = FALSE, ...) {
  box::use(DBI)
  box::use(glue)
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  cmd <- glue$glue("DELETE FROM {table} WHERE {where_cols} LIKE '{id}'")
  DBI$dbExecute(con, cmd)
  if (showNotification) {
    box::use(shiny)
  }
}

#' @export
table_create_or_upsert <- function(data, where_cols = NULL, ...) {
  box::use(
    DBI,
    dbx,
    glue[glue],
    . / postgres[connection_postgres]
  )


  con <- connection_postgres(...)
  on.exit(
    {
      if (DBI::dbIsValid(con)) DBI::dbDisconnect(con)
    },
    add = TRUE
  )

  dataname <- deparse1(substitute(data))


  if (!is.data.frame(data)) stop("The 'data' argument must be a data frame.")
  if (!is.null(where_cols) && !all(where_cols %in% names(data))) {
    stop("All 'where_cols' must exist as column names in the provided 'data'.")
  }


  table_exists <- DBI::dbExistsTable(con, dataname)

  if (!table_exists) {
    DBI::dbCreateTable(con, dataname, data)


    if (!is.null(where_cols)) {
      constraint_name <- paste0("uq_", dataname, "_", paste(where_cols, collapse = "_"))


      sql <- glue(
        "ALTER TABLE {DBI::dbQuoteIdentifier(con, dataname)}
         ADD CONSTRAINT {DBI::dbQuoteIdentifier(con, constraint_name)}
         UNIQUE ({paste(DBI::dbQuoteIdentifier(con, where_cols), collapse = ', ')});"
      )


      DBI::dbExecute(con, sql)
    }
  }


  dbx::dbxUpsert(con, dataname, data, where_cols = where_cols)

  invisible(TRUE)
}


if (FALSE) {
  box::use(. / postgres)
  box::reload(postgres)
}


#' @export
table_append <- function(data, ...) {
  box::use(DBI, dbx)
  box::use(glue[glue])
  box::use(. / postgres[connection_postgres])

  con <- connection_postgres(...)

  on.exit(DBI$dbDisconnect(con))
  dataname <- deparse1(substitute(data))

  if (isFALSE(DBI$dbExistsTable(con, dataname))) {
    DBI$dbCreateTable(con, dataname, data)
  }
  DBI$dbAppendTable(con, dataname, data)
}


#' @export
table_get <- function(dataname, ...) {
  box::use(DBI)
  box::use(dplyr)
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  dplyr$tbl(con, dataname) |>
    dplyr$collect()
}

#' @export
instance_state <- function(ImageId = NA_character_,
                           InstanceType = NA_character_,
                           InstanceStorage = NA_integer_,
                           user_data = NA_character_,
                           GroupId = NA_character_,
                           KeyName = NA_character_,
                           InstanceId = NA_character_,
                           status = "undefined", ...) {
  box::use(DBI)
  box::use(. / postgres)


  instance_state <- data.frame(
    ImageId = ImageId,
    InstanceType = InstanceType,
    InstanceStorage = InstanceStorage,
    user_data = user_data,
    GroupId = GroupId,
    KeyName = KeyName,
    InstanceId = InstanceId,
    status = status,
    time = Sys.time()
  )
  con <- postgres$connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  postgres$table_append(instance_state)
  instance_state
}


#' @export
refresh_materialized_view <- function() {
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres()
  DBI::dbExecute(con, "refresh materialized view mv_user_activity_dashboard;")
  DBI::dbDisconnect(con)
}


if (FALSE) {
  box::use(. / postgres)
}
