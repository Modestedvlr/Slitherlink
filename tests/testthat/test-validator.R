# =============================================================================
# TESTS UNITAIRES — Validateur de solution
# =============================================================================

test_that("check_cells détecte les cases correctes", {
  m <- matrix(c(2, 2, 2, 2), nrow = 2)
  g <- new_slitherlink(m)
  g <- toggle_h_edge(g, 1, 1); g <- toggle_h_edge(g, 1, 2)
  g <- toggle_h_edge(g, 3, 1); g <- toggle_h_edge(g, 3, 2)
  g <- toggle_v_edge(g, 1, 1); g <- toggle_v_edge(g, 2, 1)
  g <- toggle_v_edge(g, 1, 3); g <- toggle_v_edge(g, 2, 3)

  res <- check_cells(g)
  expect_true(res$ok)
  expect_equal(nrow(res$errors), 0)
})

test_that("check_cells détecte les cases incorrectes", {
  m <- matrix(c(3, 2, 2, 3), nrow = 2)
  g <- new_slitherlink(m)
  g <- toggle_h_edge(g, 1, 1); g <- toggle_h_edge(g, 1, 2)
  g <- toggle_h_edge(g, 3, 1); g <- toggle_h_edge(g, 3, 2)
  g <- toggle_v_edge(g, 1, 1); g <- toggle_v_edge(g, 2, 1)
  g <- toggle_v_edge(g, 1, 3); g <- toggle_v_edge(g, 2, 3)

  res <- check_cells(g)
  expect_false(res$ok)
  expect_equal(nrow(res$errors), 2)  # cases (1,1) et (2,2) en erreur
})

test_that("check_cells ignore les cases NA", {
  m <- matrix(NA, nrow = 2, ncol = 2)
  g <- new_slitherlink(m)
  # Même sans segments, pas d'erreur car tout est NA
  res <- check_cells(g)
  expect_true(res$ok)
})

test_that("check_degree valide une boucle correcte", {
  m <- matrix(NA, nrow = 2, ncol = 2)
  g <- new_slitherlink(m)
  g <- toggle_h_edge(g, 1, 1); g <- toggle_h_edge(g, 1, 2)
  g <- toggle_h_edge(g, 3, 1); g <- toggle_h_edge(g, 3, 2)
  g <- toggle_v_edge(g, 1, 1); g <- toggle_v_edge(g, 2, 1)
  g <- toggle_v_edge(g, 1, 3); g <- toggle_v_edge(g, 2, 3)

  res <- check_degree(g)
  expect_true(res$ok)
  expect_equal(nrow(res$errors), 0)
})

test_that("check_degree détecte un sommet de degré 1", {
  m <- matrix(NA, nrow = 2, ncol = 2)
  g <- new_slitherlink(m)
  # Un seul segment tracé → sommet de degré 1 aux deux bouts
  g <- toggle_h_edge(g, 1, 1)

  res <- check_degree(g)
  expect_false(res$ok)
  expect_equal(nrow(res$errors), 2)  # les 2 extrémités du segment
})

test_that("check_loop détecte une boucle unique", {
  m <- matrix(NA, nrow = 2, ncol = 2)
  g <- new_slitherlink(m)
  g <- toggle_h_edge(g, 1, 1); g <- toggle_h_edge(g, 1, 2)
  g <- toggle_h_edge(g, 3, 1); g <- toggle_h_edge(g, 3, 2)
  g <- toggle_v_edge(g, 1, 1); g <- toggle_v_edge(g, 2, 1)
  g <- toggle_v_edge(g, 1, 3); g <- toggle_v_edge(g, 2, 3)

  res <- check_loop(g)
  expect_true(res$ok)
})

test_that("check_loop détecte deux boucles séparées", {
  m <- matrix(NA, nrow = 4, ncol = 4)
  g <- new_slitherlink(m)
  # Boucle 1x1 en haut à gauche
  g <- toggle_h_edge(g, 1, 1); g <- toggle_h_edge(g, 2, 1)
  g <- toggle_v_edge(g, 1, 1); g <- toggle_v_edge(g, 1, 2)
  # Boucle 1x1 en bas à droite
  g <- toggle_h_edge(g, 4, 4); g <- toggle_h_edge(g, 5, 4)
  g <- toggle_v_edge(g, 4, 4); g <- toggle_v_edge(g, 4, 5)

  res <- check_loop(g)
  expect_false(res$ok)
  expect_match(res$message, "Plusieurs boucles")
})

test_that("check_loop retourne FALSE si aucun segment", {
  m <- matrix(NA, nrow = 2, ncol = 2)
  g <- new_slitherlink(m)

  res <- check_loop(g)
  expect_false(res$ok)
  expect_match(res$message, "Aucun segment")
})

test_that("validate_solution retourne TRUE sur une solution complète", {
  m <- matrix(c(2, 2, 2, 2), nrow = 2)
  g <- new_slitherlink(m)
  g <- toggle_h_edge(g, 1, 1); g <- toggle_h_edge(g, 1, 2)
  g <- toggle_h_edge(g, 3, 1); g <- toggle_h_edge(g, 3, 2)
  g <- toggle_v_edge(g, 1, 1); g <- toggle_v_edge(g, 2, 1)
  g <- toggle_v_edge(g, 1, 3); g <- toggle_v_edge(g, 2, 3)

  res <- validate_solution(g)
  expect_true(res$valid)
  expect_match(res$messages, "Felicitations")
})

test_that("validate_solution retourne FALSE et plusieurs messages sur erreurs multiples", {
  m <- matrix(c(3, 2, 2, 3), nrow = 2)
  g <- new_slitherlink(m)
  g <- toggle_h_edge(g, 1, 1); g <- toggle_h_edge(g, 1, 2)
  g <- toggle_h_edge(g, 3, 1); g <- toggle_h_edge(g, 3, 2)
  g <- toggle_v_edge(g, 1, 1); g <- toggle_v_edge(g, 2, 1)
  g <- toggle_v_edge(g, 1, 3); g <- toggle_v_edge(g, 2, 3)

  res <- validate_solution(g)
  expect_false(res$valid)
  expect_gte(length(res$messages), 1)
})
