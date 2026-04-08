# SlitherlinkR : Package et Application Shiny pour le Jeu Slitherlink

[![R-CMD-check](https://img.shields.io/badge/Status-In--Development-orange.svg)](https://github.com/Modestedvlr/Slitherlink_R)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Présentation du Projet
Ce projet est réalisé dans le cadre de l'unité d'enseignement **Programmation R** du Master 1 Statistique et Science des Données (SSD) à l'Université de Montpellier.

L'objectif est de concevoir un package R complet permettant de :
1. **Générer** des grilles de Slitherlink de manière algorithmique.
2. **Résoudre** ces puzzles via des méthodes de programmation mathématique (ILP).
3. **Jouer** de manière interactive via une application Shiny sophistiquée.

**Auteurs :** [Moussa DIAGNE] & [Dossou AGOSSOU]  
**Date de rendu :** 17 Avril 2026

---

## Architecture du Package
Le projet suit scrupuleusement la structure standard d'un package R pour garantir la portabilité et la robustesse :

- `R/` : Contient les fonctions de calcul (moteur logique, solveur, générateurs).
- `inst/shiny-app/` : Code source de l'interface utilisateur interactive.
- `man/` : Documentation automatique des fonctions (via `roxygen2`).
- `tests/testthat/` : Suite de tests unitaires pour valider les règles du jeu.
- `vignettes/` : (Optionnel) Guide détaillé sur la modélisation mathématique utilisée.

---

## Modélisation Mathématique & Logique

### Théorie des Graphes
Le Slitherlink est modélisé comme un graphe non orienté  $G = (V, E)$. Chaque intersection de la grille est un sommet $v \in V$, et chaque segment possible est une arête $e \in E$.

### Le Solveur (Programmation Linéaire en Nombres Entiers - ILP)
Pour répondre à l'exigence de "sophistication", nous implémentons un solveur basé sur l'optimisation sous contraintes :

- **Variables de décision :** $x_{ij} \in \{0, 1\}$, où $1$ si le segment est tracé, $0$ sinon.

- **Contrainte de degré :** $\sum_{j \in \delta(i)} x_{ij} \in$ \{0, 2\}$ pour chaque sommet $i$.

- **Contrainte de face :** La somme des $x_{ij}$ bordant une case doit égaler l'indice $k \in \{0,1,2,3\}$.

.- **Élimination des sous-tours :** Algorithme itératif pour garantir l'unicité de la boucle (cycle hamiltonien partiel).

### Algorithme de Génération
La génération de niveaux repose sur un processus de **soustraction d'indices** à partir d'une boucle complète aléatoire, tout en garantissant l'unicité de la solution par appels successifs au solveur.

---

## Installation et Utilisation

Pour installer le package depuis GitHub et lancer l'application :

```r
# Installation des dépendances
install.packages(c("shiny", "ggplot2", "devtools", "testthat", "shinyjs", "ompr", "lpSolve"))

# Chargement du projet
devtools::load_all()

# Lancement de l'application
run_slitherlink()
```

---

## Plan de Développement (Roadmap)

Phase 1 : Définition de la structure de données S3/R6 pour la grille.

Phase 2 : Implémentation du moteur de vérification (boucle unique, connectivité).

Phase 3 : Développement du solveur ILP (Programmation Linéaire).

Phase 4 : Création de l'interface Shiny (Module UI/Server).

Phase 5 : Finalisation de la documentation et tests unitaires.

---

## Collaboration Git
Nous utilisons un workflow professionnel :

Branches : `feature/nom-tâche` pour chaque nouvelle fonctionnalité.

Pull Requests : Chaque ajout de code est relu par le binôme avant fusion sur la branche main.

Issues : Suivi des bugs et des tâches mathématiques.