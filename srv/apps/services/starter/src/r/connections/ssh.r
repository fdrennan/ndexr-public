#' @export
ssh_response_parse <- function(x) {
  box::use(purrr)
  purrr$map_chr(
    x, function(x) {
      if (is.raw(x)) x <- rawToChar(x)
      as.character(x)
    }
  )
}


#' @export
ssh_upload_file <- function(data, from, to, username = NULL) {
  box::use(
    fs,
    ssh,
    glue,
    ssh_utils = . / ssh,
    .. / aws / secrets / secrets
  )

  if (is.null(username)) username <- data$username
  ns_common_store_user <- data$ns_common_store_user



  if (unique(data$instance$KeyName) == "ndexr") KeyName <- "KeyMaterial" else KeyName <- unique(data$instance$KeyName)

  keyfile <- secrets$secret_get(ns_common_store_user(KeyName))
  PublicIpAddress <- unique(data$instance$PublicIpAddress)

  tmp <- tempfile()
  readr::write_file(keyfile, tmp)
  fs::file_chmod(tmp, 400)
  on.exit(file.remove(tmp))
  con <- ssh$ssh_connect(
    host = glue$glue("{username}@{PublicIpAddress}"),
    keyfile = tmp
  )

  on.exit(ssh$ssh_disconnect(con))
  destdir <- paste0("tmp", to)
  ssh$ssh_exec_wait(con, glue$glue("mkdir -p {destdir}"))
  ssh$scp_upload(con, from, destdir)
  ssh$ssh_exec_wait(con, glue$glue("sudo cp -r {destdir}/* {to}"))
  ssh$ssh_exec_wait(con, glue$glue("rm -rf {destdir}"))
}



#' @export
ssh_execute <- function(data, command = "ls /") {
  box::use(
    ssh,
    glue,
    ssh_utils = . / ssh,
    .. / aws / secrets / secrets,
    readr
  )


  PublicIpAddress <- unique(data$instance$PublicIpAddress)


  keyfile <- secrets$secret_get(data$ns_common_store_user(data$instance$KeyName))
  tmp <- tempfile()
  readr$write_file(keyfile, tmp)

  con <- ssh$ssh_connect(
    host = glue$glue("{ data$username}@{PublicIpAddress}"),
    keyfile = tmp
  )

  on.exit(ssh$ssh_disconnect(con))
  out <- ssh$ssh_exec_internal(session = con, command = command)
  ssh_utils$ssh_response_parse(out)
}

# Run User
#' @export
ssh_execute_user <- function(data, users, command) {
  box::use(
    . / ssh,
    glue,
    purrr
  )

  purrr$map(
    users,
    function(user) {
      out <- ssh$ssh_execute(data, glue$glue("sudo runuser -l {user} -c '{command}'"))
      out
    }
  )
}

#' @export
ssh_upload_text_to_file <- function(data, text = "ls /", filepath = "", user = "ubuntu") {
  box::use(
    ssh,
    glue,
    readr
  )


  con <- ssh$ssh_connect(
    host = glue$glue("{user}@{data$instance$PublicDnsName}"),
    keyfile = keyfile
  )

  on.exit(ssh$ssh_disconnect(con))
  tmp <- tempfile()
  dir.create(fs::path_dir(tmp))
  readr$write_file(text, tmp)


  homepath <- paste0("./shared", fs::path_dir(filepath))
  userpath <- paste0("./shared", filepath)

  ssh::ssh_exec_internal(con, command = paste0("mkdir -p ", homepath))

  out <- ssh::scp_upload(
    session = con, files = tmp, to = userpath
  )

  ssh::ssh_exec_internal(con, command = paste("sudo cp -r ", userpath, " ", filepath))
}
