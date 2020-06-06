test_that("adjacent works", {
  jt_adjacent_matrix <-
    make_adjacency_matrix(jreast_jt, depart = st_name, arrive = next_st_name)
  expect_is(jt_adjacent_matrix,
                  "matrix")
  expect_equal(dim(jt_adjacent_matrix),
               c(20, 20))
  expect_equal(rownames(jt_adjacent_matrix),
               colnames(jt_adjacent_matrix))
  expect_equal(colSums(jt_adjacent_matrix),
               c(Tokyo = 1, Shimbashi = 2,
                 Shinagawa = 2, Kawasaki = 2,
                 Yokohama = 2, Totsuka = 2,
                 Ofuna = 2, Fujisawa = 2,
                 Tsujido = 2, Chigasaki = 2,
                 Hiratsuka = 2, Oiso = 2,
                 Ninomiya = 2, Kozu = 2,
                 Kamonomiya = 2, Odawara = 2,
                 Hayakawa = 2, Nebukawa = 2,
                 Manazuru = 2, Yugawara = 1))
  expect_equal(which(jt_adjacent_matrix["Tokyo", ] >= 1),
               c(Shimbashi = 2L))
  expect_equal(which(jt_adjacent_matrix[nrow(jt_adjacent_matrix), ] >= 1),
               c(Manazuru = 19L))
  expect_equal(as.numeric(which(jt_adjacent_matrix["Shimbashi", ] == 1)),
               c(1, 3))
})

test_that("passenger works", {
  jt_passenger_matrix <-
    jreast_jt_od %>%
    make_passenger_matrix(jreast_jt,
                          departure_st_code,
                          arrive_st_code,
                          st_code,
                          volume)
  expect_equal(
    dim(jt_passenger_matrix),
    c(nrow(jreast_jt),
      nrow(jreast_jt))
  )
  expect_equal(
    colnames(jt_passenger_matrix),
    rownames(jt_passenger_matrix)
  )
})
