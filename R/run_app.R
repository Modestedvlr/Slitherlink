#' Lancer l'application Shiny Slitherlink
#'
#' @export
run_slitherlink <- function() {
  app_dir <- system.file("shiny-app", package = "SlitherlinkR")
  if (app_dir == "") {
    stop("L'application Shiny est introuvable. Réinstallez le package.")
  }
  shiny::runApp(app_dir, display.mode = "normal")
}

