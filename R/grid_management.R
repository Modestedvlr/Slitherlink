#' Création d'une structure Slitherlink rigoureuse
#'
#' @param indices Une matrice d'entiers (0-3 ou NA) représentant les contraintes.
#' @return Un objet de classe \code{slitherlink}.
#' @export
new_slitherlink <- function(indices) {
  if (!is.matrix(indices)) {
    stop("L'argument 'indices' doit etre une matrice.")
  }

  # Vérification des valeurs : uniquement 0, 1, 2, 3 ou NA
  valeurs_valides <- all(is.na(indices) | (indices %in% 0:3))
  if (!valeurs_valides) {
    stop("Les valeurs de 'indices' doivent etre 0, 1, 2, 3 ou NA.")
  }

  n <- nrow(indices)
  m <- ncol(indices)

  res <- list(
    n       = as.integer(n),
    m       = as.integer(m),
    indices = indices,
    h_edges = matrix(0L, nrow = n + 1, ncol = m),
    v_edges = matrix(0L, nrow = n,     ncol = m + 1)
  )

  class(res) <- "slitherlink"
  return(res)
}


#' Basculer l'état d'un segment horizontal
#'
#' @param grid Un objet de classe \code{slitherlink}.
#' @param r    Indice de ligne   (1 à n+1).
#' @param c    Indice de colonne (1 à m).
#' @return La grille modifiée.
#' @export
toggle_h_edge <- function(grid, r, c) {

  # --- Validation des coordonnées ---
  if (!is.numeric(r) || !is.numeric(c)) {
    stop("Les coordonnees r et c doivent etre numeriques.")
  }
  if (r < 1 || r > grid$n + 1) {
    stop(sprintf(
      "Ligne r=%d invalide pour h_edges : doit etre entre 1 et %d.",
      r, grid$n + 1
    ))
  }
  if (c < 1 || c > grid$m) {
    stop(sprintf(
      "Colonne c=%d invalide pour h_edges : doit etre entre 1 et %d.",
      c, grid$m
    ))
  }

  # --- Bascule : 0 → 1 → 2 → 0 ---
  grid$h_edges[r, c] <- (grid$h_edges[r, c] + 1L) %% 3L
  return(grid)
}


#' Basculer l'état d'un segment vertical
#'
#' @param grid Un objet de classe \code{slitherlink}.
#' @param r    Indice de ligne   (1 à n).
#' @param c    Indice de colonne (1 à m+1).
#' @return La grille modifiée.
#' @export
toggle_v_edge <- function(grid, r, c) {

  # --- Validation des coordonnées ---
  if (!is.numeric(r) || !is.numeric(c)) {
    stop("Les coordonnees r et c doivent etre numeriques.")
  }
  if (r < 1 || r > grid$n) {
    stop(sprintf(
      "Ligne r=%d invalide pour v_edges : doit etre entre 1 et %d.",
      r, grid$n
    ))
  }
  if (c < 1 || c > grid$m + 1) {
    stop(sprintf(
      "Colonne c=%d invalide pour v_edges : doit etre entre 1 et %d.",
      c, grid$m + 1
    ))
  }

  # --- Bascule : 0 → 1 → 2 → 0 ---
  grid$v_edges[r, c] <- (grid$v_edges[r, c] + 1L) %% 3L
  return(grid)
}


#' @export
print.slitherlink <- function(x, ...) {
  cat("Jeu Slitherlink (Grille ", x$n, "x", x$m, ")\n", sep = "")
  cat("Segments traces : ",
      sum(x$h_edges == 1L) + sum(x$v_edges == 1L), "\n")
  cat("Segments barres : ",
      sum(x$h_edges == 2L) + sum(x$v_edges == 2L), "\n")
  invisible(x)
}
