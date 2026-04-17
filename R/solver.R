# =============================================================================
# SOLVEUR ILP — Slitherlink avec lpSolve
# =============================================================================

#' Résoudre un puzzle Slitherlink via ILP
#' @param grid Un objet de classe \code{slitherlink}
#' @return La grille résolue ou NULL
#' @export
solve_slitherlink <- function(grid) {

  n_rows <- grid$n   # ← renommé pour éviter conflit avec n()
  n_cols <- grid$m   # ← renommé pour éviter conflit avec m

  n_h   <- (n_rows + 1) * n_cols
  E     <- n_h + n_rows * (n_cols + 1)
  NV    <- (n_rows + 1) * (n_cols + 1)

  # Fonctions d'encodage locales
  h_idx <- function(r, c) (r - 1L) * n_cols + c
  v_idx <- function(r, c) n_h + (r - 1L) * (n_cols + 1L) + c
  enc_v <- function(r, c) (r - 1L) * (n_cols + 1L) + c

  # Adjacence sommets → arêtes
  vert_adj <- vector("list", NV)
  for (i in seq_len(NV)) vert_adj[[i]] <- integer(0)

  for (r in seq_len(n_rows + 1))
    for (c in seq_len(n_cols)) {
      e <- h_idx(r, c)
      u <- enc_v(r, c); vv <- enc_v(r, c + 1)
      vert_adj[[u]]  <- c(vert_adj[[u]],  e)
      vert_adj[[vv]] <- c(vert_adj[[vv]], e)
    }
  for (r in seq_len(n_rows))
    for (c in seq_len(n_cols + 1)) {
      e <- v_idx(r, c)
      u <- enc_v(r, c); vv <- enc_v(r + 1, c)
      vert_adj[[u]]  <- c(vert_adj[[u]],  e)
      vert_adj[[vv]] <- c(vert_adj[[vv]], e)
    }

  forbidden <- list()

  for (iter in seq_len(30)) {

    n_total <- E + NV
    obj     <- rep(0, n_total)
    con_mat <- matrix(0, nrow = 0, ncol = n_total)
    con_dir <- character(0)
    con_rhs <- numeric(0)

    # Contraintes des cases
    for (r in seq_len(n_rows))
      for (c in seq_len(n_cols)) {
        val <- grid$indices[r, c]
        if (is.na(val)) next
        row_vec <- rep(0, n_total)
        row_vec[c(h_idx(r,c), h_idx(r+1,c),
                  v_idx(r,c), v_idx(r,c+1))] <- 1
        con_mat <- rbind(con_mat, row_vec)
        con_dir <- c(con_dir, "=")
        con_rhs <- c(con_rhs, val)
      }

    # Contraintes degré : sum(arêtes) = 2 * y[v]
    for (vv in seq_len(NV)) {
      adj <- vert_adj[[vv]]
      if (length(adj) == 0) next
      row_vec <- rep(0, n_total)
      row_vec[adj]      <-  1
      row_vec[E + vv]   <- -2
      con_mat <- rbind(con_mat, row_vec)
      con_dir <- c(con_dir, "=")
      con_rhs <- c(con_rhs, 0)
    }

    # Élimination des sous-tours
    for (sub in forbidden) {
      row_vec <- rep(0, n_total)
      row_vec[sub] <- 1
      con_mat <- rbind(con_mat, row_vec)
      con_dir <- c(con_dir, "<=")
      con_rhs <- c(con_rhs, length(sub) - 1)
    }

    # Résoudre avec lpSolve
    lp_res <- tryCatch(
      lpSolve::lp("min", obj, con_mat, con_dir, con_rhs, all.bin = TRUE),
      error = function(e) NULL
    )

    if (is.null(lp_res) || lp_res$status != 0) return(NULL)

    sol <- lp_res$solution[seq_len(E)] > 0.5

    # Détecter les sous-tours
    subtours <- .find_subtours_ilp(sol, n_rows, n_cols,
                                   h_idx, v_idx, enc_v)

    if (length(subtours) <= 1) {
      # Appliquer la solution
      grid$h_edges <- matrix(0L, nrow = n_rows + 1, ncol = n_cols)
      grid$v_edges <- matrix(0L, nrow = n_rows,     ncol = n_cols + 1)
      for (r in seq_len(n_rows + 1))
        for (c in seq_len(n_cols))
          if (sol[h_idx(r, c)]) grid$h_edges[r, c] <- 1L
      for (r in seq_len(n_rows))
        for (c in seq_len(n_cols + 1))
          if (sol[v_idx(r, c)]) grid$v_edges[r, c] <- 1L
      return(grid)
    }

    # Ajouter les sous-tours comme contraintes interdites
    sizes   <- sapply(subtours, length)
    biggest <- which.max(sizes)
    for (i in seq_along(subtours))
      if (i != biggest)
        forbidden <- c(forbidden, list(subtours[[i]]))
  }

  return(NULL)
}

# =============================================================================
# DÉTECTION DES SOUS-TOURS
# =============================================================================
.find_subtours_ilp <- function(sol, n_rows, n_cols, h_idx, v_idx, enc_v) {

  NV      <- (n_rows + 1) * (n_cols + 1)
  adj     <- vector("list", NV)
  edge_of <- vector("list", NV)
  for (i in seq_len(NV)) {
    adj[[i]]     <- integer(0)
    edge_of[[i]] <- integer(0)
  }

  for (r in seq_len(n_rows + 1))
    for (c in seq_len(n_cols))
      if (isTRUE(sol[h_idx(r, c)])) {
        e <- h_idx(r, c)
        u <- enc_v(r, c); vv <- enc_v(r, c + 1)
        adj[[u]]  <- c(adj[[u]],  vv); edge_of[[u]]  <- c(edge_of[[u]],  e)
        adj[[vv]] <- c(adj[[vv]], u);  edge_of[[vv]] <- c(edge_of[[vv]], e)
      }

  for (r in seq_len(n_rows))
    for (c in seq_len(n_cols + 1))
      if (isTRUE(sol[v_idx(r, c)])) {
        e <- v_idx(r, c)
        u <- enc_v(r, c); vv <- enc_v(r + 1, c)
        adj[[u]]  <- c(adj[[u]],  vv); edge_of[[u]]  <- c(edge_of[[u]],  e)
        adj[[vv]] <- c(adj[[vv]], u);  edge_of[[vv]] <- c(edge_of[[vv]], e)
      }

  active <- which(sapply(adj, length) > 0)
  if (length(active) == 0) return(list())

  visited    <- logical(NV)
  components <- list()

  for (start in active) {
    if (visited[start]) next
    queue  <- start
    comp_e <- integer(0)
    while (length(queue) > 0) {
      node  <- queue[1]; queue <- queue[-1]
      if (visited[node]) next
      visited[node] <- TRUE
      comp_e        <- c(comp_e, edge_of[[node]])
      unvisited     <- adj[[node]][!visited[adj[[node]]]]
      queue         <- c(queue, unvisited)
    }
    components <- c(components, list(unique(comp_e)))
  }
  components
}
