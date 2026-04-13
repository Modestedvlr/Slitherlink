#' Résoudre un puzzle Slitherlink
#'
#' Tente de résoudre via le solveur C++.
#' Si échec, retourne NULL.
#'
#' @param grid Un objet de classe \code{slitherlink}
#' @param solution Liste avec h_edges et v_edges (solution pré-calculée)
#' @return La grille résolue ou NULL
#' @export
solve_puzzle <- function(grid, solution = NULL) {

  # Solution pré-calculée disponible → l'appliquer directement
  if (!is.null(solution)) {
    grid$h_edges <- solution$h_edges
    grid$v_edges <- solution$v_edges
    return(grid)
  }

  # Tentative via solveur C++
  tryCatch({
    res <- solve_slitherlink_cpp(grid$h_edges, grid$v_edges, grid$indices)
    if (isTRUE(res$solved)) {
      grid$h_edges <- res$h_edges
      grid$v_edges <- res$v_edges
      return(grid)
    }
    return(NULL)
  }, error = function(e) {
    return(NULL)
  })
}