setwd(glue::glue("~/manager/srv/apps/services/webapps"))

readRenviron(".env.local")

source("onload/activate.r")

options(ndexr_site = "ndexrio") # ndexr.io

shiny::runApp("src")

