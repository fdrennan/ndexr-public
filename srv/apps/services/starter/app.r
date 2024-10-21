readRenviron(".env.local")

source("onload/activate.r")

options(ndexr_site = "ndexr.io") # ndexr.io

shiny::runApp("src")
