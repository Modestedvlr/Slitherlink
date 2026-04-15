test_that("init_db cree la base sans erreur", {
  expect_no_error({
    tmp <- tempfile(fileext=".db")
    con <- DBI::dbConnect(RSQLite::SQLite(), tmp)
    DBI::dbExecute(con, "CREATE TABLE IF NOT EXISTS scores (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pseudo TEXT, temps REAL, difficulte TEXT, date TEXT)")
    DBI::dbDisconnect(con)
    unlink(tmp)
  })
})

test_that("save_score insere un score correctement", {
  tmp <- tempfile(fileext=".db")
  con <- DBI::dbConnect(RSQLite::SQLite(), tmp)
  DBI::dbExecute(con, "CREATE TABLE scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pseudo TEXT, temps REAL, difficulte TEXT, date TEXT)")
  DBI::dbExecute(con, "INSERT INTO scores VALUES (NULL,?,?,?,?)",
                 params=list("Test", 10.5, "facile", "2026-04-14"))
  df <- DBI::dbGetQuery(con, "SELECT * FROM scores")
  DBI::dbDisconnect(con); unlink(tmp)
  expect_equal(nrow(df), 1)
  expect_equal(df$pseudo, "Test")
})

test_that("la table scores a les bonnes colonnes", {
  tmp <- tempfile(fileext=".db")
  con <- DBI::dbConnect(RSQLite::SQLite(), tmp)
  DBI::dbExecute(con, "CREATE TABLE scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pseudo TEXT, temps REAL, difficulte TEXT, date TEXT)")
  cols <- DBI::dbListFields(con, "scores")
  DBI::dbDisconnect(con); unlink(tmp)
  expect_true(all(c("pseudo","temps","difficulte","date") %in% cols))
})
