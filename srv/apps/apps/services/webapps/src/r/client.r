#' @export
client <- function(service = NULL, ns_common_store_user = NULL, region = NULL) {
  {
    box::use(reticulate[import])
    box::use(. / aws / secrets / secrets)
    box::use(cli)
    box::use(jsonlite)
  }

  if (!is.null(ns_common_store_user)) {
    awscreds <- secrets$secret_get(ns_common_store_user("master"))
    awscreds <- jsonlite$fromJSON(awscreds)
    AWS_SECRET <- awscreds$AWS_SECRET
    AWS_ACCESS <- awscreds$AWS_ACCESS
    REGION <- ifelse(!is.null(region), region, awscreds$REGION)
    client <- import("boto3")$client(service,
      aws_access_key_id = AWS_ACCESS,
      aws_secret_access_key = AWS_SECRET,
      region_name = REGION
    )
  } else {
    client <- import("boto3")$client(service,
      aws_access_key_id = Sys.getenv("AWS_ACCESS"),
      aws_secret_access_key = Sys.getenv("AWS_SECRET"),
      region_name = Sys.getenv("AWS_REGION")
    )
    cli::cli_alert_warning("MASTER: Connected to {service}")
  }

  client
}


#' @export
resource <- function(service = NULL, ns_common_store_user = NULL) {
  box::use(reticulate[import])

  {
    box::use(reticulate[import])
    box::use(. / secrets / secrets)
    box::use(cli)
    box::use(jsonlite)
  }


  if (!is.null(ns_common_store_user)) {
    awscreds <- secrets$secret_get(ns_common_store_user("master"))
    awscreds <- jsonlite$fromJSON(awscreds)
    AWS_SECRET <- awscreds$AWS_SECRET
    AWS_ACCESS <- awscreds$AWS_ACCESS
    REGION <- awscreds$REGION
    resource <- import("boto3")$resource(service,
      aws_access_key_id = AWS_ACCESS,
      aws_secret_access_key = AWS_SECRET,
      region_name = REGION
    )
  } else {
    resource <- import("boto3")$resource(service)
    cli::cli_alert_warning("MASTER: Connected to {service}")
  }

  resource
  # resource <- resource(service)
}


if (FALSE) {
  box::use(. / client)
  box::reload(client)
}
