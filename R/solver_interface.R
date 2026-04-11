#' Résoudre une grille Slitherlink
#'
#' @param grid Un objet de classe \code{slitherlink}.
#' @return Une liste contenant \code{success} (booléen) et \code{grid} (l'objet mis à jour).
#' @export
solve_game <- function(grid) {
  # Appel de la fonction C++ que vous venez de pusher
  res <- solve_slitherlink_cpp(grid$h_edges, grid$v_edges, grid$indices)

  if (res$success) {
    grid$h_edges <- res$h_edges
    grid$v_edges <- res$v_edges
  }

  return(list(success = res$success, grid = grid))
}
