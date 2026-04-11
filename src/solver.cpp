#include <Rcpp.h>
using namespace Rcpp;

// =============================================================================
// SOLVEUR SLITHERLINK — Backtracking C++
// =============================================================================

// Variables globales au solveur (réinitialisées à chaque appel)
static int N, M;
static IntegerMatrix H, V, IDX;
static bool solution_found;

// -----------------------------------------------------------------------------
// Vérifier si une case respecte son chiffre (élagage / pruning)
// Retourne false si la case est DÉJÀ violée (trop de segments)
// -----------------------------------------------------------------------------
bool check_cell(int i, int j) {
  if (IntegerVector::is_na(IDX(i, j))) return true;
  int target = IDX(i, j);
  int count  = (H(i, j) == 1) + (H(i+1, j) == 1) +
    (V(i, j) == 1) + (V(i, j+1) == 1);
  int absent = (H(i, j) == 0) + (H(i+1, j) == 0) +
    (V(i, j) == 0) + (V(i, j+1) == 0);
  // Si déjà trop de segments → invalide
  if (count > target) return false;
  // Si impossible d'atteindre le target → invalide
  if (count + absent < target) return false;
  return true;
}

// -----------------------------------------------------------------------------
// Vérifier le degré d'un sommet (0 ou 2 uniquement)
// -----------------------------------------------------------------------------
bool check_vertex(int r, int c) {
  int deg = 0;
  if (c < M  && H(r, c)   == 1) deg++;
  if (c > 0  && H(r, c-1) == 1) deg++;
  if (r < N  && V(r, c)   == 1) deg++;
  if (r > 0  && V(r-1, c) == 1) deg++;
  return deg == 0 || deg == 2;
}

// -----------------------------------------------------------------------------
// Vérifier toutes les cases et sommets affectés par l'arête (type, r, c)
// type=0 → horizontale, type=1 → verticale
// -----------------------------------------------------------------------------
bool check_affected(int type, int r, int c) {
  if (type == 0) {
    // Arête horizontale H(r,c) touche cases (r-1,c) et (r,c)
    if (r > 0 && !check_cell(r-1, c)) return false;
    if (r < N && !check_cell(r,   c)) return false;
    // Sommets (r,c) et (r,c+1)
    if (!check_vertex(r, c))   return false;
    if (!check_vertex(r, c+1)) return false;
  } else {
    // Arête verticale V(r,c) touche cases (r,c-1) et (r,c)
    if (c > 0 && !check_cell(r, c-1)) return false;
    if (c < M && !check_cell(r, c))   return false;
    // Sommets (r,c) et (r+1,c)
    if (!check_vertex(r,   c)) return false;
    if (!check_vertex(r+1, c)) return false;
  }
  return true;
}

// -----------------------------------------------------------------------------
// Vérifier la connectivité : une seule boucle fermée (DFS)
// -----------------------------------------------------------------------------
bool check_single_loop() {
  int NV = (N+1) * (M+1);
  std::vector<std::vector<int>> adj(NV);

  auto enc = [&](int r, int c){ return r * (M+1) + c; };

  int total = 0;
  for (int r = 0; r <= N; r++)
    for (int c = 0; c < M; c++)
      if (H(r,c) == 1) {
        adj[enc(r,c)].push_back(enc(r,c+1));
        adj[enc(r,c+1)].push_back(enc(r,c));
        total++;
      }
      for (int r = 0; r < N; r++)
        for (int c = 0; c <= M; c++)
          if (V(r,c) == 1) {
            adj[enc(r,c)].push_back(enc(r+1,c));
            adj[enc(r+1,c)].push_back(enc(r,c));
            total++;
          }

          if (total == 0) return false;

          // DFS
          std::vector<bool> visited(NV, false);
          int start = -1;
          for (int i = 0; i < NV; i++)
            if (!adj[i].empty()) { start = i; break; }

            std::vector<int> stack = {start};
            while (!stack.empty()) {
              int node = stack.back(); stack.pop_back();
              if (visited[node]) continue;
              visited[node] = true;
              for (int nb : adj[node])
                if (!visited[nb]) stack.push_back(nb);
            }

            for (int i = 0; i < NV; i++)
              if (!adj[i].empty() && !visited[i]) return false;

              return true;
}

// -----------------------------------------------------------------------------
// BACKTRACKING RÉCURSIF
// idx = index de l'arête courante (0 à total_edges-1)
// -----------------------------------------------------------------------------
struct Edge { int type, r, c; };

void backtrack(const std::vector<Edge>& edges, int idx) {
  if (solution_found) return;

// Toutes les arêtes assignées → vérifier la solution complète
  if (idx == (int)edges.size()) {
    // Vérifier toutes les cases
    for (int i = 0; i < N && !solution_found; i++)
      for (int j = 0; j < M && !solution_found; j++)
        if (!IntegerVector::is_na(IDX(i,j))) {
          int cnt = (H(i,j)==1)+(H(i+1,j)==1)+(V(i,j)==1)+(V(i,j+1)==1);
          if (cnt != IDX(i,j)) return;
        }
        // Vérifier boucle unique
        if (check_single_loop()) solution_found = true;
        return;
  }

  const Edge& e = edges[idx];

  // Essayer 0 puis 1
  for (int val : {0, 1}) {
    if (e.type == 0) H(e.r, e.c) = val;
    else             V(e.r, e.c) = val;

    if (check_affected(e.type, e.r, e.c)) {
      backtrack(edges, idx + 1);
    }

    if (solution_found) return;
  }

  // Restaurer
  if (e.type == 0) H(e.r, e.c) = 0;
  else             V(e.r, e.c) = 0;
}

// -----------------------------------------------------------------------------
//' Solveur Slitherlink Backtracking C++
//' @param h_edges Matrice segments horizontaux
//' @param v_edges Matrice segments verticaux
//' @param indices Matrice des chiffres contraintes
//' @export
// [[Rcpp::export]]
 List solve_slitherlink_cpp(IntegerMatrix h_edges,
                            IntegerMatrix v_edges,
                            IntegerMatrix indices) {
   N   = indices.nrow();
   M   = indices.ncol();
   H   = clone(h_edges);
   V   = clone(v_edges);
   IDX = indices;
   solution_found = false;

   // Construire la liste de toutes les arêtes
   std::vector<Edge> edges;
   for (int r = 0; r <= N; r++)
     for (int c = 0; c < M; c++)
       edges.push_back({0, r, c});   // horizontales
   for (int r = 0; r < N; r++)
     for (int c = 0; c <= M; c++)
       edges.push_back({1, r, c});   // verticales

   backtrack(edges, 0);

   return List::create(
     Named("h_edges") = H,
     Named("v_edges") = V,
     Named("solved")  = solution_found
   );
 }

//' Verifier la connexion Rcpp
//' @export
// [[Rcpp::export]]
 String check_cpp_connection() {
   return "Connexion Rcpp OK ! Le compilateur fonctionne parfaitement.";
 }
