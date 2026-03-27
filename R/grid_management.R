#' Création d'une structure Slitherlink rigoureuse
#'
#' @param indices Une matrice d'entiers (0-3 ou NA) représentant les contraintes.
#' @return Un objet de classe \code{slitherlink}.
#' @export
new_slitherlink <- function(indices) {
  if (!is.matrix(indices)) {
    stop("L'argument 'indices' doit être une matrice.")
  }
  
  n <- nrow(indices)
  m <- ncol(indices)
  
  res <- list(
    n = as.integer(n),
    m = as.integer(m),
    indices = indices,
    h_edges = matrix(0L, nrow = n + 1, ncol = m),
    v_edges = matrix(0L, nrow = n, ncol = m + 1)
  )
  
  class(res) <- "slitherlink"
  return(res)
}

#' Basculer l'état d'un segment horizontal
#' @export
toggle_h_edge <- function(grid, r, c) {
  grid$h_edges[r, c] <- (grid$h_edges[r, c] + 1L) %% 3L
  return(grid)
}

#' Basculer l'état d'un segment vertical
#' @export
toggle_v_edge <- function(grid, r, c) {
  grid$v_edges[r, c] <- (grid$v_edges[r, c] + 1L) %% 3L
  return(grid)
}

#' @export
print.slitherlink <- function(x, ...) {
  cat("Jeu Slitherlink (Grille ", x$n, "x", x$m, ")\n", sep = "")
  cat("État actuel : ", sum(x$h_edges == 1L) + sum(x$v_edges == 1L), " segments tracés.\n")
  invisible(x)
}