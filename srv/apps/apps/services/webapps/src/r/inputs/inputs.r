#' @export
textAreaInput <- function(inputId, label, value = "", width = NULL, height = NULL,
                          cols = NULL, rows = NULL, placeholder = NULL, resize = NULL) {
  box::use(shiny)
  out <- shiny$textAreaInput(
    inputId, label, value, width, height,
    cols, rows, placeholder, resize
  )

  out$attribs$class <- "  rounded"
  out
}

#' @export
actionButton <- function(id, content, class) {
  box::use(shiny[tags])
  class <- paste0(c("btn action-button me-2 ", class))
  tags$button(
    id = id,
    type = "button",
    class = class,
    content
  )
}

#' @export
numericInput <- function(inputId, label, value, min = NA, max = NA, step = NA,
                         width = NULL) {
  box::use(shiny = shiny[tags])
  out <- shiny$numericInput(
    inputId, label, value, min, max, step,
    width = width
  )
  out$attribs$class <- "  rounded"
  out
}

#' @export
sliderInput <- function(inputId, label, min, max, value, step = NULL, round = FALSE,
                        ticks = TRUE, animate = FALSE, width = NULL, sep = ",", pre = NULL,
                        post = NULL, timeFormat = NULL, timezone = NULL, dragRange = TRUE) {
  box::use(shiny = shiny[tags])

  out <- shiny$sliderInput(
    inputId, label, min, max, value, step, round,
    ticks, animate, width, sep, pre,
    post, timeFormat, timezone, dragRange
  )
  out$attribs$class <- "  rounded"
  out
}

#' @export
card_collapse <- function(ns,
                          title = "",
                          footer = NULL,
                          body = NULL,
                          sidebar = NULL,
                          status = NULL,
                          collapsible = TRUE,
                          collapsed = TRUE,
                          closable = FALSE,
                          maximizable = TRUE,
                          refresh = FALSE,
                          scrollvert = FALSE) {
  box::use(shiny = shiny[tags, HTML])

  uuid <- uuid::UUIDgenerate()

  if (scrollvert) {
    class <- "scrollvert"
  } else {
    class <- ""
  }
  tags$div(
    id = ns(uuid),
    tags$h5(title, class = "display-5 border-bottom  "),
    tags$div(
      class = class,
      body
    )
  )
}




#' @export
bs4_card <-
  function(..., title = NULL,
           footer = NULL,
           status = "secondary",
           solidHeader = FALSE,
           background = NULL,
           height = NULL,
           collapsible = TRUE,
           collapsed = FALSE,
           closable = FALSE,
           maximizable = FALSE,
           icon = NULL,
           gradient = FALSE,
           boxToolSize = "sm",
           elevation = 2,
           headerBorder = TRUE,
           label = NULL,
           dropdownMenu = NULL,
           sidebar = NULL,
           id = NULL) {
    if (is.null(status)) {
      solidHeader <- TRUE
    }
    box::use(. / inputs)
    box::use(shiny = shiny[tags])

    nullsData <- list(
      # title = title,
      status = status,
      solidHeader = solidHeader,
      background = background,
      # width = width,
      height = height,
      collapsible = collapsible,
      closable = closable,
      maximizable = maximizable,
      gradient = gradient
    )

    props <- bs4Dash:::dropNulls(nullsData)
    cardCl <- inputs$setBoxClass(
      status, solidHeader, collapsible, collapsed,
      elevation, gradient, background, sidebar
    )
    #
    style <- ""
    cardToolTag <- NULL
    cardToolTag <- shiny::tags$div()
    cardToolTag <- shiny::tagAppendChildren(
      cardToolTag, label,
      inputs$createBoxTools(
        collapsible,
        collapsed, closable,
        maximizable,
        sidebar,
        dropdownMenu,
        boxToolSize,
        status,
        background,
        solidHeader
      )
    )
    # cardToolTag
    cardToolTag <- shiny::tagAppendAttributes(cardToolTag, class = "d-flex justify-content-end")
    headerTag <- shiny::tags$div(title, class = "lead")

    headerTag <- tags$div(
      class = "row  ",
      tags$div(
        class = "col-8",
        headerTag
      ),
      tags$div(
        class = "col-4",
        cardToolTag
      )
    )
    bodyTag <- shiny::tags$div(class = "card-body", style = style, ...)
    footerTag <- if (!is.null(footer)) {
      shiny::tags$div(class = "card-footer", footer)
    }
    cardTag <- shiny::tags$div(class = cardCl, id = id)
    cardTag <- shiny::tagAppendChildren(
      cardTag, tags$div(
        headerTag
      ), bodyTag,
      footerTag
    )
    shiny::tags$div(
      cardTag,
      shiny::tags$script(
        type = "application/json",
        `data-for` = id,
        jsonlite::toJSON(
          x = props,
          auto_unbox = TRUE,
          json_verbatim = TRUE
        )
      )
    )
  }

#' #' @export
#' selectizeInput <- function(inputId, label, choices, selected = "Choose...", multiple = FALSE, ..., options = NULL, width = NULL) {
#'   box::use(shiny = shiny[tags])
#'   box::use(. / inputs)
#'   # box::use(glue)
#'   print(label)
#'   # out <- shiny$selectizeInput(
#'   #   inputId=inputId, label=label, choices = choices, ...,
#'   #   options = options, width = width
#'   # )
#'   # out$attribs$class <- NULL
#'   # out$children[[2]]$children[[1]]$attribs$class <- "form-control "
#'   # out
#'   #
#'
#'   #
#'   if (is.list(choices)) {
#'     choices <- unlist(choices)
#'     names(choices) <- choices
#'   } else if (is.null(names(choices))) {
#'     names(choices) <- choices
#'   }
#'   # choices <- unlist(choices)
#'   #
#'   tags$div(
#'     class = "  rounded",
#'     tags$label(
#'       `for` = inputId,
#'       class = "form-label",
#'       label
#'     ),
#'     tags$select(
#'       # multiple = "",
#'       class = "form-select",
#'       id = inputId,
#'       tags$option(
#'         selected = "", "Choose..."
#'       ), #     }
#'       purrr::imap(
#'         choices, function(x, y) {
#'           box::use(shiny = shiny[tags])
#'           tags$option(value = x, y)
#'         }
#'       )
#'     )
#'   )
#' }

#' @export
textInput <- function(inputId, label, value = "", width = NULL, placeholder = NULL) {
  box::use(shiny)
  out <- shiny$textInput(inputId, label, value, width, placeholder)
  out$attribs$class <- "  rounded"
  out
}

#' @export
passwordInput <- function(inputId, label, value = "", width = NULL, placeholder = NULL) {
  box::use(shiny)
  out <- shiny$passwordInput(inputId, label, value, width, placeholder)
  out$attribs$class <- "  rounded"
  out
}


#' @export
modalDialog <- function(..., easyClose = TRUE, size = "xl") {
  box::use(shiny = shiny[tags])

  shiny$modalDialog(
    ...,
    fade = FALSE, easyClose = easyClose, size = size
  )
}


#' @export
createBoxTools <- function(collapsible, collapsed, closable, maximizable, sidebar,
                           dropdownMenu, boxToolSize, status, background, solidHeader) {
  validStatuses <- c("primary", "secondary", "info", "success", "warning", "danger")
  box::use(glue)
  status <- if (is.null(status)) status <- "primary"
  btnClass <- glue$glue("btn btn-{status} ms-3")

  collapseTag <- NULL
  if (collapsible) {
    collapseTag <- shiny::tags$button(
      class = btnClass, type = "button",
      `data-card-widget` = "collapse",
      shiny::icon("bars")
    )
  }
  closableTag <- NULL
  if (closable) {
    closableTag <- shiny::tags$button(
      class = btnClass, `data-card-widget` = "remove",
      type = "button", shiny::icon("xmark")
    )
  }
  maximizableTag <- NULL
  if (maximizable) {
    maximizableTag <- shiny::tags$button(
      type = "button",
      class = btnClass, `data-card-widget` = "maximize",
      shiny::icon("up-right-and-down-left-from-center")
    )
  }
  sidebarToolTag <- NULL
  if (!is.null(sidebar)) {
    sidebar[[1]]$attribs$class <- btnClass
    sidebarToolTag <- sidebar[[1]]
  }
  dropdownMenuToolTag <- NULL
  if (!is.null(dropdownMenu)) {
    dropdownMenu$children[[1]]$attribs$class <- paste0(
      btnClass,
      " dropdown-toggle"
    )
    dropdownMenuToolTag <- dropdownMenu
  }
  bs4Dash:::dropNulls(list(
    dropdownMenuToolTag, closableTag,
    maximizableTag, sidebarToolTag, collapseTag
  ))
}


#' @export
modal_transition <- function(message = "Please wait", loaders = "./images/spinners/coolload.gif", easyClose = TRUE) {
  box::use(shiny = shiny[tags])
  box::use(shinyjs)
  box::use(. / inputs)
  box::use(purrr)
  box::use(fs)
  loaders <- list(
    tags$div(
      class = "lds-hourglass",
      tags$div()
    ),
    tags$div(
      class = "lds-heart",
      tags$div()
    ),
    tags$div(
      class = "lds-ripple",
      tags$div()
    ),
    tags$div(
      class = "lds-circle text-center",
      tags$div()
    )
  )

  svgs <- purrr$map(
    fs$dir_ls("./images/spinners/", regexp = "svg$"),
    function(img) {
      tags$img(
        src = img,
        # class='img img-fluid',
        width = "64px",
        height = "64px"
      )
    }
  )

  loaders <- c(loaders, svgs)
  #
  loader <- loaders[[sample(1:length(loaders), 1)]]

  if (is.character(message)) message <- tags$p(message, class = "text-center")
  #
  # shinyjs$runjs("document.getElementById('shiny-modal').classList.add('fade');")
  # Sys.sleep(.1)
  shiny$removeModal()
  shiny$showModal(
    inputs$modalDialog(
      # style = "background-color: transparent;",
      easyClose = easyClose, footer = NULL,
      size = "m",
      tags$div(
        class = "row justify-content-center",
        tags$p(
          class = "text-secondary",
          tags$div(message, class = "lead"),
          loader
        )
        # tags$img(
        #   src = loaders,
        #   class = "rounded  m-2 img img-fluid"
        # )
      )
    )
  )
}


#' @export
a <- function(..., class = "link-dark") {
  box::use(shiny = shiny[tags])
  tags$a(
    target = "_blank",
    class = class,
    ...
  )
}


#' @export
toggle <- function(id, title, checked = FALSE, class = "me-2 ") {
  box::use(shiny = shiny[tags])
  if (checked) {
    input <- tags$input(
      class = "form-check-input",
      type = "checkbox",
      role = "switch",
      id = id,
      checked = checked
    )
  } else {
    input <- tags$input(
      class = "form-check-input",
      type = "checkbox",
      role = "switch",
      id = id
    )
  }
  tags$div(
    class = paste("form-check form-switch", class),
    input,
    tags$label(
      class = "form-check-label",
      `for` = id,
      title
    )
  )
}


#' @export
checkboxInput <- function(inputId, label, value = FALSE, width = NULL) {
  box::use(shiny = shiny[tags])
  value <- shiny$restoreInput(id = inputId, default = value)
  inputTag <- tags$input(id = inputId, type = "checkbox")
  if (!is.null(value) && value) {
    inputTag$attribs$checked <- "checked"
  }

  tags$div(class = "checkbox", tags$label(inputTag, tags$span(label)))
}
#' @export
tabsetPanel <- function(id, panels, header = shiny::tags$div(), container = "") {
  box::use(shiny = shiny[tags])
  ns <- shiny::NS(id)
  firstname <- names(panels)[[1]]
  tags$div(
    tags$nav(
      tags$div(
        class = "nav nav-tabs justify-content-center",
        id = ns("nav-tab"),
        role = "tablist",
        purrr::map(
          names(panels),
          function(x) {
            if (x == firstname) className <- "nav-link active m-1  rounded" else className <- "nav-link m-1  rounded"
            box::use(glue)
            box::use(shiny = shiny[tags])
            tags$button(
              class = className,
              id = ns(glue$glue("nav-{x}-tab")),
              `data-bs-toggle` = "tab",
              `data-bs-target` = paste0("#", ns(glue$glue("nav-{x}"))),
              type = "button",
              role = "tab",
              `aria-controls` = ns(glue$glue("nav-{x}")),
              `aria-selected` = "true",
              x
            )
          }
        )
      )
    ),
    header,
    tags$div(
      class = "tab-content",
      id = ns("nav-tabContent"),
      purrr::imap(
        panels,
        function(data, x) {
          box::use(glue)
          box::use(shiny = shiny[tags])
          if (x == firstname) className <- "tab-pane fade active show" else className <- "tab-pane fade"
          tags$div(
            class = className,
            id = ns(glue$glue("nav-{x}")),
            role = "tabpanel",
            `aria-labelledby` = ns(glue$glue("nav-{x}-tab")),
            tags$div(
              class = "",
              tags$div(
                class = container, data
              )
            )
          )
        }
      )
    )
  )
}


#' @export
card <- function() {
  box::use(shiny = shiny[tags])
  tags$div(
    class = "card ",
    tags$h3(
      class = "card-header",
      "Card header"
    ),
    tags$div(
      class = "card-body",
      tags$h5(
        class = "card-title",
        "Special title treatment"
      ),
      tags$h6(
        class = "card-subtitle text-muted",
        "Support card subtitle"
      )
    ),
    tags$svg(
      xmlns = "http://www.w3.org/2000/svg",
      class = "d-block user-select-none",
      width = "100%",
      height = "200",
      `aria-label` = "Placeholder: Image cap",
      focusable = "false",
      role = "img",
      preserveAspectRatio = "xMidYMid slice",
      viewBox = "0 0 318 180",
      style = "font-size:1.125rem;text-anchor:middle",
      tags$rect(
        width = "100%",
        height = "100%",
        fill = "#868e96"
      ),
      tags$text(
        x = "50%",
        y = "50%",
        fill = "#dee2e6",
        dy = ".3em",
        "Image cap"
      )
    ),
    tags$div(
      class = "card-body",
      tags$p(
        class = "card-text",
        "Some quick example text to build on the card title and make up the bulk of the card's content."
      )
    ),
    tags$ul(
      class = "list-group list-group-flush",
      tags$li(
        class = "list-group-item",
        "Cras justo odio"
      ),
      tags$li(
        class = "list-group-item",
        "Dapibus ac facilisis in"
      ),
      tags$li(
        class = "list-group-item",
        "Vestibulum at eros"
      )
    ),
    tags$div(
      class = "card-body",
      tags$a(
        href = "#",
        class = "card-link",
        "Card link"
      ),
      tags$a(
        href = "#",
        class = "card-link",
        "Another link"
      )
    ),
    tags$div(
      class = "card-footer text-muted",
      "2 days ago"
    )
  )
}


#' @export
selectizeInput <- function(inputId, label, choices, selected = "Choose...", multiple = FALSE, ..., options = list(create = TRUE), width = NULL) {
  box::use(shiny = shiny[tags])
  #
  choices <- unlist(choices)

  if (length(names(choices))) {
    choiceNames <- names(choices)
  } else {
    choiceNames <- choices
  }

  if (multiple) {
    selectTag <- tags$select(
      id = inputId,
      class = "demo-consoles ",
      multiple = "true",
      selected = selected
      # placeholder = choiceNames[[1]]
    )
  } else {
    selectTag <- tags$select(
      id = inputId,
      class = "demo-consoles ",
      selected = selected
      # placeholder = choiceNames[[1]]
    )
  }

  out <- tags$div(
    tags$div(
      tags$div(
        class = "control-group   rounded",
        tags$label(
          `for` = inputId,
          label
        ),
        selectTag
      )
    ),
    {
      valuesForSelectize <- data.frame(value = choices, name = choiceNames)
      valuesForSelectize <- jsonlite::toJSON(valuesForSelectize)
      selected <- sub('"', '\\\\"', selected)
      scriptToRun <- paste0(
        'var $select = $("#', inputId, '").selectize({
          options: ', valuesForSelectize, ',
          labelField: "name",
          searchField: ["name"],
          create: true
        });
        $select[0].selectize.setValue("', selected, '");
        ' # sortField: "name",
      )
      tags$script(scriptToRun)
    }
  )

  out
}


#' @export
setBoxClass <- function(status, solidHeader, collapsible, collapsed, elevation,
                        gradient, background, sidebar) {
  cardCl <- "card"
  if (!is.null(status)) {
    cardCl <- paste0(cardCl, " card-", status)
  }
  if (!solidHeader) {
    cardCl <- paste0(cardCl, " card-outline")
  }
  if (collapsible && collapsed) {
    cardCl <- paste0(cardCl, " collapsed-card")
  }
  if (!is.null(elevation)) {
    cardCl <- paste0(cardCl, " elevation-", elevation)
  }
  if (!is.null(background)) {
    cardCl <- paste0(cardCl, " bg-", if (gradient) {
      "gradient-"
    }, background)
  }

  cardCl
}
