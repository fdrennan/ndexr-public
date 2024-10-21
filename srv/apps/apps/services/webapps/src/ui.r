#' @export
ui <- function(request) {
  switch(getOption("ndexr_site", "ndexrconsole"),
    "ndexrconsole" = {
      box::use(. / r / ndexrconsole)
      ndexrconsole$ui_ndexrconsole("ndexrconsole", request)
    },
    "ndexrio" = {
      box::use(. / r / ndexrio)
      ndexrio$ui_ndexrio("ndexrio", request)
    },
    "classcadet" = {
      box::use(. / r / classcadet)
      classcadet$ui_classcadet("classcadet", request)
    },
    "classcadetconsole" = {
      box::use(. / r / classcadetconsole)
      classcadetconsole$ui_classcadetconsole("classcadetconsole", request)
    },
    "carneproperties" = {
      box::use(. / r / carneproperties)
      carneproperties$ui_carneproperties("carneproperties", request)
    }
  )
}
