#' @export
ui_head <- function(..., stylesheet = "./css/ndexrio.css") {
  # Load required libraries
  box::use(shiny = shiny[tags])
  box::use(shinyjs)
  box::use(htmltools)

  # Set resource paths
  shiny$addResourcePath(prefix = "javascript", directoryPath = "./javascript")
  shiny$addResourcePath(prefix = "css", directoryPath = "./css")
  shiny$addResourcePath(prefix = "images", directoryPath = "./images")

  tags$head(
    tags$meta(charset = "utf-8"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$title("ndexr"),
    tags$meta(name = "author", content = "Freddy Drennan"),
    tags$meta(name = "description", content = "r apps on aws"),

    # JavaScript and CSS includes
    shinyjs$useShinyjs(),
    tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.2/font/bootstrap-icons.css"),
    shiny$includeCSS("../node_modules/@selectize/selectize/dist/css/selectize.bootstrap5.css", rel = "stylesheet"),
    shiny$includeCSS("../node_modules/bootstrap/dist/css/bootstrap.min.css", rel = "stylesheet"),

    # Favicon
    tags$link(rel = "icon", type = "image/png", href = "./images/beavericon.png"),

    # Additional meta tags for SEO
    tags$meta(name = "robots", content = "index, follow"),
    # tags$meta(name = "google-site-verification", content = "your_google_site_verification_code"),
    # tags$p(filename),
    # Structured Data: JSON-LD (example)
    htmltools::tags$script(
      type = "application/ld+json",
      shiny$HTML('{
      "@context": "http://schema.org",
      "@type": "Organization",
      "name": "ndexr",
      "url": "http://www.ndexr.io",
      "logo": "./images/beavericon.png"
    }')
    ),
    # Additional scripts
    # shiny$includeScript("../node_modules/font-awesome/css/font-awesome.min.css"),
    # shiny$includeScript("../node_modules/@popperjs/core/dist/umd/popper.min.js"),
    shiny$includeScript("../node_modules/bootstrap/dist/js/bootstrap.min.js"),
    # shiny$includeScript("../node_modules/@selectize/selectize/dist/js/selectize.min.js"),
    shiny$includeCSS(stylesheet, rel = "stylesheet"),
    ...
  )
}
