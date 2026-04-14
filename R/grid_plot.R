#' Visualisation de la grille Slitherlink
#'
#' @param grid Un objet de classe \code{slitherlink}
#' @import ggplot2
#' @importFrom dplyr mutate filter bind_rows
#' @export
plot_slitherlink <- function(grid) {

  # 1. Points
  df_points <- expand.grid(x = 0:grid$m, y = 0:grid$n)

  # 2. Chiffres (Indices)
  df_indices <- as.data.frame(as.table(grid$indices))
  colnames(df_indices) <- c("row", "col", "val")
  df_indices <- df_indices %>%
    dplyr::mutate(
      row = as.numeric(row),
      col = as.numeric(col),
      x = col - 0.5,
      y = grid$n - row + 0.5
    ) %>%
    dplyr::filter(!is.na(val))

  # 3. Segments
  h_segs <- as.data.frame(which(grid$h_edges >= 0L, arr.ind = TRUE))
  colnames(h_segs) <- c("row", "col")
  h_segs <- h_segs %>%
    dplyr::mutate(
      x = col - 1, xend = col,
      y = grid$n - row + 1, yend = y,
      status = factor(grid$h_edges[cbind(row, col)])
    )

  v_segs <- as.data.frame(which(grid$v_edges >= 0L, arr.ind = TRUE))
  colnames(v_segs) <- c("row", "col")
  v_segs <- v_segs %>%
    dplyr::mutate(
      x = col - 1, xend = x,
      y = grid$n - row + 1, yend = grid$n - row,
      status = factor(grid$v_edges[cbind(row, col)])
    )

  df_edges <- dplyr::bind_rows(h_segs, v_segs)

  # 4. ggplot2 construction
  edge_colors <- c("0" = "#1e2540",   # absent → bleu très sombre (presque invisible)
                 "1" = "#6366f1",   # tracé  → violet lumineux
                 "2" = "#ef4444")   # barré  → rouge vif
edge_sizes  <- c("0" = 0.8,
                 "1" = 2.5,
                 "2" = 1.0)

  ggplot2::ggplot() +
    ggplot2::geom_segment(data = df_edges,
                          ggplot2::aes(x = x, y = y, xend = xend, yend = yend,
                                       color = status, size = status)) +
    ggplot2::geom_point(data = df_points, ggplot2::aes(x = x, y = y),
                    color = "#3d4a6b", size = 1.5) +
    ggplot2::geom_text(data = df_indices, ggplot2::aes(x = x, y = y, label = val),
                   size = 6, color = "#94a3b8", fontface = "bold",
                   family = "mono") +
    ggplot2::scale_color_manual(values = edge_colors, guide = "none") +
    ggplot2::scale_size_manual(values = edge_sizes, guide = "none") +
    ggplot2::coord_fixed() +
    ggplot2::theme_void()
}
