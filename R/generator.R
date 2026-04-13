# =============================================================================
# GÉNÉRATEUR DE PUZZLES — Slitherlink
# =============================================================================

#' Générer un puzzle Slitherlink depuis une boucle avec indices masqués
#'
#' @param h_sol Matrice h_edges de la solution
#' @param v_sol Matrice v_edges de la solution
#' @param difficulty "facile" (peu de NA), "moyen", "difficile" (beaucoup de NA)
#' @return Une liste avec grid (indices partiels) et solution
#' @export
generate_puzzle <- function(h_sol, v_sol, difficulty = "moyen") {

  n <- nrow(v_sol)
  m <- nrow(h_sol) - 1

  # Calculer tous les indices depuis la boucle
  full_indices <- matrix(0L, nrow=n, ncol=m)
  for (r in 1:n)
    for (c in 1:m)
      full_indices[r,c] <- (h_sol[r,c]==1L) + (h_sol[r+1,c]==1L) +
                           (v_sol[r,c]==1L) + (v_sol[r,c+1]==1L)

  # Proportion de cases à masquer selon la difficulté
  hide_ratio <- switch(difficulty,
    "facile"    = 0.30,   # 30% de NA
    "moyen"     = 0.50,   # 50% de NA
    "difficile" = 0.70,   # 70% de NA
    0.50
  )

  # Masquer aléatoirement certaines cases
  total_cells <- n * m
  n_hide      <- round(total_cells * hide_ratio)
  hide_idx    <- sample(total_cells, n_hide)

  puzzle_indices <- full_indices
  storage.mode(puzzle_indices) <- "integer"
  puzzle_indices[hide_idx] <- NA_integer_

  list(
    grid     = puzzle_indices,
    solution = list(h_edges = h_sol, v_edges = v_sol)
  )
}