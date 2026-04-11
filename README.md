# SlitherlinkR : Package et Application Shiny pour le Jeu Slitherlink

[![R-CMD-check](https://img.shields.io/badge/Status-In--Development-orange.svg)](https://github.com/Modestedvlr/Slitherlink_R)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Présentation du Projet

SlitherlinkR est un package R complet dédié au jeu de logique Slitherlink. Ce projet intègre une logique métier robuste, un solveur haute performance en C++ et une interface utilisateur interactive sous Shiny.

Réalisé dans le cadre de l'unité d'enseignement Programmation R à l'Université de Montpellier, ce package démontre l'intégration de plusieurs paradigmes de programmation.

**Auteurs :** [Moussa DIAGNE] & [Dossou AGOSSOU] 

**Date de rendu :** 17 Avril 2026

---

## Fonctionnalités Clés

**Interface Shiny Interactive :** Une application fluide permettant de jouer à la souris, avec détection automatique de la victoire.

**Solveur C++ Ultra-Rapide :** Implémentation d'un algorithme de backtracking récursif en C++ pour résoudre des grilles complexes en quelques millisecondes.

**Système de Leaderboard :** Persistance des scores (temps de résolution) via une base de données SQLite intégrée.

**Génération Algorithmique :** Création de nouvelles grilles garantissant une solution unique.

**Validation Rigoureuse :** Moteur de vérification des règles (contraintes de cases, boucle unique via DFS).

---

## Architecture Technique

### 1. Programmation Orientée Objet (S3) :

Le package définit une classe slitherlink structurée de manière efficiente :

- Stockage optimisé des arêtes (matrices d'entiers).

- Méthodes `plot()` basées sur `ggplot2` utilisant la grammaire des graphiques pour un rendu professionnel et clair.


### 2. Performance et C++ (Rcpp) :

Le cœur du solveur est déporté en C++ pour pallier les limitations de vitesse de R sur les algorithmes récursifs.

- **Backtracking avec Élidage :** Le solveur explore l'arbre des possibles et coupe les branches dès qu'une contrainte de Slitherlink est violée.

- **Interpénétrabilité :** Utilisation de RcppExports pour une communication transparente entre les données R et les pointeurs C++.


### Gestion des Données (SQL) :

Utilisation des packages `DBI` et `RSQLite` pour gérer un tableau d'honneur (Leaderboard) :

- Archivage des pseudos, temps et dates.

- Requêtes SQL pour l'affichage du Top 10 au sein de l'interface Shiny.


### 4. Qualité du Code :

- **Tests Unitaires :** Plus de 25 tests avec le framework testthat couvrant la logique de validation et le solveur.

- **Documentation :** Entièrement générée avec `roxygen2`.

---

## Installation

Vous pouvez installer la version de développement depuis GitHub :

```{r}
# Installation des dépendances nécessaires
install.packages(c("shiny", "ggplot2", "Rcpp", "RSQLite", "DBI", "dplyr", "testthat"))

# Chargement du package
devtools::load_all()

# Lancement du jeu
run_slitherlink()
```

---

## Structure du Dépôt

- `R/` : Logique métier (validateurs, gestion de grille, interface SQL).
- `src/` : Code source C++ (solver.cpp).
- `inst/shiny-app/` : Interface utilisateur et réactivité Shiny.
- `tests/`` : Suite de tests automatisés.

---

## Collaboration Git

Le projet a été mené en utilisant les bonnes pratiques de développement collaboratif :

- Utilisation systématique de branches pour les fonctionnalités

- Relecture de code croisée.

- Suivi des bugs via les Issues GitHub.


---

## Plan de Développement (Roadmap)

Phase 1 : Définition de la structure de données S3 pour la grille.

Phase 2 : Implémentation du moteur de vérification (boucle unique, connectivité).

Phase 3 : Développement du solveur C++ (Rcpp).

Phase 4 : Création de l'interface Shiny (Module UI/Server).

Phase 5 : Finalisation de la documentation et tests unitaires.

---
