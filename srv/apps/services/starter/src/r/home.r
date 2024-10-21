#' @export
ui_home <- function(id, request) {
  box::use(
    shiny = shiny[tags],
    . / head / head
  )
  
  ns <- shiny$NS(id)
  
  tags$html(
    head$ui_head(
      title = "ndexr - Streamlined Infrastructure for Applications",
      description = "ndexr provides a platform for managing the lifecycle of applications on AWS.",
      icon = "images/upsidedown.png",
      author = "Freddy Drennan",
      image = "https://ndexr.io/images/ndexrlogo.png",
      stylesheet = "./css/home.css",
      url = "https://console.ndexr.io",
      name = "ndexr Console",
      content = "ndexr is a versatile platform that automates the deployment and management of applications on AWS."
    ),
    tags$body(
      class = "d-flex flex-column min-vh-100",
      tags$header(
        tags$nav(
          class = "navbar navbar-expand-lg shadow-sm py-3",
          tags$div(
            class = "container-fluid",
            # Brand
            tags$a(class = "navbar-brand fw-bold text-uppercase", href = "#", "ndexr"),
            
            # Toggler button for small screens
            tags$button(
              class = "navbar-toggler border-0",
              type = "button",
              `data-bs-toggle` = "collapse",
              `data-bs-target` = paste0("#", ns("navigation")),
              `aria-controls` = ns("navigation"),
              `aria-expanded` = "false",
              `aria-label` = "Toggle navigation",
              tags$span(class = "navbar-toggler-icon")
            ),
            
            # Collapse menu
            tags$div(
              class = "collapse navbar-collapse justify-content-end", id = ns("navigation"),
              tags$ul(
                class = "navbar-nav mb-2 mb-lg-0 gap-3",
                tags$li(class = "nav-item", tags$a(class = "nav-link action-button", href = "#", id = ns("home_link"), "Home"))
              ),
              # Theme toggle button placed next to navigation items
              tags$button(
                type = "button", 
                class = "btn",
                id = ns("theme_toggle_btn"),
                tags$i(class = "fa fa-adjust")
              )
            )
          )
        )
      ),
      
      # Main layout: Content area dynamically updated
      tags$div(
        class = "d-flex flex-grow-1",
        tags$section(
          class = "flex-grow-1 ms-md-auto px-md-4 d-flex flex-column",
          shiny$uiOutput(ns("dynamic_content"))  # Dynamic content based on selected link
        )
      ),
      
      # Footer
      tags$footer(
        class = "footer mt-auto py-3",
        tags$div(
          class = "container-fluid d-flex flex-column flex-sm-row justify-content-between align-items-center",
          tags$span("© 2024 ndexr - Streamlined Infrastructure for Applications")
        )
      ),
      
      # Theme toggling script
      tags$script(shiny$HTML(paste0("
        document.addEventListener('DOMContentLoaded', function() {
          var toggleButton = document.getElementById('", ns("theme_toggle_btn"), "');
          toggleButton.addEventListener('click', function() {
            document.body.classList.toggle('dark-theme');
          });
        });")))
    )
  )
}


#' @export
server_home <- function(id, session_home) {
  box::use(shiny=shiny[tags], ./inputs/inputs)
  
  

  request <- as.list.environment(session_home$request)
  request <- request[grepl('HTTP', names(request))]
  
  
  shiny$moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    output$dynamic_content <- shiny$renderUI({
      tags$div(
        tags$h5("Headers"),
        purrr::imap(
          request, function(value, name) {
            tags$div(
              tags$div(tags$b(name), value),
              tags$div(tags$b(name), value),
              tags$div(tags$b(name), value)
            )
          }
        )
      )
    })
 

  })
}
