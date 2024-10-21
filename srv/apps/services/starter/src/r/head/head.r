#' @export
ui_head <- function(
    title = "Koodle's Club House",
    description = "Koodle's Club House! A place for fun and learning.",
    icon = "images/koodleico.png",
    author = "Freddy Drennan",
    image = "https://ndexr.io/images/carneproperties/millbeach.jpg",
    stylesheet = "./css/classcadet.css?v=1.0", # Versioned for cache control
    url = "https://www.koodlesclubhouse.com",
    name = "Koodle's Club House",
    content = "default-src 'self';
               script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdnjs.cloudflare.com https://kit.fontawesome.com https://cdn.jsdelivr.net https://console.ndexr.io;
               style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://fonts.googleapis.com https://kit.fontawesome.com https://cdn.jsdelivr.net https://console.ndexr.io;
               img-src 'self' data: https://ndexr.io https://cdnjs.cloudflare.com https://console.ndexr.io https://a.basemaps.cartocdn.com https://b.basemaps.cartocdn.com https://c.basemaps.cartocdn.com https://d.basemaps.cartocdn.com;
               font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com https://cdn.jsdelivr.net https://console.ndexr.io;
               connect-src 'self' https://ndexr.io https://console.ndexr.io https://accounts.google.com;
               frame-src 'self' https://console.ndexr.io https://accounts.google.com;") {
  box::use(shiny = shiny[tags])
  box::use(shinyjs)

  shiny$addResourcePath(prefix = "css", directoryPath = "./css")
  shiny$addResourcePath(prefix = "images", directoryPath = "./images")

  tags$head(
    tags$meta(charset = "utf-8"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$title(title),
    tags$link(rel = "icon", type = "image/x-icon", href = icon),
    tags$link(rel = "canonical", href = url),
    tags$meta(name = "author", content = author),
    tags$meta(name = "description", content = description),
    tags$meta(name = "keywords", content = "Koodle's Club House, fun, learning, kids, activities, education"),
    tags$meta(`http-equiv` = "Content-Security-Policy", content = content),
    tags$meta(property = "og:site_name", content = name),
    tags$meta(property = "og:title", content = title),
    tags$meta(property = "og:description", content = description),
    tags$meta(property = "og:url", content = url),
    tags$meta(property = "og:type", content = "website"),
    tags$meta(property = "og:image", content = image),
    tags$meta(property = "og:image:width", content = "1200"),
    tags$meta(property = "og:image:height", content = "630"),
    tags$meta(name = "twitter:card", content = "summary_large_image"),
    tags$meta(name = "twitter:title", content = title),
    tags$meta(name = "twitter:description", content = description),
    tags$meta(name = "twitter:url", content = url),
    tags$meta(name = "twitter:image", content = image),
    tags$script(
      type = "application/ld+json",
      shiny$HTML(paste0('{
        "@context": "http://schema.org",
        "@type": "Organization",
        "name": "', name, '",
        "url": "', url, '",
        "logo": "', icon, '",
        "description": "', description, '",
        "sameAs": [
          "https://www.linkedin.com/in/freddydrennan",
          "https://github.com/freddydrennan"
        ]
      }'))
    ),
    shiny$includeCSS(stylesheet),
    tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.2/font/bootstrap-icons.min.css"),
    htmltools::htmlDependency(
      name = "font-awesome",
      version = fontawesome::fa_metadata()$version,
      src = "fontawesome",
      package = "fontawesome",
      stylesheet = c("css/all.min.css", "css/v4-shims.min.css")
    ),
    tags$script(src = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"),
    shinyjs$useShinyjs()
  )
}
