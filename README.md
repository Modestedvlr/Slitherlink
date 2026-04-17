# SlitherlinkR

[![R-CMD-check](https://github.com/Modestedvlr/Slitherlink/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Modestedvlr/Slitherlink/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tests](https://img.shields.io/badge/tests-51%20passed-brightgreen)]()
[![R Version](https://img.shields.io/badge/R-%3E%3D4.1.0-blue)]()
[![shinyapps.io](https://img.shields.io/badge/demo-shinyapps.io-blue)](https://dossou-moussa-m1-ssd.shinyapps.io/shiny-app/)

---

## Presentation

Package R complet implementant le jeu logique **Slitherlink**, developpe dans le cadre du Master 1 Statistique et Science des Donnees de l'Universite de Montpellier.

**Auteurs :** Moussa DIAGNE & Dossou AGOSSOU  
**Date de rendu :** 17 Avril 2026  
**Application en ligne :** https://dossou-moussa-m1-ssd.shinyapps.io/shiny-app/

---

## Le Jeu Slitherlink

Le Slitherlink est un casse-tete logique japonais. Le joueur doit tracer une **unique boucle fermee** sur une grille de points en respectant les regles :

- La boucle doit etre **unique et fermee** (ni croisement, ni ramification)
- Chaque sommet a exactement **0 ou 2 segments**
- Le **chiffre** dans une case indique combien de ses 4 cotes appartiennent a la boucle
- Les cases **sans chiffre (NA)** n'ont aucune contrainte

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

# Lancer l'application Shiny
run_slitherlink()
```

---

## Architecture du Package

```
SlitherlinkR/
├── R/
│   ├── grid_management.R   # Classe S3, constructeur, toggle (0->1->2->0)
│   ├── grid_plot.R         # Visualisation ggplot2 (linewidth >= 3.4.0)
│   ├── validator.R         # check_cells, check_degree, check_loop (DFS)
│   ├── solver.R            # Solveur ILP (lpSolve) + elimination sous-tours
│   ├── solver_interface.R  # solve_puzzle()
│   ├── generator.R         # indices_from_loop, is_unique_solution, generate_puzzle
│   ├── database.R          # init_db, save_score (SQLite)
│   └── run_app.R           # run_slitherlink()
├── src/
│   └── solver.cpp          # Solveur backtracking C++ (Rcpp)
├── shiny-app/
│   └── app.R               # Application Shiny complete
├── tests/testthat/
│   ├── test-grid.R         # 8 tests  - Structure S3, toggle
│   ├── test-validator.R    # 18 tests - check_cells, check_degree, check_loop
│   ├── test-generator.R    # 8 tests  - generate_puzzle, unicite
│   ├── test-solver.R       # 5 tests  - solve_slitherlink ILP
│   └── test-database.R     # 4 tests  - init_db, save_score
├── man/                    # 18 fichiers de documentation roxygen2
├── .github/workflows/      # GitHub Actions CI/CD
└── DESCRIPTION             # Date: 2026-04-17
```

---

## Modelisation Mathematique

### Representation en theorie des graphes

Le Slitherlink est modelise comme un graphe G = (V, E) ou :
- **V** : les (n+1) x (m+1) points d'intersection d'une grille n x m
- **E** : tous les segments possibles entre deux points voisins
- **x[e] in {0,1}** : 1 si l'arete est tracee, 0 sinon
- **y[v] in {0,1}** : 1 si le sommet est actif

### Classe S3 `slitherlink`

```r
list(
  n       = 4L,
  m       = 4L,
  indices = matrix(...),              # chiffres 0-3 ou NA
  h_edges = matrix(0L, nrow=5, ncol=4),   # segments horizontaux
  v_edges = matrix(0L, nrow=4, ncol=5)    # segments verticaux
)
# Etats : 0L = absent | 1L = trace (violet) | 2L = barre (rouge)
```

### Solveur ILP (lpSolve)

```
Variables  : x[e] in {0,1} pour chaque arete
             y[v] in {0,1} pour chaque sommet

Contrainte cases  : sum(4 aretes de la case) = chiffre_k
Contrainte degre  : sum(aretes de v) = 2 * y[v]
Elimination tours : sum(aretes du sous-tour) <= |sous-tour| - 1

Resolution : iterative jusqu'a obtenir une seule boucle connexe
```

**Performances :**

| Taille | Temps moyen | Valide |
|--------|-------------|--------|
| 3 x 3  | ~0.03s      | Oui    |
| 4 x 4  | ~0.14s      | Oui    |
| 5 x 5  | ~0.15s      | Oui    |

### Unicite garantie - `is_unique_solution()`

```
1. Resoudre le puzzle une premiere fois (ILP)
2. Interdire cette solution : sum(aretes_sol1) <= |sol1| - 1
3. Tenter de resoudre a nouveau
4. Si infaisable -> solution unique confirmee
5. Sinon -> recommencer (max 20 tentatives)
```

- Grilles **3x3 et 4x4** : unicite garantie mathematiquement via ILP
- Grilles **5x5** : masquage direct garanti (verification trop couteuse)

---

## Utilisation de l'API

```r
# Creer une grille
m <- matrix(c(2,1,1,2, 1,0,0,1, 1,0,0,1, 2,1,1,2), nrow=4, byrow=TRUE)
g <- new_slitherlink(m)

# Visualiser
plot_slitherlink(g)

# Tracer un segment (cycle : absent -> trace -> barre -> absent)
g <- toggle_h_edge(g, 1, 1)
g <- toggle_v_edge(g, 1, 1)

# Valider la solution
validate_solution(g)   # list(valid, messages)

# Resoudre automatiquement (ILP)
g_solved <- solve_slitherlink(g)

# Generer un puzzle avec unicite garantie
h <- matrix(0L,5,4); v <- matrix(0L,4,5)
h[1,] <- 1L; h[5,] <- 1L; v[,1] <- 1L; v[,5] <- 1L
puzzle <- generate_puzzle(h, v, difficulty = "moyen")
# puzzle$grid     -> indices avec NA
# puzzle$solution -> h_edges et v_edges de la solution
```

---

## Application Shiny

L'application est accessible en ligne et offre une experience de jeu complete :

| Fonctionnalite | Description |
|----------------|-------------|
| 3 niveaux | Facile (3x3) / Moyen (4x4) / Difficile (5x5) |
| 24 puzzles | 8 formes differentes par niveau |
| Unicite | Solution unique garantie (3x3, 4x4) |
| Timer | Mise a jour chaque seconde |
| Solveur | Bouton Resoudre via ILP (instantane) |
| Leaderboard | SQLite persistant, top 8 par temps, reset |
| Design | Theme sombre premium (Space Mono + DM Sans) |
| Segments | 3 etats : trace (violet) / barre (rouge) / absent |

```r
# Lancer localement
run_slitherlink()

# Application en ligne
# https://dossou-moussa-m1-ssd.shinyapps.io/shiny-app/
```

---

## Tests et Qualite

```r
devtools::test()
# [ FAIL 0 | WARN 0 | SKIP 0 | PASS 51 ]

devtools::check()
# 0 errors | 0 warnings | 0 notes
```

| Fichier | Contexte teste | Tests |
|---------|----------------|-------|
| test-grid.R | Structure S3, toggle, coordonnees invalides | 8 |
| test-validator.R | check_cells, check_degree, check_loop, validate | 18 |
| test-generator.R | generate_puzzle, unicite, dimensions | 8 |
| test-solver.R | solve_slitherlink ILP 3x3 et 4x4, puzzle impossible | 5 |
| test-database.R | init_db, save_score, colonnes table | 4 |
| **Total** | | **51** |

---

## Dependances

| Package | Role |
|---------|------|
| ggplot2, dplyr, magrittr | Visualisation et manipulation des donnees |
| shiny | Application web interactive |
| Rcpp | Integration C++ (solveur backtracking) |
| lpSolve | Solveur ILP (programmation lineaire entiere) |
| DBI, RSQLite | Base de donnees leaderboard persistant |
| testthat | Tests unitaires automatises |
| rsconnect | Deploiement sur shinyapps.io |

---

## Phases de Developpement

| Phase | Contenu | Auteur |
|-------|---------|--------|
| Phase 1 | Structure S3, ggplot2, toggle des segments | Moussa DIAGNE |
| Phase 2 | Validateur DFS, 26 tests unitaires | Dossou AGOSSOU |
| Phase 3 | Solveur C++ Rcpp backtracking | Moussa DIAGNE |
| Phase 4 | Solveur ILP, generateur, Shiny, SQLite | Dossou AGOSSOU |
| Phase 5 | Tests complets, documentation roxygen2, CI/CD | Moussa DIAGNE |
| Phase 6 | Unicite garantie, 8 boucles/niveau, deploiement | Dossou AGOSSOU |

---

## Workflow Git

```
main   <- branche stable (production)
  |
  +-- dev   : Phase 1 initiale (Moussa DIAGNE)
  +-- dev2  : Developpement complet (Phases 2 a 6)

Merge final : dev2 -> main avant soumission
```

---

## CI/CD GitHub Actions

Le workflow `.github/workflows/R-CMD-check.yaml` se declenche a chaque push sur `main` ou `dev2` :

- Environnement : Windows Latest + R 4.4.0
- Etapes : checkout, setup-r, setup-r-dependencies, check-r-package
- Variable : `_R_CHECK_SYSTEM_CLOCK_=0`
- Resultat : badge dynamique sur le README

---

## Licence

MIT - voir le fichier [LICENSE](LICENSE).
