#' @export
server <- function(input, output, session) {
  box::use(shiny = shiny[tags])
  site <- getOption("ndexr_site", "ndexrconsole")
  switch(site,
    "ndexrconsole" = {
      box::use(. / r / ndexrconsole)
      ndexrconsole$server_ndexrconsole("ndexrconsole")
    },
    "ndexrio" = {
      box::use(. / r / ndexrio)
      ndexrio$server_ndexrio("ndexrio")
    },
    "classcadet" = {
      box::use(. / r / classcadet)
      classcadet$server_classcadet("classcadet")
    },
    "classcadetconsole" = {
      box::use(. / r / classcadetconsole)
      classcadetconsole$server_classcadetconsole("classcadetconsole")
    },
    "carneproperties" = {
      box::use(. / r / carneproperties)
      carneproperties$server_carneproperties("carneproperties")
    }
  )
}
