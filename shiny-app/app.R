# =============================================================================
# APPLICATION SHINY — Slitherlink (Design Premium)
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
h3a[1,] <- 1L; h3a[4,] <- 1L; v3a[,1] <- 1L; v3a[,4] <- 1L

h3b <- matrix(0L,4,3); v3b <- matrix(0L,3,4)
h3b[1,1] <- 1L; h3b[1,2] <- 1L; h3b[3,3] <- 1L
h3b[4,1] <- 1L; h3b[4,2] <- 1L; h3b[4,3] <- 1L
v3b[1,1] <- 1L; v3b[2,1] <- 1L; v3b[3,1] <- 1L
v3b[1,3] <- 1L; v3b[2,3] <- 1L; v3b[3,4] <- 1L

h3c <- matrix(0L,4,3); v3c <- matrix(0L,3,4)
h3c[1,1] <- 1L; h3c[1,2] <- 1L; h3c[1,3] <- 1L
h3c[2,3] <- 1L; h3c[3,3] <- 1L
h3c[4,1] <- 1L; h3c[4,2] <- 1L; h3c[4,3] <- 1L
v3c[1,1] <- 1L; v3c[2,1] <- 1L; v3c[3,1] <- 1L
v3c[1,4] <- 1L; v3c[2,3] <- 1L; v3c[3,4] <- 1L

h4a <- matrix(0L,5,4); v4a <- matrix(0L,4,5)
h4a[1,] <- 1L; h4a[5,] <- 1L; v4a[,1] <- 1L; v4a[,5] <- 1L

h4b <- matrix(0L,5,4); v4b <- matrix(0L,4,5)
h4b[1,1] <- 1L; h4b[1,2] <- 1L; h4b[1,3] <- 1L; h4b[1,4] <- 1L
h4b[3,3] <- 1L; h4b[3,4] <- 1L; h4b[5,1] <- 1L; h4b[5,2] <- 1L
v4b[1,1] <- 1L; v4b[2,1] <- 1L; v4b[3,1] <- 1L; v4b[4,1] <- 1L
v4b[1,5] <- 1L; v4b[2,5] <- 1L; v4b[3,3] <- 1L; v4b[4,3] <- 1L

h4c <- matrix(0L,5,4); v4c <- matrix(0L,4,5)
h4c[1,1] <- 1L; h4c[1,2] <- 1L; h4c[1,3] <- 1L; h4c[1,4] <- 1L
h4c[2,4] <- 1L; h4c[3,4] <- 1L
h4c[5,1] <- 1L; h4c[5,2] <- 1L; h4c[5,3] <- 1L; h4c[5,4] <- 1L
v4c[1,1] <- 1L; v4c[2,1] <- 1L; v4c[3,1] <- 1L; v4c[4,1] <- 1L
v4c[1,5] <- 1L; v4c[2,4] <- 1L; v4c[3,5] <- 1L; v4c[4,5] <- 1L

h5a <- matrix(0L,6,5); v5a <- matrix(0L,5,6)
h5a[1,] <- 1L; h5a[6,] <- 1L; v5a[,1] <- 1L; v5a[,6] <- 1L

h5b <- matrix(0L,6,5); v5b <- matrix(0L,5,6)
h5b[1,1] <- 1L; h5b[1,2] <- 1L; h5b[1,3] <- 1L
h5b[3,4] <- 1L; h5b[3,5] <- 1L; h5b[4,1] <- 1L; h5b[4,2] <- 1L
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

# =============================================================================
# UI
# =============================================================================
ui <- fluidPage(

  tags$head(
    # Google Fonts
    tags$link(rel="preconnect", href="https://fonts.googleapis.com"),
    tags$link(rel="stylesheet",
      href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;600&display=swap"),

    tags$style(HTML("

      /* ===== RESET & BASE ===== */
      *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

      body {
        background-color: #0f1117;
        background-image:
          radial-gradient(ellipse at 20% 50%, rgba(99,102,241,0.08) 0%, transparent 50%),
          radial-gradient(ellipse at 80% 20%, rgba(20,184,166,0.06) 0%, transparent 50%);
        color: #e2e8f0;
        font-family: 'DM Sans', sans-serif;
        min-height: 100vh;
        padding: 0;
      }

      /* ===== SCROLLBAR ===== */
      ::-webkit-scrollbar { width: 6px; }
      ::-webkit-scrollbar-track { background: #1a1d2e; }
      ::-webkit-scrollbar-thumb { background: #6366f1; border-radius: 3px; }

      /* ===== HEADER ===== */
      .game-header {
        background: linear-gradient(135deg, #1a1d2e 0%, #16213e 100%);
        border-bottom: 1px solid rgba(99,102,241,0.3);
        padding: 16px 32px;
        display: flex;
        align-items: center;
        gap: 16px;
        position: sticky;
        top: 0;
        z-index: 100;
        backdrop-filter: blur(10px);
      }

      .game-logo {
        font-family: 'Space Mono', monospace;
        font-size: 22px;
        font-weight: 700;
        background: linear-gradient(135deg, #6366f1, #14b8a6);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        letter-spacing: -0.5px;
      }

      .game-subtitle {
        font-size: 12px;
        color: #64748b;
        font-weight: 300;
        letter-spacing: 0.05em;
      }

      .header-badge {
        margin-left: auto;
        background: rgba(99,102,241,0.15);
        border: 1px solid rgba(99,102,241,0.3);
        color: #a5b4fc;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 11px;
        font-family: 'Space Mono', monospace;
        letter-spacing: 0.1em;
      }

      /* ===== MAIN LAYOUT ===== */
      .game-container {
        display: grid;
        grid-template-columns: 260px 1fr 280px;
        gap: 20px;
        padding: 20px 24px;
        max-width: 1400px;
        margin: 0 auto;
      }

      /* ===== PANELS ===== */
      .panel {
        background: linear-gradient(145deg, #1a1d2e, #16213e);
        border: 1px solid rgba(99,102,241,0.15);
        border-radius: 16px;
        padding: 20px;
        position: relative;
        overflow: hidden;
      }

      .panel::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 2px;
        background: linear-gradient(90deg, #6366f1, #14b8a6, transparent);
      }

      .panel-title {
        font-family: 'Space Mono', monospace;
        font-size: 11px;
        font-weight: 700;
        color: #6366f1;
        letter-spacing: 0.15em;
        text-transform: uppercase;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
      }

      .panel-title::after {
        content: '';
        flex: 1;
        height: 1px;
        background: rgba(99,102,241,0.2);
      }

      /* ===== LEVEL SELECT ===== */
      .level-select label {
        font-size: 11px;
        color: #64748b;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        margin-bottom: 6px;
        display: block;
      }

      .level-select select,
      .level-select .selectize-input {
        background: rgba(15,17,23,0.8) !important;
        border: 1px solid rgba(99,102,241,0.3) !important;
        border-radius: 10px !important;
        color: #e2e8f0 !important;
        font-family: 'DM Sans', sans-serif !important;
        padding: 10px 14px !important;
        font-size: 14px !important;
        box-shadow: none !important;
        transition: border-color 0.2s !important;
        width: 100% !important;
      }

      .level-select .selectize-input:focus,
      .level-select .selectize-input.focus {
        border-color: #6366f1 !important;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.15) !important;
      }

      .selectize-dropdown {
        background: #1a1d2e !important;
        border: 1px solid rgba(99,102,241,0.3) !important;
        border-radius: 10px !important;
      }

      .selectize-dropdown .option {
        color: #e2e8f0 !important;
        padding: 10px 14px !important;
      }

      .selectize-dropdown .option:hover,
      .selectize-dropdown .option.active {
        background: rgba(99,102,241,0.2) !important;
      }

      /* ===== BUTTONS ===== */
      .btn-game {
        width: 100%;
        padding: 11px 16px;
        border: none;
        border-radius: 10px;
        font-family: 'DM Sans', sans-serif;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        letter-spacing: 0.02em;
        margin-bottom: 8px;
        position: relative;
        overflow: hidden;
      }

      .btn-game::after {
        content: '';
        position: absolute;
        inset: 0;
        background: linear-gradient(rgba(255,255,255,0.1), transparent);
        opacity: 0;
        transition: opacity 0.2s;
      }

      .btn-game:hover::after { opacity: 1; }
      .btn-game:active { transform: scale(0.98); }

      .btn-primary {
        background: linear-gradient(135deg, #6366f1, #818cf8);
        color: white;
        box-shadow: 0 4px 15px rgba(99,102,241,0.3);
      }

      .btn-primary:hover {
        box-shadow: 0 6px 20px rgba(99,102,241,0.5);
        transform: translateY(-1px);
      }

      .btn-success {
        background: linear-gradient(135deg, #059669, #10b981);
        color: white;
        box-shadow: 0 4px 15px rgba(16,185,129,0.25);
      }

      .btn-success:hover { box-shadow: 0 6px 20px rgba(16,185,129,0.4); }

      .btn-warning {
        background: linear-gradient(135deg, #d97706, #f59e0b);
        color: white;
        box-shadow: 0 4px 15px rgba(245,158,11,0.25);
      }

      .btn-warning:hover { box-shadow: 0 6px 20px rgba(245,158,11,0.4); }

      .btn-ghost {
        background: rgba(255,255,255,0.05);
        border: 1px solid rgba(255,255,255,0.1) !important;
        color: #94a3b8;
      }

      .btn-ghost:hover {
        background: rgba(255,255,255,0.08);
        color: #e2e8f0;
      }

      .btn-danger {
        background: rgba(239,68,68,0.15);
        border: 1px solid rgba(239,68,68,0.3) !important;
        color: #f87171;
        font-size: 12px;
        padding: 8px 14px;
      }

      .btn-danger:hover {
        background: rgba(239,68,68,0.25);
        color: #fca5a5;
      }

      /* Curseur personnalisé sur la grille */
      .board-wrapper { 
        cursor: pointer; 
      }
      #grid_plot { 
        cursor: pointer; 
      }

      /* ===== TIMER ===== */
      .timer-wrapper {
        text-align: center;
        padding: 16px 0;
        border-top: 1px solid rgba(99,102,241,0.1);
        border-bottom: 1px solid rgba(99,102,241,0.1);
        margin: 16px 0;
      }

      .timer-label {
        font-size: 10px;
        color: #475569;
        letter-spacing: 0.15em;
        text-transform: uppercase;
        margin-bottom: 6px;
      }

      .timer-value {
        font-family: 'Space Mono', monospace;
        font-size: 36px;
        font-weight: 700;
        background: linear-gradient(135deg, #e2e8f0, #94a3b8);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        line-height: 1;
      }

      .timer-value.running {
        background: linear-gradient(135deg, #6366f1, #14b8a6);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
      }

      /* ===== RULES ===== */
      .rules-list {
        list-style: none;
        padding: 0;
      }

      .rules-list li {
        font-size: 12px;
        color: #64748b;
        padding: 5px 0;
        padding-left: 16px;
        position: relative;
        line-height: 1.5;
      }

      .rules-list li::before {
        content: '▸';
        position: absolute;
        left: 0;
        color: #6366f1;
        font-size: 10px;
        top: 6px;
      }

      /* ===== GAME BOARD ===== */
      .board-panel {
        background: linear-gradient(145deg, #1a1d2e, #0f1117);
        border: 1px solid rgba(99,102,241,0.2);
        border-radius: 16px;
        padding: 16px;
        position: relative;
      }

      .board-panel::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 2px;
        background: linear-gradient(90deg, transparent, #6366f1, #14b8a6, transparent);
      }

      .board-wrapper {
        background: #0a0c14;
        border-radius: 12px;
        border: 1px solid rgba(99,102,241,0.1);
        overflow: hidden;
      }

      /* ===== FEEDBACK ===== */
      .feedback-box {
        margin-top: 12px;
        padding: 12px 16px;
        border-radius: 10px;
        font-size: 13px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 10px;
        animation: slideUp 0.3s ease;
      }

      @keyframes slideUp {
        from { opacity: 0; transform: translateY(8px); }
        to   { opacity: 1; transform: translateY(0); }
      }

      .feedback-ok {
        background: rgba(16,185,129,0.1);
        border: 1px solid rgba(16,185,129,0.3);
        color: #34d399;
      }

      .feedback-err {
        background: rgba(239,68,68,0.1);
        border: 1px solid rgba(239,68,68,0.3);
        color: #f87171;
      }

      .feedback-inf {
        background: rgba(99,102,241,0.1);
        border: 1px solid rgba(99,102,241,0.2);
        color: #a5b4fc;
      }

      /* ===== LEADERBOARD ===== */
      .leaderboard-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 16px;
      }

      .leaderboard-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 12px;
      }

      .leaderboard-table th {
        color: #475569;
        font-weight: 600;
        text-transform: uppercase;
        font-size: 10px;
        letter-spacing: 0.08em;
        padding: 0 6px 8px;
        border-bottom: 1px solid rgba(99,102,241,0.15);
        text-align: left;
      }

      .leaderboard-table td {
        padding: 8px 6px;
        color: #94a3b8;
        border-bottom: 1px solid rgba(255,255,255,0.03);
      }

      .leaderboard-table tr:first-child td { color: #fbbf24; }
      .leaderboard-table tr:nth-child(2) td { color: #cbd5e1; }
      .leaderboard-table tr:nth-child(3) td { color: #cd7c2f; }

      .leaderboard-table tr:hover td {
        background: rgba(99,102,241,0.05);
      }

      .rank-badge {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 20px;
        height: 20px;
        border-radius: 50%;
        font-family: 'Space Mono', monospace;
        font-size: 10px;
        font-weight: 700;
      }

      /* ===== SAVE FORM ===== */
      .save-section {
        border-top: 1px solid rgba(99,102,241,0.1);
        padding-top: 16px;
        margin-top: 16px;
      }

      .save-label {
        font-size: 11px;
        color: #475569;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        margin-bottom: 8px;
        display: block;
      }

      .save-input input {
        background: rgba(15,17,23,0.8) !important;
        border: 1px solid rgba(99,102,241,0.25) !important;
        border-radius: 10px !important;
        color: #e2e8f0 !important;
        font-family: 'DM Sans', sans-serif !important;
        padding: 10px 14px !important;
        font-size: 13px !important;
        width: 100% !important;
        box-shadow: none !important;
        outline: none !important;
        transition: border-color 0.2s !important;
        margin-bottom: 8px;
      }

      .save-input input:focus {
        border-color: #6366f1 !important;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.15) !important;
      }

      .save-input input::placeholder { color: #334155 !important; }

      /* ===== DIFFICULTY BADGES ===== */
      .diff-facile    { color: #34d399; }
      .diff-moyen     { color: #fbbf24; }
      .diff-difficile { color: #f87171; }

      /* ===== SECTION DIVIDER ===== */
      .section-divider {
        height: 1px;
        background: rgba(99,102,241,0.1);
        margin: 16px 0;
      }

      /* ===== SHINY OVERRIDES ===== */
      .container-fluid { padding: 0 !important; }
      .row { margin: 0 !important; }
      .col-sm-3, .col-sm-6, .col-sm-9 { padding: 0 !important; }

      /* Table from renderTable */
      #leaderboard_table table {
        width: 100%;
        border-collapse: collapse;
        font-size: 12px;
      }

      #leaderboard_table thead tr th {
        color: #475569;
        font-weight: 600;
        text-transform: uppercase;
        font-size: 10px;
        letter-spacing: 0.08em;
        padding: 0 6px 8px;
        border-bottom: 1px solid rgba(99,102,241,0.15);
        text-align: left;
        background: transparent;
      }

      #leaderboard_table tbody tr td {
        padding: 8px 6px;
        color: #94a3b8;
        border-bottom: 1px solid rgba(255,255,255,0.03);
        background: transparent;
      }

      #leaderboard_table tbody tr:first-child td { color: #fbbf24; font-weight: 600; }
      #leaderboard_table tbody tr:nth-child(2) td { color: #cbd5e1; }
      #leaderboard_table tbody tr:nth-child(3) td { color: #cd7c2f; }
      #leaderboard_table tbody tr:hover td { background: rgba(99,102,241,0.05); }
    "))
  ),

  # ── HEADER ──────────────────────────────────────────────────
  tags$div(class="game-header",
    tags$div(
      tags$div(class="game-logo", "◈ SLITHERLINK"),
      tags$div(class="game-subtitle", "Tracez une boucle unique fermée")
    ),
    tags$div(class="header-badge", "R PACKAGE v0.1")
  ),

  # ── MAIN LAYOUT ─────────────────────────────────────────────
  tags$div(class="game-container",

    # ── COLONNE GAUCHE : Contrôles ──────────────────────────
    tags$div(class="panel",

      # Nouvelle partie
      tags$div(class="panel-title", "◈ Nouvelle Partie"),
      tags$div(class="level-select",
        selectInput("puzzle_choice", "Niveau de difficulté",
          choices = list(
            "⬡  Facile  — 3×3" = "facile",
            "⬡  Moyen   — 4×4" = "moyen",
            "⬡  Difficile — 5×5" = "difficile"
          ), width = "100%")
      ),
      tags$button(id="btn_new", class="btn btn-game btn-primary",
        onclick="Shiny.setInputValue('btn_new', Math.random())",
        "▶  Nouvelle Partie"),

      # Timer
      tags$div(class="timer-wrapper",
        tags$div(class="timer-label", "Temps écoulé"),
        tags$div(class="timer-value", id="timer_display_styled",
          textOutput("timer_display", inline=TRUE))
      ),

      # Actions
      tags$div(class="panel-title", "⚙ Actions"),
      tags$button(id="btn_check", class="btn btn-game btn-success",
        onclick="Shiny.setInputValue('btn_check', Math.random())",
        "✔  Vérifier"),
      tags$button(id="btn_solve", class="btn btn-game btn-warning",
        onclick="Shiny.setInputValue('btn_solve', Math.random())",
        "◈  Résoudre"),
      tags$button(id="btn_reset", class="btn btn-game btn-ghost",
        onclick="Shiny.setInputValue('btn_reset', Math.random())",
        "↺  Réinitialiser"),

      # Règles
      tags$div(class="section-divider"),
      tags$div(class="panel-title", "📖 Règles"),
      tags$ul(class="rules-list",
        tags$li("Tracez une seule boucle fermée"),
        tags$li("La boucle ne se croise pas"),
        tags$li("Chiffre = nombre de côtés tracés"),
        tags$li("Clic : tracer → barrer → effacer")
      )
    ),

    # ── COLONNE CENTRE : Grille ─────────────────────────────
    tags$div(class="board-panel",
      tags$div(class="board-wrapper",
        plotOutput("grid_plot",
                   click  = "grid_click",
                   width  = "100%",
                   height = "560px")
      ),
      uiOutput("feedback")
    ),

    # ── COLONNE DROITE : Leaderboard ────────────────────────
    tags$div(class="panel",

      # Header leaderboard avec bouton reset
      tags$div(class="leaderboard-header",
        tags$div(class="panel-title", style="margin-bottom:0",
          "🏆 Classement"),
        tags$button(id="btn_reset_lb", class="btn btn-game btn-danger",
          style="width:auto; margin:0; padding:6px 12px; font-size:11px;",
          onclick="Shiny.setInputValue('btn_reset_lb', Math.random())",
          "🗑 Effacer")
      ),

      tableOutput("leaderboard_table"),

      # Sauvegarder
      tags$div(class="save-section",
        tags$div(class="panel-title", "💾 Sauvegarder"),
        tags$div(class="save-input",
          textInput("pseudo_input", NULL,
                    placeholder="Votre pseudo...",
                    width="100%")
        ),
        tags$button(id="btn_save", class="btn btn-game btn-primary",
          onclick="Shiny.setInputValue('btn_save', Math.random())",
          "Sauvegarder mon score")
      )
    )
  )
)

# =============================================================================
# SERVER
# =============================================================================
server <- function(input, output, session) {

  tryCatch(init_db(), error = function(e) NULL)

  init_puzzle    <- generate_puzzle(base_loops$facile[[1]]$h,
                                    base_loops$facile[[1]]$v,
                                    difficulty="facile")
  current_puzzle <- reactiveVal(init_puzzle)
  grid_state     <- reactiveVal(new_slitherlink(init_puzzle$grid))
  feedback_msg   <- reactiveVal(
    list(type="info", text="◈ Cliquez sur un segment pour tracer la boucle.")
  )

  start_time    <- reactiveVal(Sys.time())
  timer_running <- reactiveVal(FALSE)
  elapsed_time  <- reactiveVal(0)

  observe({
    invalidateLater(1000, session)
    if (timer_running())
      elapsed_time(as.numeric(difftime(Sys.time(), start_time(), units="secs")))
  })

  output$timer_display <- renderText({
    t <- elapsed_time()
    sprintf("%02d:%02d", floor(t/60), floor(t%%60))
  })

  # --- Nouvelle Partie ---
  observeEvent(input$btn_new, {
    choix  <- input$puzzle_choice
    loops  <- base_loops[[choix]]
    loop   <- loops[[sample(length(loops), 1)]]
    puzzle <- generate_puzzle(loop$h, loop$v, difficulty=choix)
    current_puzzle(puzzle)
    grid_state(new_slitherlink(puzzle$grid))
    start_time(Sys.time()); elapsed_time(0); timer_running(TRUE)
    feedback_msg(list(type="info",
      text=paste0("◈ Nouveau puzzle — ",
        switch(choix, facile="Facile 3×3", moyen="Moyen 4×4",
               difficile="Difficile 5×5"))))
  })

  # --- Réinitialiser grille ---
  observeEvent(input$btn_reset, {
    g <- grid_state()
    g$h_edges <- matrix(0L, nrow=g$n+1, ncol=g$m)
    g$v_edges <- matrix(0L, nrow=g$n,   ncol=g$m+1)
    grid_state(g)
    start_time(Sys.time()); elapsed_time(0); timer_running(TRUE)
    feedback_msg(list(type="info", text="↺ Grille réinitialisée."))
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
        text=paste0("✗ ", paste(res$messages, collapse=" · "))))
    }
  })

  # --- Résoudre ---
  observeEvent(input$btn_solve, {
    timer_running(FALSE)
    g_solved <- tryCatch(solve_slitherlink(grid_state()), error=function(e) NULL)
    if (!is.null(g_solved)) {
      grid_state(g_solved)
      feedback_msg(list(type="ok", text="◈ Solution trouvée par le solveur ILP."))
    } else {
      feedback_msg(list(type="err", text="✗ Aucune solution trouvée."))
    }
  })

  # --- Reset Leaderboard ---
  observeEvent(input$btn_reset_lb, {
    tryCatch({
      con <- DBI::dbConnect(RSQLite::SQLite(), "leaderboard.db")
      DBI::dbExecute(con, "DELETE FROM scores")
      DBI::dbDisconnect(con)
      feedback_msg(list(type="info", text="🗑 Leaderboard effacé."))
    }, error=function(e) NULL)
  })

  # --- Sauvegarder ---
  observeEvent(input$btn_save, {
    pseudo <- trimws(input$pseudo_input)
    if (nchar(pseudo) == 0) {
      feedback_msg(list(type="err", text="✗ Entrez un pseudo avant de sauvegarder."))
      return()
    }
    tryCatch({
      save_score(pseudo, round(elapsed_time(), 1), input$puzzle_choice)
      feedback_msg(list(type="ok",
        text=paste0("✔ Score sauvegardé pour ", pseudo, " !")))
    }, error=function(e) {
      feedback_msg(list(type="err", text="✗ Erreur lors de la sauvegarde."))
    })
  })

  # --- Leaderboard ---
  output$leaderboard_table <- renderTable({
    input$btn_save; input$btn_new; input$btn_reset_lb
    tryCatch({
      con <- DBI::dbConnect(RSQLite::SQLite(), "leaderboard.db")
      df  <- DBI::dbGetQuery(con,
        "SELECT pseudo, temps, difficulte, date FROM scores
         ORDER BY temps ASC LIMIT 8")
      DBI::dbDisconnect(con)
      if (nrow(df) == 0) return(data.frame(Message="Pas encore de scores"))
      names(df) <- c("Joueur", "Temps(s)", "Niveau", "Date")
      df
    }, error=function(e) data.frame(Message="—"))
  }, striped=FALSE, hover=TRUE, bordered=FALSE,
     spacing="s", align="l", width="100%")

  # --- Clic grille ---
  observeEvent(input$grid_click, {
    g  <- grid_state()
    cx <- input$grid_click$x; cy <- input$grid_click$y
    if (is.null(cx) || is.null(cy)) return()
    tol <- 0.25; clicked <- FALSE

    for (r in 1:(g$n+1)) {
      for (c in 1:g$m) {
        if (abs(cy-(g$n-r+1)) < tol &&
            cx > (c-1)-tol && cx < c+tol) {
          g <- toggle_h_edge(g,r,c); clicked <- TRUE; break
        }
      }; if (clicked) break
    }
    if (!clicked) {
      for (r in 1:g$n) {
        for (c in 1:(g$m+1)) {
          if (abs(cx-(c-1)) < tol &&
              cy > (g$n-r)-tol && cy < (g$n-r+1)+tol) {
            g <- toggle_v_edge(g,r,c); clicked <- TRUE; break
          }
        }; if (clicked) break
      }
    }
    if (clicked) {
      grid_state(g)
      feedback_msg(list(type="info",
        text="◈ Cliquez sur un segment pour tracer la boucle."))
    }
  })

  # --- Rendu grille ---
  output$grid_plot <- renderPlot({
    plot_slitherlink(grid_state()) +
      ggplot2::theme(
        plot.background  = ggplot2::element_rect(fill="#0a0c14", color=NA),
        panel.background = ggplot2::element_rect(fill="#0a0c14", color=NA)
      )
  }, bg="#0a0c14")

  # --- Feedback ---
  output$feedback <- renderUI({
    msg <- feedback_msg()
    css <- switch(msg$type,
      "ok"   = "feedback-box feedback-ok",
      "err"  = "feedback-box feedback-err",
      "info" = "feedback-box feedback-inf")
    tags$div(class=css, msg$text)
  })
}

shinyApp(ui=ui, server=server)