packages <- c(
  "shiny",
  "shinydashboard",
  "tidyverse",
  "plotly",
  "DT"
)

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}