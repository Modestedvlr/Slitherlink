make_grid_3x3 <- function() {
  h <- matrix(0L,4,3); v <- matrix(0L,3,4)
  h[1,1]<-1L; h[1,2]<-1L; h[1,3]<-1L
  h[2,3]<-1L; h[3,3]<-1L
  h[4,1]<-1L; h[4,2]<-1L; h[4,3]<-1L
  v[1,1]<-1L; v[2,1]<-1L; v[3,1]<-1L
  v[1,4]<-1L; v[2,3]<-1L; v[3,4]<-1L
  indices <- matrix(0L,3,3)
  for(r in 1:3) for(c in 1:3)
    indices[r,c] <- (h[r,c]==1L)+(h[r+1,c]==1L)+(v[r,c]==1L)+(v[r,c+1]==1L)
  storage.mode(indices) <- "integer"
  new_slitherlink(indices)
}

test_that("solve_slitherlink resout un puzzle 3x3", {
  g <- make_grid_3x3()
  result <- solve_slitherlink(g)
  expect_false(is.null(result))
  expect_true(validate_solution(result)$valid)
})

test_that("solve_slitherlink resout un puzzle 4x4", {
  m <- matrix(c(2L,1L,1L,2L,1L,0L,0L,1L,
                1L,0L,0L,1L,2L,1L,1L,2L), nrow=4, byrow=TRUE)
  storage.mode(m) <- "integer"
  g <- new_slitherlink(m)
  result <- solve_slitherlink(g)
  expect_false(is.null(result))
  expect_true(validate_solution(result)$valid)
})

# APRÈS — puzzle valide mais sans solution
test_that("solve_slitherlink retourne NULL sur puzzle impossible", {
  # Case centrale = 3 entourée de cases = 0 → contradiction impossible
  m <- matrix(c(0L,0L,0L, 0L,3L,0L, 0L,0L,0L), nrow=3)
  storage.mode(m) <- "integer"
  result <- solve_slitherlink(new_slitherlink(m))
  expect_null(result)
})
