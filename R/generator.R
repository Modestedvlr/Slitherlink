#' Générer une boucle complexe aléatoire
#' @param n,m Dimensions de la grille
#' @return Une liste (h_edges, v_edges)
#' @export
generate_random_loop <- function(n, m) {
  n_cells <- n * m
  n_to_fill <- sample(floor(n_cells/3):floor(n_cells/1.5), 1)
  filled <- matrix(FALSE, n, m)
  curr_r <- sample(1:n, 1); curr_c <- sample(1:m, 1)
  filled[curr_r, curr_c] <- TRUE

  for(i in 2:n_to_fill) {
    neighbors <- which(!filled, arr.ind = TRUE)
    possible <- c()
    for(j in 1:nrow(neighbors)) {
      r <- neighbors[j,1]; c <- neighbors[j,2]
      has_adj <- (r > 1 && filled[r-1, c]) || (r < n && filled[r+1, c]) ||
        (c > 1 && filled[r, c-1]) || (c < m && filled[r, c+1])
      if(has_adj) possible <- c(possible, j)
    }
    if(length(possible) == 0) break
    next_cell <- neighbors[sample(possible, 1), ]
    filled[next_cell[1], next_cell[2]] <- TRUE
  }

  h <- matrix(0L, n + 1, m); v <- matrix(0L, n, m + 1)
  for(r in 1:n) {
    for(c in 1:m) {
      if(filled[r, c]) {
        if(r == 1 || !filled[r-1, c]) h[r, c] <- 1L
        if(r == n || !filled[r+1, c]) h[r+1, c] <- 1L
        if(c == 1 || !filled[r, c-1]) v[r, c] <- 1L
        if(c == m || !filled[r, c+1]) v[r, c+1] <- 1L
      }
    }
  }
  return(list(h_edges = h, v_edges = v))
}

#' Calculer les indices depuis une boucle
#' @param h,v Matrices de segments
#' @export
indices_from_loop <- function(h, v) {
  n <- nrow(v); m <- ncol(h)
  mat <- matrix(0L, n, m)
  for (r in 1:n) {
    for (c in 1:m) {
      mat[r,c] <- h[r,c] + h[r+1,c] + v[r,c] + v[r,c+1]
    }
  }
  mat
}

#' Verifier l'unicité (Interne)
#' @export
is_unique_solution <- function(grid, sol_h, sol_v) {
  n <- grid$n; m <- grid$m
  n_h <- (n + 1) * m
  E <- n_h + n * (m + 1)
  NV <- (n + 1) * (m + 1)

  h_idx <- function(r, c) (r - 1L) * m + c
  v_idx <- function(r, c) n_h + (r - 1L) * (m + 1L) + c
  enc_v <- function(r, c) (r - 1L) * (m + 1L) + c

  vert_adj <- vector("list", NV)
  for (r in seq_len(n+1)) {
    for (c in seq_len(m)) {
      e <- h_idx(r,c); u <- enc_v(r,c); vv <- enc_v(r,c+1)
      vert_adj[[u]] <- c(vert_adj[[u]], e); vert_adj[[vv]] <- c(vert_adj[[vv]], e)
    }
  }
  for (r in seq_len(n)) {
    for (c in seq_len(m+1)) {
      e <- v_idx(r,c); u <- enc_v(r,c); vv <- enc_v(r+1,c)
      vert_adj[[u]] <- c(vert_adj[[u]], e); vert_adj[[vv]] <- c(vert_adj[[vv]], e)
    }
  }

  n_total <- E + NV
  obj <- rep(0, n_total)
  con_mat <- matrix(0, nrow=0, ncol=n_total)
  con_dir <- character(0); con_rhs <- numeric(0)

  for (r in seq_len(n)) {
    for (c in seq_len(m)) {
      val <- grid$indices[r,c]
      if (is.na(val)) next
      row_vec <- rep(0, n_total)
      row_vec[c(h_idx(r,c), h_idx(r+1,c), v_idx(r,c), v_idx(r,c+1))] <- 1
      con_mat <- rbind(con_mat, row_vec)
      con_dir <- c(con_dir, "="); con_rhs <- c(con_rhs, val)
    }
  }

  for (vv in seq_len(NV)) {
    adj_e <- vert_adj[[vv]]
    if (length(adj_e) == 0) next
    row_vec <- rep(0, n_total)
    row_vec[adj_e] <- 1; row_vec[E + vv] <- -2
    con_mat <- rbind(con_mat, row_vec)
    con_dir <- c(con_dir, "="); con_rhs <- c(con_rhs, 0)
  }

  sol_edges <- c(which(sol_h == 1L), n_h + which(sol_v == 1L))
  row_vec <- rep(0, n_total)
  row_vec[sol_edges] <- 1
  con_mat <- rbind(con_mat, row_vec)
  con_dir <- c(con_dir, "<="); con_rhs <- c(con_rhs, length(sol_edges) - 1)

  lp_res <- tryCatch(lpSolve::lp("min", obj, con_mat, con_dir, con_rhs, all.bin=TRUE), error = function(e) NULL)
  if (is.null(lp_res) || lp_res$status != 0) return(TRUE)
  return(FALSE)
}

#' Générer un puzzle Slitherlink
#' @export
generate_puzzle <- function(difficulty = "moyen", n = 5, m = 5) {
  sol <- generate_random_loop(n, m)
  full_indices <- indices_from_loop(sol$h_edges, sol$v_edges)

  target_clues <- switch(difficulty, "facile" = floor(n*m*0.6), "moyen" = floor(n*m*0.45), floor(n*m*0.3))

  cells <- sample(1:(n*m))
  current_indices <- full_indices
  clue_count <- n*m

  for(cell_idx in cells) {
    if(clue_count <= target_clues) break
    val_backup <- current_indices[cell_idx]
    current_indices[cell_idx] <- NA
    g_test <- list(n = n, m = m, indices = current_indices)
    if(!is_unique_solution(g_test, sol$h_edges, sol$v_edges)) {
      current_indices[cell_idx] <- val_backup
    } else {
      clue_count <- clue_count - 1
    }
  }
  return(list(grid = current_indices, solution = sol))
}
