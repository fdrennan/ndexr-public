#' @export
modal_transition <- function(message = "Please wait", loaders = "./images/spinners/coolload.gif", easyClose = TRUE) {
  box::use(shiny = shiny[tags])
  box::use(shinyjs)
  box::use(. / inputs)
  box::use(purrr)
  box::use(fs)

  inputs$pan(message)

  svgs <- purrr$map(
    fs$dir_ls("./images/spinners
#' #' @export/", regexp = "svg$"),
    function(img) {
      tags$img(
        src = img,
        class = "img-fluid",
        style = "max-width: 100%; height: auto; display: block; margin: 0 auto;" # Center and limit width to prevent scroll
      )
    }
  )

  loader <- svgs[[sample(1:length(svgs), 1)]]

  if (is.character(message)) message <- tags$p(message, class = "text-center")
  shiny$removeModal()
  shiny$showModal(
    shiny$modalDialog(
      easyClose = easyClose, footer = NULL,
      tags$div(
        class = "container",
        tags$div(
          class = "row justify-content-center align-items-center",
          tags$div(
            class = "col-12",
            tags$p(
              class = "text-secondary",
              tags$div(message, class = "lead")
            ),
            loader
          )
        )
      ),
      size = "l" # Ensures modal is large enough to fit content
    )
  )
}



#' @export
pan <- function(message) {
  cli::cli_inform(message)
  shiny::showNotification(message)
}



#' @export
create_dynamic_card <- function(ns, titles, values, buttons = list()) {
  box::use(shiny = shiny[tags], . / inputs)
  server_info <- purrr::map2(titles, values, ~ tags$p(tags$strong(.x), .y, class = "me-3 mb-0"))

  # Create buttons layout if provided
  buttons_layout <- purrr::map(buttons, function(btn) {
    inputs$actionButton(ns(btn$id), btn$label, class = paste("btn", btn$class, "btn-sm me-2"))
  })

  tags$div(
    class = "card mb-2",
    style = "max-width: 100%;",
    tags$div(
      class = "card-body p-2",
      tags$div(
        class = "row",

        # Server Info
        tags$div(
          class = "col-12 col-md-8 d-flex flex-wrap align-items-center",
          server_info # Dynamically generated server information
        ),

        # Buttons (if any)
        tags$div(
          class = "col-12 col-md-4 d-flex align-items-center justify-content-md-end mt-3 mt-md-0",
          buttons_layout # Dynamically generated buttons
        )
      )
    )
  )
}


#' @export
actionButton <- function(id, label = NULL, icon = NULL, class = "btn-primary", value = 0, size = "sm", disabled = FALSE, ...) {
  box::use(shiny = shiny[tags])

  args <- list(...) # Capture the arguments as a list

  valid_sizes <- c("sm", "md", "lg")
  if (!size %in% valid_sizes) {
    stop("Invalid button size. Use 'sm', 'md', or 'lg'.")
  }

  # Add the button size class if size is specified
  size_class <- ifelse(size == "md", "", paste0("btn-", size))

  # If disabled, add the disabled attribute
  disabled_attr <- if (disabled) "disabled" else NULL

  # Create the button with Bootstrap styling and an optional icon
  tags$button(
    id = id,
    type = "button",
    class = paste("btn", class, size_class, "action-button"), # Combine button classes dynamically
    `data-val` = value, # Data attribute to track button clicks
    disabled = disabled_attr, # Add disabled attribute if TRUE
    tags$span(
      if (!is.null(icon)) shiny::icon(icon), # If an icon is provided, add it
      if (!is.null(label)) label # Button label text, only if provided
    ),
    !!!args
  )
}


#' @export
passwordInput <- function(id, label = NULL, placeholder = NULL, value = "", size = "md", disabled = FALSE, ...) {
  box::use(shiny = shiny[tags])

  args <- list(...) # Capture the arguments as a list

  valid_sizes <- c("sm", "md", "lg")
  if (!size %in% valid_sizes) {
    stop("Invalid input size. Use 'sm', 'md', or 'lg'.")
  }

  # Add the input size class if size is specified
  size_class <- ifelse(size == "md", "", paste0("form-control-", size))

  # If disabled, add the disabled attribute
  disabled_attr <- if (disabled) "disabled" else NULL

  # Create the password input field with Bootstrap styling
  tags$div(
    class = "form-group",
    if (!is.null(label)) tags$label(`for` = id, label), # Add label if provided
    tags$input(
      id = id,
      type = "password",
      class = paste("form-control", size_class), # Combine input classes dynamically
      placeholder = placeholder, # Placeholder text if provided
      value = value, # Initial value
      disabled = disabled_attr, # Add disabled attribute if TRUE
      !!!args # Include any additional passed attributes
    )
  )
}



#' @export
create_tabset_panel <- function(..., sidebar = FALSE, reload_button = NULL, title = NULL, justify = c("start", "center", "end", "between", "fill", "justified")) {
  box::use(shiny = shiny[tags])

  justify <- match.arg(justify)

  tabs <- list(...)

  if (!is.null(tabs[[1]][[1]]$nav_item)) {
    tabs <- tabs[[1]]
  }

  uuid <- uuid::UUIDgenerate()

  # Check if there is an active tab; if not, activate the first tab by default
  has_active <- any(sapply(tabs, function(tab) {
    grepl("active", tab$nav_item$children[[1]]$attribs$class)
  }))

  if (!has_active && length(tabs) > 0) {
    tabs[[1]]$nav_item$children[[1]]$attribs$class <- "nav-link active"
    tabs[[1]]$content$attribs$class <- "tab-pane fade show active"
  }

  # Determine justification class
  justify_class <- switch(justify,
    start = "justify-content-start",
    center = "justify-content-center",
    end = "justify-content-end",
    fill = "nav-fill",
    between = "justify-content-between",
    justified = "nav-justified",
    "justify-content-start"
  )

  if (sidebar) {
    tags$div(
      class = "d-flex flex-column",
      tags$div(
        class = "row flex-grow-1",
        tags$nav(
          class = "col-auto d-none d-md-block",
          tags$div(
            class = "d-flex flex-column align-items-center align-items-md-start",
            # Add title if provided
            if (!is.null(title)) {
              tags$h4(class = "mt-3", title)
            },
            tags$ul(
              class = paste("nav nav-pills flex-column mb-sm-auto mb-0 align-items-center align-items-md-start", justify_class),
              id = uuid,
              role = "tablist",
              lapply(tabs, function(tab) {
                tab$nav_item
              })
            )
          )
        ),
        tags$nav(
          class = "d-md-none p-1",
          tags$div(
            class = "d-flex flex-column align-items-center align-items-md-start",
            if (!is.null(title)) {
              tags$h4(class = "mt-3", title)
            },
            tags$ul(
              class = paste("nav nav-pills mb-sm-auto mb-0 align-items-center align-items-md-start", justify_class),
              id = uuid,
              role = "tablist",
              lapply(tabs, function(tab) {
                tab$nav_item
              })
            )
          )
        ),
        # Main content area
        tags$div(
          class = "col d-flex flex-column",
          tags$div(
            class = "container mt-3 h-100",
            tags$div(
              class = "tab-content h-100",
              lapply(tabs, `[[`, "content")
            )
          )
        )
      )
    )
  } else {
    # Horizontal tabset panel (default behavior)
    tags$div(
      class = "d-flex flex-column",
      # Add title if provided
      if (!is.null(title)) {
        tags$h4(class = "mt-3", title)
      },
      tags$div(
        class = "d-flex justify-content-between align-items-center",
        tags$ul(
          class = paste("nav nav-tabs flex-grow-1", justify_class),
          id = uuid,
          role = "tablist",
          style = "margin: 0; padding: 0;",
          lapply(tabs, function(tab) tab$nav_item)
        ),
        if (!is.null(reload_button)) {
          tags$div(
            class = "ms-2",
            reload_button
          )
        }
      ),
      tags$div(
        class = "tab-content",
        lapply(tabs, `[[`, "content")
      )
    )
  }
}

#' @export
create_tab <- function(tab_title, tab_content, icon = NULL, popup_message = NULL, active_title = FALSE, header_type = shiny::tags$h3) {
  box::use(shiny = shiny[tags])
  tab_id <- uuid::UUIDgenerate()

  # If icon is provided, include it in the tab title
  title_with_icon <- if (!is.null(icon)) {
    shiny$tags$span(
      shiny$tags$i(class = icon),
      # Text is displayed only on medium screens and up
      shiny$tags$span(class = "d-none d-md-inline ms-2", tab_title)
    )
  } else {
    tab_title
  }

  # Add tooltip attributes
  if (!is.null(popup_message)) {
    # Use Bootstrap tooltip with popup_message
    tooltip_attributes <- list(
      `data-bs-toggle` = "tooltip",
      `data-bs-placement` = "top",
      title = popup_message
    )
  } else {
    # Use default title attribute with tab_title
    tooltip_attributes <- list(
      title = tab_title
    )
  }

  list(
    nav_item = tags$li(
      class = "nav-item",
      role = "presentation",
      tags$a(
        class = ifelse(active_title, "nav-link active", "nav-link"),
        id = paste0(tab_id, "-tab"),
        href = paste0("#", tab_id),
        `data-bs-toggle` = "tab",
        role = "tab",
        `aria-controls` = tab_id,
        `aria-selected` = ifelse(active_title, "true", "false"),
        !!!tooltip_attributes,
        title_with_icon
      )
    ),
    content = tags$div(
      class = ifelse(active_title, "tab-pane fade show active h-100", "tab-pane fade"),
      id = tab_id,
      role = "tabpanel",
      `aria-labelledby` = paste0(tab_id, "-tab"),
      tab_content
    )
  )
}


#' @export
filler_paragraphs <- function(n = 5) {
  paste(lorem::ipsum(paragraphs = n), collapse = "\n\n")
}
