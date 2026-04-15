test_that("generate_puzzle retourne un objet valide", {
  h <- matrix(0L,4,3); v <- matrix(0L,3,4)
  h[1,] <- 1L; h[4,] <- 1L; v[,1] <- 1L; v[,4] <- 1L
  puzzle <- generate_puzzle(h, v, difficulty="facile")
  expect_type(puzzle, "list")
  expect_true("grid" %in% names(puzzle))
  expect_true("solution" %in% names(puzzle))
})

test_that("generate_puzzle retourne une grille avec des NA", {
  h <- matrix(0L,4,3); v <- matrix(0L,3,4)
  h[1,] <- 1L; h[4,] <- 1L; v[,1] <- 1L; v[,4] <- 1L
  puzzle <- generate_puzzle(h, v, difficulty="facile")
  expect_true(any(is.na(puzzle$grid)))
})

test_that("la solution de generate_puzzle est valide", {
  h <- matrix(0L,4,3); v <- matrix(0L,3,4)
  h[1,] <- 1L; h[4,] <- 1L; v[,1] <- 1L; v[,4] <- 1L
  puzzle <- generate_puzzle(h, v, difficulty="moyen")
  g <- new_slitherlink(puzzle$grid)
  g$h_edges <- puzzle$solution$h_edges
  g$v_edges <- puzzle$solution$v_edges
  expect_true(validate_solution(g)$valid)
})

test_that("generate_puzzle fonctionne pour les 3 niveaux", {
  h <- matrix(0L,4,3); v <- matrix(0L,3,4)
  h[1,] <- 1L; h[4,] <- 1L; v[,1] <- 1L; v[,4] <- 1L
  for (diff in c("facile", "moyen", "difficile")) {
    puzzle <- generate_puzzle(h, v, difficulty=diff)
    expect_false(is.null(puzzle$grid))
  }
})
