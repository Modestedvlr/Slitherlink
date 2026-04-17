test_that("generate_puzzle retourne un objet valide", {
  res <- generate_puzzle(difficulty = "facile", n = 3, m = 3)

  expect_type(res, "list")
  expect_named(res, c("grid", "solution"))
  expect_true(is.matrix(res$grid))
})

test_that("generate_puzzle respecte les dimensions", {
  n <- 4
  m <- 5
  res <- generate_puzzle(difficulty = "moyen", n = n, m = m)

  expect_equal(nrow(res$grid), n)
  expect_equal(ncol(res$grid), m)
})

test_that("generate_puzzle fonctionne pour les 3 niveaux", {
  levels <- c("facile", "moyen", "difficile")
  for (diff in levels) {
    res <- generate_puzzle(difficulty = diff, n = 3, m = 3)
    expect_true(is.matrix(res$grid))
  }
})
