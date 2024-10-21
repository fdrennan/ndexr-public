#' @export
ui_carneproperties <- function(id = "carneproperties", request) {
  box::use(
    shiny = shiny[tags],
    . / carneproperties
  )
  ns <- shiny::NS(id)

  shiny::addResourcePath(prefix = "images", directoryPath = "./images")

  tags$html(
    lang = "en",
    ui_head_carneproperties(),
    tags$body(
      class = "carneproperties",
      carneproperties$navbar_carneproperties(),
      tags$div(
        class = "container my-2",
        carneproperties$carousel_carneproperties(),
        carneproperties$contact_form_carneproperties(ns)
      ),
      carneproperties$footer_carneproperties(ns)
    )
  )
}

#' @export
navbar_carneproperties <- function() {
  box::use(shiny = shiny[tags])
  tags$nav(
    class = "navbar navbar-expand-lg navbar-light ",
    tags$div(
      tags$a(
        class = "navbar-brand",
        href = "#",
        "Carne Properties"
      ),
      tags$button(
        class = "navbar-toggler",
        type = "button",
        `data-bs-toggle` = "collapse",
        `data-bs-target` = "#navbarNav",
        `aria-controls` = "navbarNav",
        `aria-expanded` = "false",
        `aria-label` = "Toggle navigation",
        tags$span(class = "navbar-toggler-icon")
      ),
      tags$div(
        class = "collapse navbar-collapse",
        id = "navbarNav",
        tags$ul(
          class = "navbar-nav ms-auto mb-2 mb-lg-0",
          tags$li(
            class = "nav-item",
            tags$a(
              class = "nav-link active",
              `aria-current` = "page",
              href = "#",
              "Home"
            )
          ),
          tags$li(
            class = "nav-item",
            tags$a(class = "nav-link", href = "#services", "Services")
          ),
          tags$li(
            class = "nav-item",
            tags$a(class = "nav-link", href = "#about", "About")
          ),
          tags$li(
            class = "nav-item",
            tags$a(class = "nav-link", href = "#contact", "Contact")
          )
        ),
        tags$a(
          class = "btn btn-primary my-2",
          href = "https://carneproperties.co.uk",
          "Enquire Today"
        )
      )
    )
  )
}



#' @export
ui_head_carneproperties <- function() {
  box::use(shiny = shiny[tags], . / head / head)
  head$ui_head(
    title = "Carne Properties: Property Management",
    description = "Carne Properties specializes in professional property management services.",
    icon = "https://assets.squarespace.com/universal/default-favicon.ico",
    author = "Carne Properties",
    stylesheet = "./css/carneproperties.css",
    url = "https://www.carneproperties.co.uk"
  )
}

#' @export
carousel_carneproperties <- function() {
  box::use(shiny = shiny[tags])
  tags$div(
    class = "row",
    tags$div(
      class = "col-12",
      tags$div(
        id = "propertyCarousel",
        class = "carousel slide",
        `data-bs-ride` = "carousel",
        tags$div(
          class = "carousel-inner",
          tags$div(
            class = "carousel-item active",
            tags$img(
              src = "./images/carneproperties/millbeach3.jpg",
              class = "d-block w-100",
              alt = "Property 1"
            )
          ),
          tags$div(
            class = "carousel-item",
            tags$img(
              src = "./images/carneproperties/creekreflections4.jpg",
              class = "d-block w-100",
              alt = "Property 2"
            )
          ),
          tags$div(
            class = "carousel-item",
            tags$img(
              src = "images/carneproperties/doublebed3.jpg",
              class = "d-block w-100",
              alt = "Property 3"
            )
          )
        ),
        tags$a(
          class = "carousel-control-prev",
          href = "#propertyCarousel",
          role = "button",
          `data-bs-slide` = "prev",
          tags$span(
            class = "carousel-control-prev-icon",
            `aria-hidden` = "true"
          ),
          tags$span(class = "sr-only", "Previous")
        ),
        tags$a(
          class = "carousel-control-next",
          href = "#propertyCarousel",
          role = "button",
          `data-bs-slide` = "next",
          tags$span(
            class = "carousel-control-next-icon",
            `aria-hidden` = "true"
          ),
          tags$span(class = "sr-only", "Next")
        )
      )
    )
  )
}

#' @export
contact_form_carneproperties <- function(ns) {
  box::use(shiny = shiny[tags])
  tags$div(
    class = "my-2",
    tags$h2("Contact Us"),
    tags$form(
      tags$div(
        class = "mb-2",
        tags$input(
          type = "text",
          class = "form-control",
          id = ns("name"),
          placeholder = "Your Name"
        )
      ),
      tags$div(
        class = "mb-2",
        tags$input(
          type = "email",
          class = "form-control",
          id = ns("email"),
          placeholder = "Your Email"
        )
      ),
      tags$div(
        class = "mb-2",
        tags$input(
          type = "tel",
          class = "form-control",
          id = ns("phone"),
          placeholder = "Your Phone Number"
        )
      ),
      tags$div(
        class = "mb-2",
        tags$textarea(
          class = "form-control",
          id = ns("message"),
          rows = "4",
          placeholder = "Your Message"
        )
      ),
      tags$button(
        type = "button",
        id = ns("submit"),
        class = "btn btn-primary action-button",
        "Submit"
      )
    )
  )
}

#' @export
footer_carneproperties <- function(ns) {
  box::use(shiny = shiny[tags], . / footer / footer)

  tags$footer(
    class = "  py-4",
    tags$div(
      tags$div(
        class = "row",
        tags$div(
          class = "col-md-6",
          tags$h4(class = "text-uppercase mb-2", "Contact Information"),
          tags$p(class = "mb-2", tags$strong("Carne Properties: Property Management")),
          tags$p(class = "mb-2", "Porthleven, Cornwall"),
          tags$p(class = "mb-2", tags$a(href = "tel:+447881022393", "07881022393")),
          tags$p(class = "mb-2", tags$a(href = "mailto:carneproperties@gmail.com", "carneproperties@gmail.com"))
        ),
        tags$div(
          class = "col-md-6 text-center",
          tags$h4(class = "text-uppercase mb-2", "Photo Credits"),
          tags$p(class = "mb-2", "Photos provided by various sources, mostly by the business owner."),
          tags$div(
            class = "d-flex justify-content-center mt-3",
            tags$a(
              href = "http://www.instagram.com/carneproperties",
              class = " ",
              tags$i(class = "fab fa-instagram fa-2x")
            ),
            tags$a(
              href = "http://www.facebook.com/carneproperties",
              class = " ",
              tags$i(class = "fab fa-facebook fa-2x")
            )
          )
        )
      )
    ),
    tags$div(
      class = "text-center mt-4",
      tags$small("© 2024 Carne Properties. All rights reserved.")
    )
  )
}
#' @export
server_carneproperties <- function(id = "carneproperties") {
  box::use(.. / r / aws / sns / sns, shiny = shiny[tags])
  shiny$moduleServer(
    id,
    function(input, output, session) {
      shiny$observeEvent(input$submit, {
        sns$sns_send(
          ns_common_store_user = shiny::NS("fdrennan"),
          PhoneNumber = "2549318313",
          countryCode = "1",
          Message = paste0(c(input$name, input$email, input$phone, input$message), collapse = "\n")
        )
        inputs$pan("Message sent!")
      })
    }
  )
}
