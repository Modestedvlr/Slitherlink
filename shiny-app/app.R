# =============================================================================
# APPLICATION SHINY — Slitherlink
# =============================================================================

library(shiny)
library(ggplot2)
library(SlitherlinkR)

# -----------------------------------------------------------------------------
# FONCTION UTILITAIRE
# -----------------------------------------------------------------------------
indices_from_loop <- function(h, v) {
  n <- nrow(v); m <- nrow(h) - 1
  mat <- matrix(0L, nrow=n, ncol=m)
  for (r in 1:n)
    for (c in 1:m)
      mat[r,c] <- (h[r,c]==1L) + (h[r+1,c]==1L) +
                  (v[r,c]==1L) + (v[r,c+1]==1L)
  mat
}

# -----------------------------------------------------------------------------
# BOUCLES DE BASE
# -----------------------------------------------------------------------------
h3a <- matrix(0L,4,3); v3a <- matrix(0L,3,4)
h3a[1,] <- 1L; h3a[4,] <- 1L
v3a[,1] <- 1L; v3a[,4] <- 1L

h3b <- matrix(0L,4,3); v3b <- matrix(0L,3,4)
h3b[1,1] <- 1L; h3b[1,2] <- 1L
h3b[3,3] <- 1L
h3b[4,1] <- 1L; h3b[4,2] <- 1L; h3b[4,3] <- 1L
v3b[1,1] <- 1L; v3b[2,1] <- 1L; v3b[3,1] <- 1L
v3b[1,3] <- 1L; v3b[2,3] <- 1L
v3b[3,4] <- 1L

h3c <- matrix(0L,4,3); v3c <- matrix(0L,3,4)
h3c[1,1] <- 1L; h3c[1,2] <- 1L; h3c[1,3] <- 1L
h3c[2,3] <- 1L; h3c[3,3] <- 1L
h3c[4,1] <- 1L; h3c[4,2] <- 1L; h3c[4,3] <- 1L
v3c[1,1] <- 1L; v3c[2,1] <- 1L; v3c[3,1] <- 1L
v3c[1,4] <- 1L; v3c[2,3] <- 1L; v3c[3,4] <- 1L

h4a <- matrix(0L,5,4); v4a <- matrix(0L,4,5)
h4a[1,] <- 1L; h4a[5,] <- 1L
v4a[,1] <- 1L; v4a[,5] <- 1L

h4b <- matrix(0L,5,4); v4b <- matrix(0L,4,5)
h4b[1,1] <- 1L; h4b[1,2] <- 1L; h4b[1,3] <- 1L; h4b[1,4] <- 1L
h4b[3,3] <- 1L; h4b[3,4] <- 1L
h4b[5,1] <- 1L; h4b[5,2] <- 1L
v4b[1,1] <- 1L; v4b[2,1] <- 1L; v4b[3,1] <- 1L; v4b[4,1] <- 1L
v4b[1,5] <- 1L; v4b[2,5] <- 1L
v4b[3,3] <- 1L; v4b[4,3] <- 1L

h4c <- matrix(0L,5,4); v4c <- matrix(0L,4,5)
h4c[1,1] <- 1L; h4c[1,2] <- 1L; h4c[1,3] <- 1L; h4c[1,4] <- 1L
h4c[2,4] <- 1L; h4c[3,4] <- 1L
h4c[5,1] <- 1L; h4c[5,2] <- 1L; h4c[5,3] <- 1L; h4c[5,4] <- 1L
v4c[1,1] <- 1L; v4c[2,1] <- 1L; v4c[3,1] <- 1L; v4c[4,1] <- 1L
v4c[1,5] <- 1L; v4c[2,4] <- 1L
v4c[3,5] <- 1L; v4c[4,5] <- 1L

h5a <- matrix(0L,6,5); v5a <- matrix(0L,5,6)
h5a[1,] <- 1L; h5a[6,] <- 1L
v5a[,1] <- 1L; v5a[,6] <- 1L

h5b <- matrix(0L,6,5); v5b <- matrix(0L,5,6)
h5b[1,1] <- 1L; h5b[1,2] <- 1L; h5b[1,3] <- 1L
h5b[3,4] <- 1L; h5b[3,5] <- 1L
h5b[4,1] <- 1L; h5b[4,2] <- 1L
h5b[6,3] <- 1L; h5b[6,4] <- 1L; h5b[6,5] <- 1L
v5b[1,1] <- 1L; v5b[2,1] <- 1L; v5b[3,1] <- 1L
v5b[1,4] <- 1L; v5b[2,4] <- 1L
v5b[3,6] <- 1L; v5b[4,6] <- 1L; v5b[5,6] <- 1L
v5b[4,3] <- 1L; v5b[5,3] <- 1L

h5c <- matrix(0L,6,5); v5c <- matrix(0L,5,6)
h5c[1,1] <- 1L; h5c[1,2] <- 1L; h5c[1,3] <- 1L
h5c[1,4] <- 1L; h5c[1,5] <- 1L
h5c[2,5] <- 1L; h5c[3,5] <- 1L
h5c[6,1] <- 1L; h5c[6,2] <- 1L; h5c[6,3] <- 1L
h5c[6,4] <- 1L; h5c[6,5] <- 1L
v5c[1,1] <- 1L; v5c[2,1] <- 1L; v5c[3,1] <- 1L
v5c[4,1] <- 1L; v5c[5,1] <- 1L
v5c[1,6] <- 1L; v5c[2,5] <- 1L
v5c[3,6] <- 1L; v5c[4,6] <- 1L; v5c[5,6] <- 1L

base_loops <- list(
  facile    = list(list(h=h3a,v=v3a), list(h=h3b,v=v3b), list(h=h3c,v=v3c)),
  moyen     = list(list(h=h4a,v=v4a), list(h=h4b,v=v4b), list(h=h4c,v=v4c)),
  difficile = list(list(h=h5a,v=v5a), list(h=h5b,v=v5b), list(h=h5c,v=v5c))
)


# -----------------------------------------------------------------------------
# UI
# -----------------------------------------------------------------------------
ui <- fluidPage(

  tags$head(tags$style(HTML("
    body { background-color: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
    .title-panel { background-color: #2c3e50; color: white;
                   padding: 15px 20px; border-radius: 8px; margin-bottom: 20px; }
    .btn-action  { width: 100%; margin-bottom: 10px;
                   border-radius: 6px; font-weight: bold; }
    .feedback-box { padding: 12px; border-radius: 8px;
                    margin-top: 15px; font-size: 14px; }
    .feedback-ok  { background-color: #d4edda; color: #155724;
                    border: 1px solid #c3e6cb; }
    .feedback-err { background-color: #f8d7da; color: #721c24;
                    border: 1px solid #f5c6cb; }
    .feedback-inf { background-color: #d1ecf1; color: #0c5460;
                    border: 1px solid #bee5eb; }
    .sidebar-card { background: white; padding: 15px; border-radius: 8px;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .timer-display { font-size: 28px; font-weight: bold; color: #2c3e50;
                     text-align: center; padding: 10px; }
    .leaderboard-title { color: #2c3e50; font-weight: bold; margin-top: 10px; }
  "))),

  div(class = "title-panel",
    h2("🔷 Slitherlink", style = "margin: 0;"),
    p("Tracez une boucle unique fermée respectant les contraintes.",
      style = "margin: 5px 0 0 0; opacity: 0.8; font-size: 13px;")
  ),

  fluidRow(
    column(3,
      div(class = "sidebar-card",

        h4("🎮 Nouvelle Partie"),
        selectInput("puzzle_choice", "Niveau de difficulté :",
          choices = list(
            "Facile (3x3)"    = "facile",
            "Moyen (4x4)"     = "moyen",
            "Difficile (5x5)" = "difficile"
          )),
        actionButton("btn_new", "▶ Nouvelle Partie",
                     class = "btn btn-primary btn-action"),

        hr(),

        # Timer
        div(class = "timer-display",
          textOutput("timer_display")
        ),

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
          tags$li("Le chiffre = nombre de côtés tracés."),
          tags$li("Clic : tracer → barrer → effacer.")
        )
      )
    ),

    column(6,
      div(style = "background: white; border-radius: 8px;
                   box-shadow: 0 2px 4px rgba(0,0,0,0.1); padding: 10px;",
        plotOutput("grid_plot",
                   click  = "grid_click",
                   width  = "100%",
                   height = "500px"),
        uiOutput("feedback")
      )
    ),

    column(3,
      div(class = "sidebar-card",
        h4("🏆 Leaderboard", class = "leaderboard-title"),
        tableOutput("leaderboard_table"),
        hr(),
        h4("💾 Sauvegarder"),
        textInput("pseudo_input", "Votre pseudo :", placeholder = "Ex: Alice"),
        actionButton("btn_save", "Sauvegarder mon score",
                     class = "btn btn-info btn-action")
      )
    )
  )
)

# -----------------------------------------------------------------------------
# SERVER
# -----------------------------------------------------------------------------
server <- function(input, output, session) {
  
  # Initialiser DB au démarrage du server
  tryCatch(init_db(), error = function(e) NULL)

  # --- États réactifs ---
  init_puzzle    <- generate_puzzle(base_loops$facile[[1]]$h,
                                    base_loops$facile[[1]]$v,
                                    difficulty = "facile")
  current_puzzle <- reactiveVal(init_puzzle)
  grid_state     <- reactiveVal(new_slitherlink(init_puzzle$grid))
  feedback_msg   <- reactiveVal(
    list(type="info", text="Cliquez sur un segment pour le tracer.")
  )

  # Timer
  start_time  <- reactiveVal(Sys.time())
  timer_running <- reactiveVal(FALSE)
  elapsed_time  <- reactiveVal(0)

  # Mise à jour du timer chaque seconde
  observe({
    invalidateLater(1000, session)
    if (timer_running()) {
      elapsed_time(as.numeric(difftime(Sys.time(), start_time(), units="secs")))
    }
  })

  output$timer_display <- renderText({
    t <- elapsed_time()
    sprintf("⏱ %02d:%02d", floor(t/60), floor(t%%60))
  })

  # --- Nouvelle Partie ---
  observeEvent(input$btn_new, {
    choix  <- input$puzzle_choice
    loops  <- base_loops[[choix]]
    loop   <- loops[[sample(length(loops), 1)]]
    puzzle <- generate_puzzle(loop$h, loop$v, difficulty=choix)
    current_puzzle(puzzle)
    grid_state(new_slitherlink(puzzle$grid))

    # Démarrer le timer
    start_time(Sys.time())
    elapsed_time(0)
    timer_running(TRUE)

    feedback_msg(list(type="info",
      text=paste0("Nouveau puzzle ! Niveau : ",
        switch(choix,
          "facile"    = "Facile (3x3)",
          "moyen"     = "Moyen (4x4)",
          "difficile" = "Difficile (5x5)"
        ))))
  })

  # --- Réinitialiser ---
  observeEvent(input$btn_reset, {
    g <- grid_state()
    g$h_edges <- matrix(0L, nrow=g$n+1, ncol=g$m)
    g$v_edges <- matrix(0L, nrow=g$n,   ncol=g$m+1)
    grid_state(g)

    # Redémarrer le timer
    start_time(Sys.time())
    elapsed_time(0)
    timer_running(TRUE)

    feedback_msg(list(type="info", text="Grille réinitialisée."))
  })

  # --- Vérifier ---
  observeEvent(input$btn_check, {
    res <- validate_solution(grid_state())
    if (res$valid) {
      timer_running(FALSE)
      t <- elapsed_time()
      feedback_msg(list(type="ok",
        text=paste0("🎉 Félicitations ! Résolu en ",
                    sprintf("%02d:%02d", floor(t/60), floor(t%%60)),
                    " ! Sauvegardez votre score →")))
    } else {
      feedback_msg(list(type="err",
        text=paste(res$messages, collapse=" | ")))
    }
  })

  # --- Résoudre ---

  observeEvent(input$btn_solve, {
  g <- grid_state()
  feedback_msg(list(type="info", text="⏳ Solveur ILP en cours..."))

  g_solved <- tryCatch(
    solve_slitherlink(g),
    error = function(e) NULL
  )

  if (!is.null(g_solved)) {
    timer_running(FALSE)
    grid_state(g_solved)
    feedback_msg(list(type="ok",
      text="💡 Solution trouvée par le solveur ILP lpSolve !"))
  } else {
    feedback_msg(list(type="err",
      text="❌ Aucune solution trouvée pour ce puzzle."))
  }
})

  # --- Sauvegarder le score ---
  observeEvent(input$btn_save, {
    pseudo <- trimws(input$pseudo_input)
    if (nchar(pseudo) == 0) {
      feedback_msg(list(type="err", text="❌ Entrez un pseudo avant de sauvegarder."))
      return()
    }
    t     <- elapsed_time()
    choix <- input$puzzle_choice
    tryCatch({
      save_score(pseudo, round(t, 1), choix)
      feedback_msg(list(type="ok",
        text=paste0("✅ Score sauvegardé pour ", pseudo, " !")))
    }, error = function(e) {
      feedback_msg(list(type="err", text="❌ Erreur lors de la sauvegarde."))
    })
  })

  # --- Leaderboard ---
  output$leaderboard_table <- renderTable({
    input$btn_save  # Rafraîchir après sauvegarde
    input$btn_new
    tryCatch({
      con <- DBI::dbConnect(RSQLite::SQLite(), "leaderboard.db")
      df  <- DBI::dbGetQuery(con,
        "SELECT pseudo, temps, difficulte, date
         FROM scores
         ORDER BY temps ASC
         LIMIT 10")
      DBI::dbDisconnect(con)
      if (nrow(df) == 0) return(data.frame(Message="Pas encore de scores"))
      colnames(df) <- c("Joueur", "Temps(s)", "Niveau", "Date")
      df
    }, error = function(e) {
      data.frame(Message="Base non disponible")
    })
  })

  # --- Détection du clic ---
  observeEvent(input$grid_click, {
    g  <- grid_state()
    cx <- input$grid_click$x
    cy <- input$grid_click$y
    if (is.null(cx) || is.null(cy)) return()

    tol     <- 0.25
    clicked <- FALSE

    for (r in 1:(g$n+1)) {
      for (c in 1:g$m) {
        seg_y <- g$n - r + 1
        if (abs(cy - seg_y) < tol &&
            cx > (c-1) - tol && cx < c + tol) {
          g <- toggle_h_edge(g, r, c)
          clicked <- TRUE; break
        }
      }
      if (clicked) break
    }

    if (!clicked) {
      for (r in 1:g$n) {
        for (c in 1:(g$m+1)) {
          seg_x  <- c - 1
          seg_y1 <- g$n - r
          seg_y2 <- g$n - r + 1
          if (abs(cx - seg_x) < tol &&
              cy > seg_y1 - tol && cy < seg_y2 + tol) {
            g <- toggle_v_edge(g, r, c)
            clicked <- TRUE; break
          }
        }
        if (clicked) break
      }
    }

    if (clicked) {
      grid_state(g)
      feedback_msg(list(type="info",
        text="Cliquez sur un segment pour le tracer."))
    }
  })

  # --- Rendu grille ---
  output$grid_plot <- renderPlot({
    plot_slitherlink(grid_state())
  }, bg="white")

  # --- Rendu feedback ---
  output$feedback <- renderUI({
    msg <- feedback_msg()
    css <- switch(msg$type,
      "ok"   = "feedback-box feedback-ok",
      "err"  = "feedback-box feedback-err",
      "info" = "feedback-box feedback-inf"
    )
    div(class=css, msg$text)
  })
}

# -----------------------------------------------------------------------------
shinyApp(ui=ui, server=server)