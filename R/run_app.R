#' Lancer l'application Shiny Slitherlink
#' @export
run_slitherlink <- function() {
  app_dir <- system.file("shiny-app", package = "SlitherlinkR")
  
  # Si introuvable via system.file → chercher relativement au package
  if (app_dir == "") {
    app_dir <- file.path(find.package("SlitherlinkR"), "..", "..", "shiny-app")
  }
  
  # En développement avec devtools → chemin direct
  if (!dir.exists(app_dir)) {
    app_dir <- file.path(getwd(), "shiny-app")
  }
  
  if (!dir.exists(app_dir)) {
    stop("L'application Shiny est introuvable.")
  }
  
  shiny::runApp(app_dir, display.mode = "normal")
}