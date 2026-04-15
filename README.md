# Slitherlink

[![R-CMD-check](https://github.com/Modestedvlr/Slitherlink/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Modestedvlr/Slitherlink/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tests](https://img.shields.io/badge/tests-43%20passed-brightgreen)]()
[![R Version](https://img.shields.io/badge/R-%3E%3D4.1.0-blue)]()

## Presentation

Package R complet implementant le jeu logique **Slitherlink**, developpe dans le cadre du Master 1 Statistique et Science des Donnees (SSD) a l'Universite de Montpellier.

**Auteurs :** Moussa DIAGNE & Dossou AGOSSOU  
**Date de rendu :** 17 Avril 2026

---

## Le Jeu Slitherlink

Le Slitherlink est un casse-tete logique japonais. Le joueur doit tracer
une **unique boucle fermee** sur une grille de points en respectant les regles :

- La boucle doit etre **unique et fermee** (ni croisement, ni ramification)
- Chaque sommet a exactement **0 ou 2 segments**
- Le **chiffre** dans une case indique combien de ses 4 cotes appartiennent a la boucle

---

## Architecture du Package

```
SlitherlinkR/
├── R/
│   ├── grid_management.R   # Classe S3, constructeur, toggle
│   ├── grid_plot.R         # Visualisation ggplot2
│   ├── validator.R         # Moteur de verification (DFS)
│   ├── solver.R            # Solveur ILP (lpSolve)
│   ├── solver_interface.R  # Interface solveur
│   ├── generator.R         # Generateur de puzzles (unicite garantie)
│   ├── database.R          # Leaderboard SQLite
│   └── run_app.R           # Lancement application Shiny
├── src/
│   └── solver.cpp          # Solveur backtracking C++ (Rcpp)
├── shiny-app/
│   └── app.R               # Application Shiny interactive
├── tests/testthat/
│   ├── test-grid.R         # Tests structure et toggle (8 tests)
│   ├── test-validator.R    # Tests validateur (18 tests)
│   ├── test-generator.R    # Tests generateur (8 tests)
│   ├── test-solver.R       # Tests solveur ILP (5 tests)
│   └── test-database.R     # Tests SQLite (4 tests)
└── man/                    # Documentation roxygen2 (16 fichiers)
```

---

## Modelisation Mathematique

### Structure de donnees — Classe S3 `slitherlink`

```r
list(
  n       = 4L,                              # lignes de cases
  m       = 4L,                              # colonnes de cases
  indices = matrix(..., nrow=4, ncol=4),     # chiffres (0-3 ou NA)
  h_edges = matrix(0L, nrow=5, ncol=4),      # segments horizontaux
  v_edges = matrix(0L, nrow=4, ncol=5)       # segments verticaux
)
```

Les segments ont 3 etats : `0L` (absent), `1L` (trace), `2L` (barre impossible).

### Solveur ILP — Programmation Lineaire en Nombres Entiers

Le solveur principal utilise **lpSolve** avec :

- **Variables** : `x[e] ∈ {0,1}` pour chaque arete, `y[v] ∈ {0,1}` pour chaque sommet
- **Contrainte cases** : `Σ(4 aretes de la case) = chiffre`
- **Contrainte degre** : `Σ(aretes de v) = 2 × y[v]`
- **Elimination sous-tours** : algorithme iteratif BFS

**Performances mesurées :**

| Taille | Temps  | Resultat  |
|--------|--------|-----------|
| 3×3    | ~0.03s | Valide    |
| 4×4    | ~0.14s | Valide    |
| 5×5    | ~0.15s | Valide    |

### Generateur — Unicite Garantie

```
1. Partir d'une boucle valide connue
2. Masquer aleatoirement des cases (30/50/70% selon difficulte)
3. Verifier l'unicite : resoudre + interdire la solution + re-resoudre
4. Si une 2eme solution existe → recommencer (max 20 tentatives)
```

---

## Installation

```r
# Installer les dependances
install.packages(c(
  "shiny", "ggplot2", "dplyr", "magrittr",
  "Rcpp", "lpSolve", "DBI", "RSQLite", "testthat"
))

# Charger le package en developpement
devtools::load_all()

# Lancer l'application
run_slitherlink()
```

---

## Utilisation de l'API

```r
# Creer une grille
m <- matrix(c(2,1,1,2, 1,0,0,1, 1,0,0,1, 2,1,1,2), nrow=4, byrow=TRUE)
g <- new_slitherlink(m)

# Afficher la grille
plot_slitherlink(g)

# Tracer un segment (clic)
g <- toggle_h_edge(g, 1, 1)

# Valider la solution
validate_solution(g)

# Resoudre automatiquement (ILP)
g_solved <- solve_slitherlink(g)

# Generer un puzzle avec unicite garantie
h <- matrix(0L,5,4); v <- matrix(0L,4,5)
h[1,] <- 1L; h[5,] <- 1L; v[,1] <- 1L; v[,5] <- 1L
puzzle <- generate_puzzle(h, v, difficulty = "moyen")
```

---

## Application Shiny

L'application offre une experience de jeu complete :

- **3 niveaux** : Facile (3×3), Moyen (4×4), Difficile (5×5)
- **Puzzles uniques** : solution unique garantie mathematiquement
- **Timer** reactif mis a jour chaque seconde
- **Solveur ILP** integre (bouton Resoudre)
- **Leaderboard** SQLite persistant avec sauvegarde des scores
- **Design** premium theme sombre

---

## Tests

```r
devtools::test()
# [ FAIL 0 | WARN 0 | SKIP 0 | PASS 43 ]

devtools::check()
# 0 errors | 0 warnings | 0 notes
```

| Fichier          | Contexte                              | Tests  |
|------------------|---------------------------------------|--------|
| test-grid.R      | Structure S3, toggle, validation      | 8      |
| test-validator.R | check_cells, check_degree, check_loop | 18     |
| test-generator.R | generate_puzzle, unicite              | 8      |
| test-solver.R    | solve_slitherlink ILP                 | 5      |
| test-database.R  | init_db, save_score                   | 4      |
| **Total**        |                                       | **43** |

---

## Phases de Developpement

| Phases   | Contenus                              | Auteurs        |
|---------|----------------------------------------|----------------|
| Phase 1 | Structure S3, ggplot2, toggle          | Dossou AGOSSOU |
| Phase 2 | Validateur DFS, 26 tests               | Moussa DIAGNE  |
| Phase 3 | Solveur C++ Rcpp                       | Dossou AGOSSOU |
| Phase 4 | Solveur ILP, generateur, Shiny, SQLite | Moussa DIAGNE  |
| Phase 5 | Tests complets, documentation, unicite | Dossou AGOSSOU |

---

## Collaboration Git

- **Branches** : `dev` (Phase 1) / `dev2` (Phase 2, 3, 4 & 5)
- **Pull Requests** : chaque phase reviewee avant fusion sur `main`
- **Issues** : suivi des bugs et taches mathematiques
