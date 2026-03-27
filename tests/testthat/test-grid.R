test_that("La structure de données est correcte", {
  m <- matrix(c(3, 2, NA, 0), nrow = 2)
  g <- new_slitherlink(m)

  expect_s3_class(g, "slitherlink")
  expect_type(g, "list")
  # Vérification des dimensions (Rigueur mathématique)
  expect_equal(dim(g$h_edges), c(3, 2)) # n+1 lignes
  expect_equal(dim(g$v_edges), c(2, 3)) # m+1 colonnes
})

test_that("La bascule des segments (toggle) cycle correctement", {
  m <- matrix(NA, nrow = 2, ncol = 2)
  g <- new_slitherlink(m)

  # Cycle 0L -> 1L -> 2L -> 0L
  g <- toggle_h_edge(g, 1, 1)
  expect_equal(g$h_edges[1, 1], 1L)

  g <- toggle_h_edge(g, 1, 1)
  expect_equal(g$h_edges[1, 1], 2L)

  g <- toggle_h_edge(g, 1, 1)
  expect_equal(g$h_edges[1, 1], 0L)
})

test_that("Les erreurs de coordonnées sont détectées", {
  m <- matrix(NA, nrow = 2, ncol = 2)
  g <- new_slitherlink(m)
  # Test de la programmation défensive (Livre Marin p. 126)
  expect_error(toggle_h_edge(g, 10, 10))
})
