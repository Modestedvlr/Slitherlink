# =============================================================================
# VALIDATEUR DE SOLUTION — Slitherlink
# =============================================================================


# -----------------------------------------------------------------------------
#' Vérifier les contraintes des cases (chiffres)
#'
#' Pour chaque case contenant un chiffre k, vérifie que exactement
#' k de ses 4 côtés sont tracés (état 1L).
#'
#' @param grid Un objet de classe \code{slitherlink}.
#' @return Une liste : \code{ok} (logical), \code{errors} (dataframe des cases en erreur).
#' @export
check_cells <- function(grid) {

  errors <- data.frame(row = integer(), col = integer(),
                       expected = integer(), found = integer())

  for (r in 1:grid$n) {
    for (c in 1:grid$m) {

      # On saute les cases sans contrainte (NA)
      if (is.na(grid$indices[r, c])) next

      expected <- grid$indices[r, c]

      # Les 4 côtés de la case (r, c) :
      top    <- grid$h_edges[r,     c]   # côté haut
      bottom <- grid$h_edges[r + 1, c]   # côté bas
      left   <- grid$v_edges[r,     c]   # côté gauche
      right  <- grid$v_edges[r,     c + 1] # côté droit

      # On compte uniquement les segments TRACÉS (état 1L)
      found <- sum(c(top, bottom, left, right) == 1L)

      if (found != expected) {
        errors <- rbind(errors, data.frame(
          row = r, col = c,
          expected = expected,
          found = found
        ))
      }
    }
  }

  list(ok = nrow(errors) == 0, errors = errors)
}


# -----------------------------------------------------------------------------
#' Vérifier le degré de chaque sommet
#'
#' À chaque point d'intersection, le nombre de segments tracés
#' doit être exactement 0 ou 2 (jamais 1 ni 3).
#'
#' @param grid Un objet de classe \code{slitherlink}.
#' @return Une liste : \code{ok} (logical), \code{errors} (dataframe des sommets en erreur).
#' @export
check_degree <- function(grid) {

  errors <- data.frame(row = integer(), col = integer(), degree = integer())

  # Les sommets sont les points d'intersection : (n+1) x (m+1) points
  for (r in 1:(grid$n + 1)) {
    for (c in 1:(grid$m + 1)) {

      degree <- 0L

      # Segment horizontal VERS LA DROITE depuis ce sommet
      # h_edges[r, c] existe si c <= m
      if (c <= grid$m) {
        degree <- degree + (grid$h_edges[r, c] == 1L)
      }

      # Segment horizontal VERS LA GAUCHE depuis ce sommet
      # h_edges[r, c-1] existe si c > 1
      if (c > 1) {
        degree <- degree + (grid$h_edges[r, c - 1] == 1L)
      }

      # Segment vertical VERS LE BAS depuis ce sommet
      # v_edges[r, c] existe si r <= n
      if (r <= grid$n) {
        degree <- degree + (grid$v_edges[r, c] == 1L)
      }

      # Segment vertical VERS LE HAUT depuis ce sommet
      # v_edges[r-1, c] existe si r > 1
      if (r > 1) {
        degree <- degree + (grid$v_edges[r - 1, c] == 1L)
      }

      # Degré valide : 0 ou 2 uniquement
      if (!(degree %in% c(0L, 2L))) {
        errors <- rbind(errors, data.frame(row = r, col = c, degree = degree))
      }
    }
  }

  list(ok = nrow(errors) == 0, errors = errors)
}


# -----------------------------------------------------------------------------
#' Vérifier que les segments tracés forment une seule boucle fermée
#'
#' Utilise un parcours en profondeur (DFS) sur le graphe des segments tracés.
#' Si tous les segments tracés appartiennent au même composant connexe,
#' c'est une boucle unique.
#'
#' @param grid Un objet de classe \code{slitherlink}.
#' @return Une liste : \code{ok} (logical), \code{message} (explication).
#' @export
check_loop <- function(grid) {

  # --- Construire la liste d'adjacence des sommets connectés par un segment tracé ---
  # Un sommet est identifié par (r, c) → on l'encode en entier : (r-1)*(m+1) + c
  encode <- function(r, c) (r - 1L) * (grid$m + 1L) + c

  n_vertices <- (grid$n + 1L) * (grid$m + 1L)
  adj <- vector("list", n_vertices)
  for (i in 1:n_vertices) adj[[i]] <- integer(0)

  total_edges <- 0L  # nombre total de segments tracés

  # Ajouter les arêtes horizontales tracées
  for (r in 1:(grid$n + 1)) {
    for (c in 1:grid$m) {
      if (grid$h_edges[r, c] == 1L) {
        u <- encode(r, c)
        v <- encode(r, c + 1)
        adj[[u]] <- c(adj[[u]], v)
        adj[[v]] <- c(adj[[v]], u)
        total_edges <- total_edges + 1L
      }
    }
  }

  # Ajouter les arêtes verticales tracées
  for (r in 1:grid$n) {
    for (c in 1:(grid$m + 1)) {
      if (grid$v_edges[r, c] == 1L) {
        u <- encode(r, c)
        v <- encode(r + 1, c)
        adj[[u]] <- c(adj[[u]], v)
        adj[[v]] <- c(adj[[v]], u)
        total_edges <- total_edges + 1L
      }
    }
  }

  # --- Cas trivial : aucun segment tracé ---
  if (total_edges == 0L) {
    return(list(ok = FALSE, message = "Aucun segment tracé."))
  }

  # --- DFS depuis le premier sommet ayant un segment ---
  start <- which(sapply(adj, length) > 0)[1]
  visited <- logical(n_vertices)
  stack <- start

  while (length(stack) > 0) {
    node <- stack[length(stack)]
    stack <- stack[-length(stack)]

    if (!visited[node]) {
      visited[node] <- TRUE
      stack <- c(stack, adj[[node]][!visited[adj[[node]]]])
    }
  }

  # Sommets qui participent à au moins un segment tracé
  active_vertices <- which(sapply(adj, length) > 0)
  all_connected <- all(visited[active_vertices])

  if (!all_connected) {
    return(list(ok = FALSE,
                message = "Plusieurs boucles distinctes détectées."))
  }

  list(ok = TRUE, message = "Boucle unique et fermée. ✓")
}


# -----------------------------------------------------------------------------
#' Valider une solution complète
#'
#' Vérifie les 3 contraintes : cases, degrés, boucle unique.
#'
#' @param grid Un objet de classe \code{slitherlink}.
#' @return Une liste avec \code{valid} (logical) et \code{messages} (character vector).
#' @export
validate_solution <- function(grid) {

  messages <- character(0)
  valid <- TRUE

  # --- 1. Contraintes des cases ---
  res_cells <- check_cells(grid)
  if (!res_cells$ok) {
    valid <- FALSE
    for (i in 1:nrow(res_cells$errors)) {
      e <- res_cells$errors[i, ]
      messages <- c(messages, sprintf(
        "Case (%d,%d) : attendu %d segment(s), trouvé %d.",
        e$row, e$col, e$expected, e$found
      ))
    }
  }

  # --- 2. Degrés des sommets ---
  res_deg <- check_degree(grid)
  if (!res_deg$ok) {
    valid <- FALSE
    messages <- c(messages, sprintf(
      "%d sommet(s) avec un degré invalide (ni 0 ni 2).",
      nrow(res_deg$errors)
    ))
  }

  # --- 3. Boucle unique ---
  res_loop <- check_loop(grid)
  if (!res_loop$ok) {
    valid <- FALSE
    messages <- c(messages, res_loop$message)
  }

  # --- Résultat final ---
  if (valid) {
    messages <- "Félicitations ! La solution est correcte. 🎉"
  }

  list(valid = valid, messages = messages)
}