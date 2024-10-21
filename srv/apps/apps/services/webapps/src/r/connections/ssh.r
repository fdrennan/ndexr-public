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
ssh_upload_file <- function(ec2data, from, to, username = NULL) {
  {
    box::use(fs)
    box::use(ssh)
    box::use(glue)
    box::use(ssh_utils = . / ssh)
    box::use(.. / aws / secrets / secrets)
  }

  if (is.null(username)) username <- ec2data$username
  ns_common_store_user <- ec2data$ns_common_store_user
  #
  if (unique(ec2data$instance$KeyName) == "ndexr") KeyName <- "KeyMaterial" else KeyName <- unique(ec2data$instance$KeyName)

  keyfile <- secrets$secret_get(ns_common_store_user(KeyName))
  PublicIpAddress <- unique(ec2data$instance$PublicIpAddress)

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
ssh_execute <- function(ec2data, command = "ls /", username = NULL) {
  {
    box::use(ssh)
    box::use(glue)
    box::use(fs)
    box::use(ssh_utils = . / ssh)
    box::use(.. / aws / secrets / secrets)
    box::use(shiny = shiny[tags, HTML])
    box::use(readr)
  }

  if (is.null(username)) username <- ec2data$username
  PublicIpAddress <- unique(ec2data$instance$PublicIpAddress)

  if (unique(ec2data$instance$KeyName) == "ndexr") KeyName <- "KeyMaterial" else KeyName <- unique(ec2data$instance$KeyName)
  keyfile <- secrets$secret_get(ec2data$ns_common_store_user(KeyName))
  tmp <- tempfile()
  readr$write_file(keyfile, tmp)
  # fs$file_chmod(tmp, 400)
  con <- ssh$ssh_connect(
    host = glue$glue("{username}@{PublicIpAddress}"),
    keyfile = tmp
  )
  # fs::file_delete(tmp)
  on.exit(ssh$ssh_disconnect(con))
  out <- ssh$ssh_exec_internal(session = con, command = command)
  ssh_utils$ssh_response_parse(out)
}

# Run User
#' @export
ssh_execute_user <- function(ec2data, users, command) {
  {
    box::use(. / ssh)
    box::use(glue)
    box::use(purrr)
  }
  purrr$map(
    users,
    function(user) {
      out <- ssh$ssh_execute(ec2data, glue$glue("sudo runuser -l {user} -c '{command}'"))
      out
    }
  )
}

#' @export
ssh_upload_text_to_file <- function(ec2data, text = "ls /", filepath = "", user = "ubuntu") {
  box::use(ssh)
  box::use(glue)
  box::use(readr)
  #

  con <- ssh$ssh_connect(
    host = glue$glue("{user}@{ec2data$instance$PublicDnsName}"),
    keyfile = keyfile
  )

  on.exit(ssh$ssh_disconnect(con))
  tmp <- tempfile()
  dir.create(fs::path_dir(tmp))
  readr$write_file(text, tmp)
  #

  homepath <- paste0("./shared", fs::path_dir(filepath))
  userpath <- paste0("./shared", filepath)

  ssh::ssh_exec_internal(con, command = paste0("mkdir -p ", homepath))

  out <- ssh::scp_upload(
    session = con, files = tmp, to = userpath
  )

  ssh::ssh_exec_internal(con, command = paste("sudo cp -r ", userpath, " ", filepath))
}


# scp -r user@ssh.example.com:/path/to/remote/source /path/to/local/destination
