# Slitherlink

[![R-CMD-check](https://github.com/Modestedvlr/Slitherlink/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Modestedvlr/Slitherlink/actions/workflows/R-CMD-check.yaml)
[![Shiny App](https://img.shields.io/badge/Shiny-Live_Demo-blue?logo=rstudio&style=for-the-badge)](https://dossou-moussa-m1-ssd.shinyapps.io/shiny-app/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tests](https://img.shields.io/badge/tests-43%20passed-brightgreen)]()
[![R Version](https://img.shields.io/badge/R-%3E%3D4.1.0-blue)]()

## Présentation

**Slitherlink** est un package R complet implémentant le jeu logique japonais **Slitherlink**. Ce projet a été développé dans le cadre de l'unité d'enseignement Programmation R du Master 1 Statistique et Science des Données (SSD) à l'Université de Montpellier.

**Auteurs :** Moussa DIAGNE & Dossou AGOSSOU  
**Date de rendu :** 17 Avril 2026

---

## Jouer en ligne

Une version interactive du jeu est disponible sans installation à cette adresse :

**[Démo Live - SlitherlinkR](https://dossou-moussa-m1-ssd.shinyapps.io/shiny-app/)**

---

## Installation

Vous pouvez installer la version de développement de SlitherlinkR directement depuis GitHub :

```r
# Installer remotes si nécessaire
if (!requireNamespace("remotes")) install.packages("remotes")

# Installer le package SlitherlinkR
remotes::install_github("Modestedvlr/Slitherlink")

# Lancer l'application
library(SlitherlinkR)
run_slitherlink()
```

---

## Le Jeu Slitherlink

Le Slitherlink est un casse-tete logique japonais. Le joueur doit tracer
une **unique boucle fermée** sur une grille de points en respectant les règles :

- La boucle doit être **unique et fermée** (ni croisement, ni ramification)
- Chaque point (sommet) de la boucle doit être connecté à exactement **0 ou 2 segments**
- Les **chiffres** dans les cases indiquent combien de ses quatre côtés appartiennent à la boucle. Les cases vides n'ont aucune contrainte.


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

## Modélisation et Algorithmes

### Structure de données — Classe S3 `slitherlink`
La grille est gérée par un objet S3 contenant les dimensions, les chiffres imposés et deux matrices d'états pour les segments horizontaux et verticaux (0 : absent, 1 : tracé, 2 : marqué d'une croix).

### Double Solveur : ILP & Backtracking
Le package intègre deux moteurs de résolution :
- **ILP (lpSolve)** : Résolution par programmation linéaire en nombres entiers (utilisé pour la garantie d'unicité).
- **C++ (Rcpp)** : Un solveur par backtracking récursif pour une performance maximale lors de l'exécution en temps réel.

### Générateur avec Unicité Garantie
Le générateur garantit qu'un puzzle n'a qu'une seule et unique solution possible. Il utilise une boucle connue, masque des cases selon la difficulté, et vérifie mathématiquement (via le solveur ILP) qu'aucune autre solution ne peut exister avant de proposer le puzzle au joueur.

---

## Tests et Qualité

Le package respecte les standards de développement R avec une couverture de tests complète.

```r
devtools::test()
# [ FAIL 0 | WARN 0 | SKIP 0 | PASS 43 ]

devtools::check()
# 0 errors | 0 warnings | 0 notes
```

| Fichier          | Périmètre de test                              | Nb Tests |
|------------------|------------------------------------------------|----------|
| test-grid.R      | Structure S3, toggle segments, erreurs limites | 8        |
| test-validator.R | Vérification des cases, sommets et boucle unique | 18       |
| test-generator.R | Génération de puzzle et vérification d'unicité | 8        |
| test-solver.R    | Résolution complète par ILP                    | 5        |
| test-database.R  | Création base de données et stockage scores    | 4        |

---

## Phases de Développement

| Phases   | Contenus                              | Auteurs        |
|---------|----------------------------------------|----------------|
| Phase 1 | Structure S3, ggplot2, toggle          | Dossou AGOSSOU |
| Phase 2 | Validateur DFS, 26 tests               | Moussa DIAGNE  |
| Phase 3 | Solveur C++ Rcpp                       | Dossou AGOSSOU |
| Phase 4 | Solveur ILP, generateur, Shiny, SQLite | Moussa DIAGNE  |
| Phase 5 | Tests complets, documentation, unicite | Dossou AGOSSOU |

---

## Collaboration Git

Le projet a suivi un flux de travail rigoureux :
- **Développement par phases** : Chaque fonctionnalité majeure a fait l'objet d'une phase dédiée (voir rapport technique).
- **Intégration Continue (CI)** : GitHub Actions lance `R CMD check` à chaque push pour garantir la stabilité du code.
- **Merge Requests** : Fusion systématique sur la branche `main` après validation des tests.

---
