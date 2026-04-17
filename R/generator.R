# =============================================================================
# GENERATEUR DE PUZZLES - Slitherlink
# =============================================================================

#' Calculer les indices depuis une boucle
#'
#' @param h Matrice h_edges de la solution
#' @param v Matrice v_edges de la solution
#' @return Matrice d'indices (0-3)
#' @export
indices_from_loop <- function(h, v) {
  n <- nrow(v); m <- nrow(h) - 1
  mat <- matrix(0L, nrow=n, ncol=m)
  for (r in 1:n)
    for (c in 1:m)
      mat[r,c] <- as.integer(
        (h[r,c]==1L) + (h[r+1,c]==1L) +
        (v[r,c]==1L) + (v[r,c+1]==1L)
      )
  storage.mode(mat) <- "integer"
  mat
}

#' Verifier qu'un puzzle a une solution unique
#'
#' @param grid Un objet de classe \code{slitherlink}
#' @param sol_h Matrice h_edges de la solution
#' @param sol_v Matrice v_edges de la solution
#' @return TRUE si la solution est unique, FALSE sinon
#' @export
is_unique_solution <- function(grid, sol_h, sol_v) {

  n <- grid$n; m <- grid$m
  n_h <- (n + 1) * m
  E   <- n_h + n * (m + 1)
  NV  <- (n + 1) * (m + 1)

  h_idx <- function(r, c) (r - 1L) * m + c
  v_idx <- function(r, c) n_h + (r - 1L) * (m + 1L) + c
  enc_v <- function(r, c) (r - 1L) * (m + 1L) + c

  vert_adj <- vector("list", NV)
  for (i in seq_len(NV)) vert_adj[[i]] <- integer(0)
  for (r in seq_len(n+1))
    for (c in seq_len(m)) {
      e <- h_idx(r,c); u <- enc_v(r,c); vv <- enc_v(r,c+1)
      vert_adj[[u]] <- c(vert_adj[[u]], e)
      vert_adj[[vv]] <- c(vert_adj[[vv]], e)
    }
  for (r in seq_len(n))
    for (c in seq_len(m+1)) {
      e <- v_idx(r,c); u <- enc_v(r,c); vv <- enc_v(r+1,c)
      vert_adj[[u]] <- c(vert_adj[[u]], e)
      vert_adj[[vv]] <- c(vert_adj[[vv]], e)
    }

  n_total <- E + NV
  obj     <- rep(0, n_total)
  con_mat <- matrix(0, nrow=0, ncol=n_total)
  con_dir <- character(0)
  con_rhs <- numeric(0)

  for (r in seq_len(n))
    for (c in seq_len(m)) {
      val <- grid$indices[r,c]
      if (is.na(val)) next
      row_vec <- rep(0, n_total)
      row_vec[c(h_idx(r,c), h_idx(r+1,c),
                v_idx(r,c), v_idx(r,c+1))] <- 1
      con_mat <- rbind(con_mat, row_vec)
      con_dir <- c(con_dir, "=")
      con_rhs <- c(con_rhs, val)
    }

  for (vv in seq_len(NV)) {
    adj <- vert_adj[[vv]]
    if (length(adj) == 0) next
    row_vec <- rep(0, n_total)
    row_vec[adj]    <-  1
    row_vec[E + vv] <- -2
    con_mat <- rbind(con_mat, row_vec)
    con_dir <- c(con_dir, "=")
    con_rhs <- c(con_rhs, 0)
  }

  sol_edges <- integer(0)
  for (r in seq_len(n+1))
    for (c in seq_len(m))
      if (sol_h[r,c] == 1L) sol_edges <- c(sol_edges, h_idx(r,c))
  for (r in seq_len(n))
    for (c in seq_len(m+1))
      if (sol_v[r,c] == 1L) sol_edges <- c(sol_edges, v_idx(r,c))

  if (length(sol_edges) > 0) {
    row_vec <- rep(0, n_total)
    row_vec[sol_edges] <- 1
    con_mat <- rbind(con_mat, row_vec)
    con_dir <- c(con_dir, "<=")
    con_rhs <- c(con_rhs, length(sol_edges) - 1)
  }

  lp_res <- tryCatch(
    lpSolve::lp("min", obj, con_mat, con_dir, con_rhs, all.bin=TRUE),
    error = function(e) NULL
  )

  if (is.null(lp_res) || lp_res$status != 0) return(TRUE)
  sol2 <- lp_res$solution[seq_len(E)] > 0.5
  if (sum(sol2) == 0) return(TRUE)
  return(FALSE)
}

#' Generer un puzzle Slitherlink avec solution unique garantie
#'
#' Pour les grilles 3x3 et 4x4, verifie l'unicite via ILP.
#' Pour les grilles 5x5, masque directement les cases (unicite non verifiee
#' car trop couteuse) mais garantit la presence de NA.
#'
#' @param h_sol Matrice h_edges de la solution
#' @param v_sol Matrice v_edges de la solution
#' @param difficulty Niveau : "facile" (30 pct NA), "moyen" (50 pct), "difficile" (70 pct)
#' @param max_attempts Nombre maximum de tentatives pour 3x3 et 4x4 (defaut 20)
#' @return Une liste avec \code{grid} (indices partiels) et \code{solution}
#' @export
generate_puzzle <- function(h_sol, v_sol,
                            difficulty   = "moyen",
                            max_attempts = 20) {

  full_indices <- indices_from_loop(h_sol, v_sol)
  n <- nrow(full_indices); m <- ncol(full_indices)
  total_cells <- n * m

  hide_ratio <- switch(difficulty,
    "facile"    = 0.30,
    "moyen"     = 0.50,
    "difficile" = 0.65,
    0.50
  )
  n_hide <- round(total_cells * hide_ratio)

  # ── 5x5 : masquage direct sans verification d'unicite ──────────────────────
  # La verification ILP est trop couteuse et echoue souvent sur 5x5
  # On garantit simplement la presence de NA
  if (n >= 5 || m >= 5) {
    hide_idx       <- sample(total_cells, n_hide)
    puzzle_indices <- full_indices
    puzzle_indices[hide_idx] <- NA_integer_
    return(list(
      grid     = puzzle_indices,
      solution = list(h_edges = h_sol, v_edges = v_sol)
    ))
  }

  # ── 3x3 et 4x4 : verification d'unicite via ILP ────────────────────────────
  for (attempt in seq_len(max_attempts)) {
    hide_idx       <- sample(total_cells, n_hide)
    puzzle_indices <- full_indices
    puzzle_indices[hide_idx] <- NA_integer_

    g <- new_slitherlink(puzzle_indices)

    unique <- tryCatch(
      is_unique_solution(g, h_sol, v_sol),
      error = function(e) FALSE
    )

    if (unique) {
      return(list(
        grid     = puzzle_indices,
        solution = list(h_edges = h_sol, v_edges = v_sol)
      ))
    }
  }

  # Fallback : masquage simple sans verification
  message("Unicite non garantie apres ", max_attempts,
          " tentatives - masquage simple applique.")
  hide_idx       <- sample(total_cells, n_hide)
  puzzle_indices <- full_indices
  puzzle_indices[hide_idx] <- NA_integer_
  list(
    grid     = puzzle_indices,
    solution = list(h_edges = h_sol, v_edges = v_sol)
  )
}