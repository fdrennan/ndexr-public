#' @export
file_data <- function(data, files_list) {
  box::use(
    shiny = shiny[tags],
    dplyr, stats, purrr, readr, stringr, fs, glue,
    .. / inputs / inputs,
    .. / connections / ssh,
    . / configurations
  )


  files_df <- data.frame(
    files = files_list,
    name_file = fs$path_file(files_list),
    ndexr_type_name = dplyr::if_else(
      stringr::str_detect(files_list, "sites-enabled"),
      fs$path_file(files_list),
      fs$path_file(fs$path_dir(files_list))
    ),
    ndexr_type = dplyr::case_when(
      stringr::str_detect(files_list, "[.]yml") ~ "project",
      stringr::str_detect(files_list, "Dockerfile") ~ "service",
      TRUE ~ "site"
    ),
    stringsAsFactors = FALSE
  ) |>
    dplyr::filter(!stringr::str_detect(files, "Dockerfile")) |>
    dplyr::filter(!stringr::str_detect(files, "Dockerfile"))

  files_df <- files_df |>
    dplyr::mutate(
      title = dplyr::case_when(
        ndexr_type %in% c("project", "service") ~ ndexr_type_name,
        TRUE ~ name_file
      )
    )

  files_df$project_name <- purrr::map_chr(strsplit(files_df$files, "/"), function(x) {
    x[6]
  })
  files_df$service_name <- purrr::map_chr(strsplit(files_df$files, "/"), function(x) {
    x[8]
  })
  files_df$service_name <- ifelse(is.na(files_df$service_name), "none", files_df$service_name)

  # Reorder the data frame to have certain project_names at the top
  preferred_order <- c("router", "gateway", "apps")
  files_df <- files_df |>
    dplyr::arrange(factor(project_name, levels = preferred_order))

  return(files_df)
}
