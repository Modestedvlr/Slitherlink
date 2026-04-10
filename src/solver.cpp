#include <Rcpp.h>
using namespace Rcpp;

// Fonction utilitaire interne (non exportée vers R)
// On utilise // au lieu de //' pour éviter l'erreur Roxygen
// Cette fonction vérifie si une case (i, j) respecte son chiffre
bool is_cell_satisfied(int i, int j, IntegerMatrix h_edges, IntegerMatrix v_edges, IntegerMatrix indices) {
  int target = indices(i, j);

  // Utilisation de la méthode statique pour vérifier les NA
  if (IntegerVector::is_na(target)) return true;

  int count = 0;
  // Rappel : indexation C++ commence à 0
  if (h_edges(i, j) == 1) count++;     // Haut
  if (h_edges(i + 1, j) == 1) count++; // Bas
  if (v_edges(i, j) == 1) count++;     // Gauche
  if (v_edges(i, j + 1) == 1) count++; // Droite

  return count == target;
}

//' Solveur Slitherlink (Squelette de Phase 3)
//' @param h_edges Matrice segments horizontaux
//' @param v_edges Matrice segments verticaux
//' @param indices Matrice des chiffres contraintes
//' @export
// [[Rcpp::export]]
List solve_slitherlink_cpp(IntegerMatrix h_edges, IntegerMatrix v_edges, IntegerMatrix indices) {
  int n = indices.nrow();
  int m = indices.ncol();

  // Test sur la première case pour vérifier que tout communique bien
  bool first_check = is_cell_satisfied(0, 0, h_edges, v_edges, indices);

  Rcout << "Moteur C++ : Analyse d'une grille " << n << "x" << m << std::endl;
  Rcout << "Verification case (0,0) : " << (first_check ? "OK" : "Non valide") << std::endl;

  return List::create(
    Named("h_edges") = h_edges,
    Named("v_edges") = v_edges,
    Named("solved") = false
  );
}

//' Verifier la connexion Rcpp
//' @export
// [[Rcpp::export]]
String check_cpp_connection() {
  return "Connexion Rcpp OK ! Le compilateur fonctionne parfaitement.";
}
