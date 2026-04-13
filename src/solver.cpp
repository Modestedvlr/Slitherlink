#include <Rcpp.h>
#include <vector>
#include <algorithm>
using namespace Rcpp;

// =============================================================================
// SOLVEUR SLITHERLINK OPTIMISÉ — Backtracking + Propagation de contraintes
// =============================================================================

static int N, M;
static IntegerMatrix H, V, IDX;
static bool solution_found;

// Encodage sommet (r,c) → entier
inline int enc(int r, int c) { return r * (M + 1) + c; }

// -----------------------------------------------------------------------------
// Compter les segments tracés / libres autour d'une case
// -----------------------------------------------------------------------------
inline int cell_count(int i, int j) {
  return (H(i,j)==1) + (H(i+1,j)==1) +
         (V(i,j)==1) + (V(i,j+1)==1);
}
inline int cell_free(int i, int j) {
  return (H(i,j)==0) + (H(i+1,j)==0) +
         (V(i,j)==0) + (V(i,j+1)==0);
}

// -----------------------------------------------------------------------------
// Compter le degré d'un sommet
// -----------------------------------------------------------------------------
inline int vertex_deg(int r, int c) {
  int d = 0;
  if (c < M  && H(r,c)   == 1) d++;
  if (c > 0  && H(r,c-1) == 1) d++;
  if (r < N  && V(r,c)   == 1) d++;
  if (r > 0  && V(r-1,c) == 1) d++;
  return d;
}
inline int vertex_free(int r, int c) {
  int f = 0;
  if (c < M  && H(r,c)   == 0) f++;
  if (c > 0  && H(r,c-1) == 0) f++;
  if (r < N  && V(r,c)   == 0) f++;
  if (r > 0  && V(r-1,c) == 0) f++;
  return f;
}

// -----------------------------------------------------------------------------
// Vérification partielle (pendant la recherche)
// -----------------------------------------------------------------------------
bool check_cell_partial(int i, int j) {
  int target = IDX(i,j);
  if (target == NA_INTEGER) return true;
  int cnt  = cell_count(i,j);
  int free = cell_free(i,j);
  return cnt <= target && cnt + free >= target;
}

bool check_vertex_partial(int r, int c) {
  int deg  = vertex_deg(r,c);
  int free = vertex_free(r,c);
  if (deg > 2) return false;
  // Si deg==1 et plus aucun segment libre → impasse
  if (deg == 1 && free == 0) return false;
  return true;
}

// -----------------------------------------------------------------------------
// Vérification stricte (solution finale)
// -----------------------------------------------------------------------------
bool check_cell_strict(int i, int j) {
  int target = IDX(i,j);
  if (target == NA_INTEGER) return true;
  return cell_count(i,j) == target;
}

bool check_vertex_strict(int r, int c) {
  int d = vertex_deg(r,c);
  return d == 0 || d == 2;
}

// -----------------------------------------------------------------------------
// Vérifier les cases et sommets affectés par une arête
// -----------------------------------------------------------------------------
bool check_affected(int type, int r, int c) {
  if (type == 0) { // horizontale H(r,c)
    if (r > 0 && !check_cell_partial(r-1,c)) return false;
    if (r < N && !check_cell_partial(r,  c)) return false;
    if (!check_vertex_partial(r,c))   return false;
    if (!check_vertex_partial(r,c+1)) return false;
  } else { // verticale V(r,c)
    if (c > 0 && !check_cell_partial(r,c-1)) return false;
    if (c < M && !check_cell_partial(r,c))   return false;
    if (!check_vertex_partial(r,  c)) return false;
    if (!check_vertex_partial(r+1,c)) return false;
  }
  return true;
}

// -----------------------------------------------------------------------------
// PROPAGATION DE CONTRAINTES
// Force les arêtes obligatoires (must=1) ou impossibles (must=0)
// Retourne false si contradiction détectée
// -----------------------------------------------------------------------------
struct Edge { int type, r, c; };

// Récupérer les arêtes libres d'une case
std::vector<Edge> cell_free_edges(int i, int j) {
  std::vector<Edge> res;
  if (H(i,j)   == 0) res.push_back({0, i,   j});
  if (H(i+1,j) == 0) res.push_back({0, i+1, j});
  if (V(i,j)   == 0) res.push_back({1, i,   j});
  if (V(i,j+1) == 0) res.push_back({1, i,   j+1});
  return res;
}

// Récupérer les arêtes libres d'un sommet
std::vector<Edge> vertex_free_edges(int r, int c) {
  std::vector<Edge> res;
  if (c < M  && H(r,c)   == 0) res.push_back({0, r,   c});
  if (c > 0  && H(r,c-1) == 0) res.push_back({0, r,   c-1});
  if (r < N  && V(r,c)   == 0) res.push_back({1, r,   c});
  if (r > 0  && V(r-1,c) == 0) res.push_back({1, r-1, c});
  return res;
}

inline void set_edge(const Edge& e, int val) {
  if (e.type == 0) H(e.r, e.c) = val;
  else             V(e.r, e.c) = val;
}

// Propagation : retourne la liste des arêtes modifiées (pour annulation)
// ou vecteur vide si contradiction
bool propagate(std::vector<std::pair<Edge,int>>& changed) {
  bool progress = true;
  while (progress) {
    progress = false;

    // --- Contraintes des cases ---
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < M; j++) {
        int target = IDX(i,j);
        if (target == NA_INTEGER) continue;

        int cnt  = cell_count(i,j);
        int free = cell_free(i,j);

        if (cnt > target)          return false;
        if (cnt + free < target)   return false;

        // Tous les libres doivent être tracés
        if (cnt < target && free == target - cnt) {
          auto fe = cell_free_edges(i,j);
          for (auto& e : fe) {
            changed.push_back({e, 0});
            set_edge(e, 1);
            if (!check_affected(e.type, e.r, e.c)) return false;
            progress = true;
          }
        }

        // Quota atteint → les libres doivent être à 0
        if (cnt == target && free > 0) {
          auto fe = cell_free_edges(i,j);
          for (auto& e : fe) {
            changed.push_back({e, 0});
            set_edge(e, 0);
            progress = true;
          }
        }
      }
    }

    // --- Contraintes des sommets ---
    for (int r = 0; r <= N; r++) {
      for (int c = 0; c <= M; c++) {
        int deg  = vertex_deg(r,c);
        int free = vertex_free(r,c);

        if (deg > 2) return false;

        // Degré 1 et un seul libre → forcé à 1
        if (deg == 1 && free == 1) {
          auto fe = vertex_free_edges(r,c);
          for (auto& e : fe) {
            changed.push_back({e, 0});
            set_edge(e, 1);
            if (!check_affected(e.type, e.r, e.c)) return false;
            progress = true;
          }
        }

        // Degré 2 → tous les libres forcés à 0
        if (deg == 2 && free > 0) {
          auto fe = vertex_free_edges(r,c);
          for (auto& e : fe) {
            changed.push_back({e, 0});
            set_edge(e, 0);
            progress = true;
          }
        }
      }
    }
  }
  return true;
}

// -----------------------------------------------------------------------------
// Vérification boucle unique (DFS)
// -----------------------------------------------------------------------------
bool check_single_loop() {
  int NV = (N+1)*(M+1);
  std::vector<std::vector<int>> adj(NV);

  int total = 0;
  for (int r=0; r<=N; r++)
    for (int c=0; c<M; c++)
      if (H(r,c)==1) {
        adj[enc(r,c)].push_back(enc(r,c+1));
        adj[enc(r,c+1)].push_back(enc(r,c));
        total++;
      }
  for (int r=0; r<N; r++)
    for (int c=0; c<=M; c++)
      if (V(r,c)==1) {
        adj[enc(r,c)].push_back(enc(r+1,c));
        adj[enc(r+1,c)].push_back(enc(r,c));
        total++;
      }

  if (total == 0) return false;

  std::vector<bool> visited(NV, false);
  int start = -1;
  for (int i=0; i<NV; i++)
    if (!adj[i].empty()) { start=i; break; }
  if (start == -1) return false;

  std::vector<int> stack = {start};
  while (!stack.empty()) {
    int node = stack.back(); stack.pop_back();
    if (visited[node]) continue;
    visited[node] = true;
    for (int nb : adj[node])
      if (!visited[nb]) stack.push_back(nb);
  }

  for (int i=0; i<NV; i++)
    if (!adj[i].empty() && !visited[i]) return false;

  return true;
}

// -----------------------------------------------------------------------------
// BACKTRACKING avec propagation
// -----------------------------------------------------------------------------
void backtrack(const std::vector<Edge>& free_edges, int idx) {
  if (solution_found) return;

  // Propager les contraintes
  std::vector<std::pair<Edge,int>> changed;
  if (!propagate(changed)) {
    // Annuler les changements
    for (auto& p : changed) set_edge(p.first, p.second);
    return;
  }

  // Trouver la prochaine arête libre
  int next = -1;
  for (int i = idx; i < (int)free_edges.size(); i++) {
    const Edge& e = free_edges[i];
    int cur = (e.type==0) ? H(e.r,e.c) : V(e.r,e.c);
    if (cur == 0) { // encore libre (pas encore propagé)
      next = i; break;
    }
  }

  // Toutes les arêtes sont assignées → vérification finale
  if (next == -1) {
    // Vérification complète
    bool ok = true;
    for (int i=0; i<N && ok; i++)
      for (int j=0; j<M && ok; j++)
        ok = check_cell_strict(i,j);
    for (int r=0; r<=N && ok; r++)
      for (int c=0; c<=M && ok; c++)
        ok = check_vertex_strict(r,c);
    if (ok && check_single_loop())
      solution_found = true;

    for (auto& p : changed) set_edge(p.first, p.second);
    return;
  }

  const Edge& e = free_edges[next];

  // Essayer 1 puis 0
  for (int val : {1, 0}) {
    set_edge(e, val);
    if (check_affected(e.type, e.r, e.c)) {
      backtrack(free_edges, next + 1);
    }
    if (solution_found) {
      // Ne pas annuler — on garde la solution
      for (int i = (int)changed.size()-1; i >= 0; i--)
        ; // on garde
      return;
    }
    set_edge(e, 0);
  }

  // Annuler la propagation
  for (auto& p : changed) set_edge(p.first, p.second);
}

// -----------------------------------------------------------------------------
//' Solveur Slitherlink Optimisé C++
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
  for (int r=0; r<=N; r++)
    for (int c=0; c<M; c++)
      edges.push_back({0,r,c});
  for (int r=0; r<N; r++)
    for (int c=0; c<=M; c++)
      edges.push_back({1,r,c});

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