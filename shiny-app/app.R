# =============================================================================
# APPLICATION SHINY — Slitherlink
# =============================================================================

library(shiny)
library(ggplot2)
library(SlitherlinkR)

# -----------------------------------------------------------------------------
# PUZZLES PRÉDÉFINIS (en attendant le générateur)
# -----------------------------------------------------------------------------
puzzles <- list(

  facile = list(
    name = "Facile (3x3)",
    grid = matrix(
      c(NA,  2, NA,
         2, NA,  2,
        NA,  2, NA),
      nrow = 3, byrow = TRUE
    )
  ),

  moyen = list(
    name = "Moyen (4x4)",
    grid = matrix(
      c(NA,  3,  2, NA,
         2, NA, NA,  2,
        NA, NA, NA,  1,
        NA,  2,  3, NA),
      nrow = 4, byrow = TRUE
    )
  ),

  difficile = list(
    name = "Difficile (5x5)",
    grid = matrix(
      c(NA,  3, NA,  2, NA,
         2, NA, NA, NA,  2,
        NA, NA,  2, NA, NA,
         1, NA, NA, NA,  3,
        NA,  2, NA,  3, NA),
      nrow = 5, byrow = TRUE
    )
  )
)

# -----------------------------------------------------------------------------
# UI
# -----------------------------------------------------------------------------
ui <- fluidPage(

  # --- Style général ---
  tags$head(tags$style(HTML("
    body { background-color: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
    .title-panel { background-color: #2c3e50; color: white;
                   padding: 15px 20px; border-radius: 8px; margin-bottom: 20px; }
    .btn-action { width: 100%; margin-bottom: 10px;
                  border-radius: 6px; font-weight: bold; }
    .feedback-box { padding: 12px; border-radius: 8px;
                    margin-top: 15px; font-size: 14px; }
    .feedback-ok  { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
    .feedback-err { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    .feedback-inf { background-color: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
    .sidebar-card { background: white; padding: 15px;
                    border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
  "))),

  # --- Titre ---
  div(class = "title-panel",
    h2("🔷 Slitherlink", style = "margin: 0;"),
    p("Tracez une boucle unique fermée respectant les contraintes.",
      style = "margin: 5px 0 0 0; opacity: 0.8; font-size: 13px;")
  ),

  fluidRow(

    # --- Panneau gauche : contrôles ---
    column(3,
      div(class = "sidebar-card",

        h4("🎮 Nouvelle Partie"),
        selectInput("puzzle_choice", "Choisir un puzzle :",
                    choices = list(
                      "Facile (3x3)"   = "facile",
                      "Moyen (4x4)"    = "moyen",
                      "Difficile (5x5)" = "difficile"
                    )),
        actionButton("btn_new",   "▶ Nouvelle Partie",
                     class = "btn btn-primary btn-action"),

        hr(),

        h4("⚙️ Actions"),
        actionButton("btn_check", "✔ Vérifier",
                     class = "btn btn-success btn-action"),
        actionButton("btn_solve", "💡 Résoudre",
                     class = "btn btn-warning btn-action"),
        actionButton("btn_reset", "↺ Réinitialiser",
                     class = "btn btn-secondary btn-action"),

        hr(),

        h4("📖 Règles"),
        tags$ul(
          tags$li("Tracez une boucle fermée unique."),
          tags$li("La boucle ne doit pas se croiser."),
          tags$li("Le chiffre indique combien de côtés de la case sont tracés."),
          tags$li("Clic gauche : tracer / barrer / effacer.")
        )
      )
    ),

    # --- Zone principale : grille ---
    column(9,
      div(style = "background: white; border-radius: 8px;
                   box-shadow: 0 2px 4px rgba(0,0,0,0.1); padding: 10px;",

        plotOutput("grid_plot",
                   click    = "grid_click",
                   width    = "100%",
                   height   = "550px"),

        # --- Zone de feedback ---
        uiOutput("feedback")
      )
    )
  )
)

# -----------------------------------------------------------------------------
# SERVER
# -----------------------------------------------------------------------------
server <- function(input, output, session) {

  # --- État réactif de la grille ---
  grid_state <- reactiveVal(new_slitherlink(puzzles$facile$grid))

  # Dimensions du plot en pixels (pour la détection du clic)
  PLOT_W <- 550
  PLOT_H <- 550

  # --- Message de feedback ---
  feedback_msg <- reactiveVal(
    list(type = "info", text = "Cliquez sur un segment pour le tracer.")
  )

  # ===========================================================================
  # NOUVELLE PARTIE
  # ===========================================================================
  observeEvent(input$btn_new, {
    choix <- input$puzzle_choice
    grid_state(new_slitherlink(puzzles[[choix]]$grid))
    feedback_msg(list(type = "info",
                      text = paste("Nouveau puzzle :", puzzles[[choix]]$name)))
  })

  # ===========================================================================
  # RÉINITIALISER
  # ===========================================================================
  observeEvent(input$btn_reset, {
    g <- grid_state()
    g$h_edges <- matrix(0L, nrow = g$n + 1, ncol = g$m)
    g$v_edges <- matrix(0L, nrow = g$n,     ncol = g$m + 1)
    grid_state(g)
    feedback_msg(list(type = "info", text = "Grille réinitialisée."))
  })

  # ===========================================================================
  # VÉRIFIER
  # ===========================================================================
  observeEvent(input$btn_check, {
    res <- validate_solution(grid_state())
    if (res$valid) {
      feedback_msg(list(type = "ok",
                        text = "🎉 Félicitations ! La solution est correcte !"))
    } else {
      feedback_msg(list(type = "err",
                        text = paste(res$messages, collapse = " | ")))
    }
  })

  # ===========================================================================
  # RÉSOUDRE (stub — en attente du vrai solveur C++)
  # ===========================================================================
  observeEvent(input$btn_solve, {
  feedback_msg(list(type = "info", text = "⏳ Résolution en cours..."))

  g <- grid_state()

  # Appel du solveur C++
  result <- solve_slitherlink_cpp(
    h_edges = g$h_edges,
    v_edges = g$v_edges,
    indices = g$indices
  )

  if (result$solved) {
    # Appliquer la solution à la grille
    g$h_edges <- result$h_edges
    g$v_edges <- result$v_edges
    grid_state(g)
    feedback_msg(list(type = "ok",
                      text = "💡 Solution trouvée et affichée !"))
  } else {
    feedback_msg(list(type = "err",
                      text = "❌ Aucune solution trouvée pour ce puzzle."))
  }
})

  # ===========================================================================
  # DÉTECTION DU CLIC SUR LA GRILLE
  # ===========================================================================
  observeEvent(input$grid_click, {
    g   <- grid_state()
    click <- input$grid_click

    # Coordonnées du clic dans l'espace du graphique ggplot2
    # ggplot2 avec coord_fixed() : x ∈ [0, m], y ∈ [0, n]
    cx <- click$x
    cy <- click$y

    if (is.null(cx) || is.null(cy)) return()

    # --- Tolérance de clic : 0.25 unité autour d'un segment ---
    tol <- 0.25

    clicked <- FALSE

    # --- Cherche un segment HORIZONTAL proche du clic ---
    # h_edges[r, c] relie (c-1, n-r+1) à (c, n-r+1)
    for (r in 1:(g$n + 1)) {
      for (c in 1:g$m) {
        seg_y  <- g$n - r + 1          # coordonnée Y du segment
        seg_x1 <- c - 1                 # début en X
        seg_x2 <- c                     # fin en X
        seg_xm <- (seg_x1 + seg_x2) / 2 # milieu

        if (abs(cy - seg_y)  < tol &&
            cx > seg_x1 - tol &&
            cx < seg_x2 + tol) {
          g <- toggle_h_edge(g, r, c)
          clicked <- TRUE
          break
        }
      }
      if (clicked) break
    }

    # --- Cherche un segment VERTICAL si aucun horizontal trouvé ---
    if (!clicked) {
      for (r in 1:g$n) {
        for (c in 1:(g$m + 1)) {
          seg_x  <- c - 1               # coordonnée X du segment
          seg_y1 <- g$n - r             # bas en Y
          seg_y2 <- g$n - r + 1         # haut en Y

          if (abs(cx - seg_x)  < tol &&
              cy > seg_y1 - tol &&
              cy < seg_y2 + tol) {
            g <- toggle_v_edge(g, r, c)
            clicked <- TRUE
            break
          }
        }
        if (clicked) break
      }
    }

    if (clicked) {
      grid_state(g)
      feedback_msg(list(type = "info",
                        text = "Cliquez sur un segment pour le tracer."))
    }
  })

  # ===========================================================================
  # RENDU DE LA GRILLE
  # ===========================================================================
  output$grid_plot <- renderPlot({
    plot_slitherlink(grid_state())
  }, bg = "white")

  # ===========================================================================
  # RENDU DU FEEDBACK
  # ===========================================================================
  output$feedback <- renderUI({
    msg <- feedback_msg()
    css_class <- switch(msg$type,
      "ok"   = "feedback-box feedback-ok",
      "err"  = "feedback-box feedback-err",
      "info" = "feedback-box feedback-inf"
    )
    div(class = css_class, msg$text)
  })
}

# -----------------------------------------------------------------------------
# LANCEMENT
# -----------------------------------------------------------------------------
shinyApp(ui = ui, server = server)