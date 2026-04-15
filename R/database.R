#' Initialiser la base de données
#'
#' @param db_path Chemin vers le fichier de base de données.
#' @importFrom RSQLite SQLite
#' @importFrom DBI dbConnect dbExecute dbDisconnect
#' @export
init_db <- function(db_path = "leaderboard.db") {
  con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
  DBI::dbExecute(con, "CREATE TABLE IF NOT EXISTS scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pseudo TEXT,
    temps REAL,
    difficulte TEXT,
    date TEXT
  )")
  DBI::dbDisconnect(con)
}

#' Sauvegarder le score
#'
#' @param pseudo Pseudo du joueur
#' @param temps Temps en secondes
#' @param diff Niveau de difficulté
#' @param db_path Chemin vers le fichier de base de données.
#' @importFrom DBI dbConnect dbExecute dbDisconnect
#' @importFrom RSQLite SQLite
#' @export
save_score <- function(pseudo, temps, diff, db_path = "leaderboard.db") {
  con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
  DBI::dbExecute(con, "INSERT INTO scores (pseudo, temps, difficulte, date) VALUES (?, ?, ?, ?)",
                 params = list(pseudo, temps, diff, as.character(Sys.Date())))
  DBI::dbDisconnect(con)
}
