#' @importFrom RSQLite SQLite
#' @importFrom DBI dbConnect dbExecute dbDisconnect
init_db <- function() {
  con <- DBI::dbConnect(RSQLite::SQLite(), "leaderboard.db")
  dbExecute(con, "CREATE TABLE IF NOT EXISTS scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pseudo TEXT,
    temps REAL,
    difficulte TEXT,
    date TEXT
  )")
  dbDisconnect(con)
}

save_score <- function(pseudo, temps, diff) {
  con <- dbConnect(SQLite(), "leaderboard.db")
  dbExecute(con, "INSERT INTO scores (pseudo, temps, difficulte, date) VALUES (?, ?, ?, ?)",
            params = list(pseudo, temps, diff, as.character(Sys.Date())))
  dbDisconnect(con)
}
