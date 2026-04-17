# =============================================================================
# TESTS — Generateur de puzzles
# =============================================================================

# Boucle de base pour les tests (3x3 bord exterieur)
h_test <- matrix(0L,4,3); v_test <- matrix(0L,3,4)
h_test[1,] <- 1L; h_test[4,] <- 1L
v_test[,1] <- 1L; v_test[,4] <- 1L

test_that("generate_puzzle retourne un objet valide", {
  puzzle <- generate_puzzle(h_test, v_test, difficulty="facile")
  expect_type(puzzle, "list")
  expect_true("grid"     %in% names(puzzle))
  expect_true("solution" %in% names(puzzle))
})

test_that("generate_puzzle retourne une grille avec des NA", {
  puzzle <- generate_puzzle(h_test, v_test, difficulty="facile")
  expect_true(any(is.na(puzzle$grid)))
})

test_that("generate_puzzle respecte les dimensions", {
  puzzle <- generate_puzzle(h_test, v_test, difficulty="moyen")
  expect_equal(nrow(puzzle$grid), 3)
  expect_equal(ncol(puzzle$grid), 3)
})

test_that("generate_puzzle fonctionne pour les 3 niveaux", {
  for (diff in c("facile", "moyen", "difficile")) {
    puzzle <- generate_puzzle(h_test, v_test, difficulty=diff)
    expect_false(is.null(puzzle$grid))
  }
})

test_that("la solution de generate_puzzle est valide", {
  puzzle <- generate_puzzle(h_test, v_test, difficulty="moyen")
  g <- new_slitherlink(puzzle$grid)
  g$h_edges <- puzzle$solution$h_edges
  g$v_edges <- puzzle$solution$v_edges
  expect_true(validate_solution(g)$valid)
})

test_that("generate_puzzle 4x4 retourne une grille valide", {
  h4 <- matrix(0L,5,4); v4 <- matrix(0L,4,5)
  h4[1,] <- 1L; h4[5,] <- 1L
  v4[,1] <- 1L; v4[,5] <- 1L
  puzzle <- generate_puzzle(h4, v4, difficulty="moyen")
  expect_type(puzzle, "list")
  expect_true(any(is.na(puzzle$grid)))
})

test_that("generate_puzzle 5x5 retourne des NA", {
  h5 <- matrix(0L,6,5); v5 <- matrix(0L,5,6)
  h5[1,] <- 1L; h5[6,] <- 1L
  v5[,1] <- 1L; v5[,6] <- 1L
  puzzle <- generate_puzzle(h5, v5, difficulty="difficile")
  expect_true(any(is.na(puzzle$grid)))
})

test_that("indices_from_loop calcule correctement les indices", {
  m <- indices_from_loop(h_test, v_test)
  expect_equal(nrow(m), 3)
  expect_equal(ncol(m), 3)
  expect_true(all(m >= 0L & m <= 3L))
})
