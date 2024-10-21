#' @export
ui_configurations <- function(id) {
  box::use(shiny = shiny[tags])
  ns <- shiny$NS(id)
  shiny$uiOutput(ns("project"))
}

#' @export
server_configurations <- function(id, data, files) {
  box::use(
    shiny = shiny[tags],
    dplyr, stats, purrr, readr, stringr, fs, glue,
    .. / inputs / inputs,
    .. / connections / ssh,
    . / configurations,
    .. / aws / ec2 / ec2_backend,
    .. / aws / ec2 / workflows / https
  )


  instance <- data$instance
  domains <- data$instance$domain
  domains <- unname(domains)

  shiny$moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns

      print("server_configurations")



      output$project <- shiny$renderUI({
        if (instance$state != "running") {
          inputs$pan(glue::glue("Server is state {instance$state}"))
          return()
        }

        #

        purrr::map(
          split(files, files$ndexr_type),
          function(ndexr_types) {
            purrr::map(
              split(ndexr_types, ndexr_types$project_name),
              function(project) {
                if (project$service_name[[1]] == "nginx") {
                  id <- uuid::UUIDgenerate()
                  domain <- purrr::map_chr(ec2_backend$route53_list_hosted_zones(data$ns_common_store_user)$HostedZones, function(x) x$Name)
                  domain <- sort(domain)
                  https$server_https(paste0(id, "https"), data, project$project_name[[1]])
                  https_html <- https$ui_https(ns(paste0(id, "https")), domain)
                } else {
                  https_html <- tags$div()
                }

                tags$div(
                  # tags$div(
                  #   class = "d-flex justify-content-start align-items-center",
                  #   tags$p(unique(project$project_name), class = "fw-bold text-decoration-underline")
                  # ),
                  https_html,
                  inputs$create_tabset_panel(
                    justify = "end",
                    purrr::map(
                      split(project, 1:nrow(project)),
                      function(file) {
                        id <- uuid::UUIDgenerate()
                        configurations$server_edit_file(id, data, file)
                        inputs$create_tab(
                          header_type = shiny::tags$div,
                          file$name_file,
                          configurations$ui_edit_file(ns(id))
                        )
                      }
                    )
                  )
                )
                # )
              }
            )
            # )
          }
        )
      })
    }
  )
}

#' @export
ui_edit_file <- function(id = "edit_file") {
  box::use(shiny = shiny[tags], .. / inputs / inputs)
  ns <- shiny$NS(id)
  # print("ui_edit_file")
  # print(file)
  tags$div(
    class = "p-1 mb-3",
    tags$div(
      class = "d-flex align-items-center justify-content-end", # Add a custom class for clickable styling
      tags$b("Pull File", class = "me-2"),
      inputs$actionButton(ns("reload"), icon = "cloud-download-alt", class = "btn btn-outline-secondary ms-2") # Add a cloud download icon
    ),
    shiny$uiOutput(ns("ui")),
    shiny$uiOutput(ns("fileOutput")),
    shiny$uiOutput(ns("logsUI"))
  )
}


#' @export
server_edit_file <- function(id = "edit_file", data, file) {
  box::use(
    shiny = shiny[tags],
    . / configurations,
    .. / aws / ec2 / workflows / https,
    .. / inputs / inputs,
    .. / connections / ssh,
    .. / connections / state,
    .. / connections / postgres,
    .. / aws / ec2 / ec2_backend,
    dplyr, purrr, readr, stringr, fs, glue, shinyAce
  )

  shiny$moduleServer(id, function(input, output, session) {
    ns <- session$ns


    file_content <- shiny$eventReactive(input$reload, {
      command <- paste("cat", file$files)

      # content <- ssh$ssh_execute(data, glue::glue("cat {file$files}"))[[2]]
      file$content <- ssh$ssh_execute(data, command)[[2]]

      file$has_certbot <- stringr::str_detect(file$content, "certbot")
      file$key <- data$ns_common_store_user(file$files)

      file <- as.list(file)

      append(
        file,
        list(
          # header_html = header_html,
          command_build = glue::glue("cd manager && make build down up proj={file$project_name} > ~/{file$project_name}.txt 2>&1 &"),
          command_down = glue::glue("cd manager && make down proj={file$project_name} > ~/{file$project_name}.txt 2>&1 &"),
          command_logs = glue::glue("cat ~/{file$project_name}.txt")
        )
      )
    })




    shiny$observeEvent(input$build, {
      shiny$req(file_content())
      file <- file_content()

      inputs$pan("Starting Rebuild")
      ssh$ssh_execute(data, file$command_build)
      inputs$pan("Rebuild Running")
    })


    shiny$observeEvent(input$logs, {
      shiny$req(file_content())
      file <- file_content()

      out <- tryCatch(
        {
          inputs$pan("Fetching Log")
          ssh$ssh_execute(data, file$command_logs)[[2]]
        },
        error = function(err) {
          as.character(err)
        }
      )
      shiny$showModal(
        shiny$modalDialog(
          tags$pre(tags$code(out))
        )
      )
    })

    shiny$observeEvent(input$down, {
      shiny$req(file_content())
      file <- file_content()

      out <- tryCatch(
        {
          inputs$pan("Shutting Down")
          ssh$ssh_execute(data, file$command_down)[[2]]
        },
        error = function(err) {
          as.character(err)
        }
      )
      shiny$showModal(shiny$modalDialog(easyClose = TRUE, tags$code(out)))
    })


    output$fileOutput <- shiny$renderUI({
      shiny$req(file_content())
      file <- file_content()

      if (!state$key_exists(file$key)) {
        state$store_state(file$key, file$content)
      }

      tags$div(
        class = "row",
        tags$div(
          class = "col-12 d-flex flex-wrap justify-content-between align-items-center mb-2 toolbar",
          tags$div(
            class = "btn-toolbar w-100",
            tags$div(
              class = "btn-group me-2", role = "group",
              tags$button(
                id = ns("build"),
                class = "btn btn-warning action-button",
                tags$i(class = "fas fa-hammer"),
                tags$span(class = "d-none d-md-inline ms-2", "Build")
              ),
              tags$button(
                id = ns("down"),
                class = "btn btn-warning action-button",
                tags$i(class = "fas fa-arrow-down"),
                tags$span(class = "d-none d-md-inline ms-2", "Down")
              ),
              tags$button(
                id = ns("logs"),
                class = "btn btn-info action-button",
                tags$i(class = "fas fa-file-alt"),
                tags$span(class = "d-none d-md-inline ms-2", "Logs")
              )
            ),
            tags$div(
              class = "btn-group me-2", role = "group",
              tags$button(
                id = ns("backup"),
                class = "btn btn-secondary action-button",
                tags$i(class = "fas fa-cloud-upload-alt"),
                tags$span(class = "d-none d-md-inline ms-2", "Backup")
              ),
              tags$button(
                id = ns("restore"),
                class = "btn btn-secondary action-button",
                tags$i(class = "fas fa-sync-alt"),
                tags$span(class = "d-none d-md-inline ms-2", "Restore")
              ),
              tags$button(
                id = ns("update"),
                class = "btn btn-primary action-button",
                tags$i(class = "fas fa-upload"),
                tags$span(class = "d-none d-md-inline ms-2", "Update")
              )
            )
          )
        ),

        # Editor below toolbar
        tags$div(
          class = "col-12",
          shiny$uiOutput(ns("aceeditor"))
        )
      )
    })

    shiny$observeEvent(input$backup, {
      shiny$req(file_content())
      file <- file_content()
      state$store_state(file$key, input$results_code)
    })

    shiny$observeEvent(
      input$restore,
      {
        shiny$req(file_content())
        file <- file_content()

        output$aceeditor <- shiny$renderUI({
          content <- state$get_state(file$key)
          tags$div(
            shinyAce::aceEditor(
              outputId = ns("results_code"),
              value = state$get_state(file$key),
              minLines = stringr::str_count(content, "\n") + 1,
              fontSize = 12,
              vimKeyBinding = FALSE,
              autoComplete = "live",
              theme = "textmate"
            )
          )
        })
      }
    )

    output$aceeditor <- shiny$renderUI({
      shiny$req(file_content())
      file <- file_content()

      shinyAce$aceEditor(
        outputId = ns("results_code"),
        value = file$content,
        minLines = stringr::str_count(file$content, "\n") + 1,
        fontSize = 12,
        vimKeyBinding = FALSE,
        autoComplete = "live",
        theme = "textmate"
      )
    })

    shiny$observeEvent(input$update, {
      shiny$req(file_content())
      file <- file_content()

      tmpdir <- tempdir()
      file_path <- file.path(tmpdir, fs::path_file(file$files))
      readr$write_file(input$results_code, file_path)
      ssh$ssh_upload_file(data, file_path, fs::path_dir(file$files))
      inputs$pan("File updated successfully")
    })
  })
}
