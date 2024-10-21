options(warn = -1)
library_names <- c(
  "rsthemes",
  "paws",
  "paws.analytics",
  "paws.application.integration",
  "paws.common",
  "paws.compute",
  "paws.cost.management",
  "paws.customer.engagement",
  "paws.database",
  "paws.developer.tools",
  "paws.end.user.computing",
  "paws.machine.learning",
  "paws.management",
  "paws.networking",
  "paws.security.identity",
  "paws.storage",
  "styler",
  "devtools",
  "rsconnect"
)

if ("renv" %in% utils::installed.packages()[, 1]) {
  renv::settings$ignored.packages(library_names)
}


lapply(list.files("./onload/options", full.names = TRUE, pattern = "[.]r$"), source)
