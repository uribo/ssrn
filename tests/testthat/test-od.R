test_that("multiplication works", {
  res <-
    make_passenger_od(jreast_jt_od,
                      jreast_jt,
                      departure_st_code,
                      arrive_st_code,
                      st_code,
                      volume)
  expect_is(res, "data.frame")
  expect_equal(
    dim(res),
    c(197, 4))
  expect_equal(
    nrow(jreast_jt_od),
    nrow(res)
  )
  res_all <-
    make_passenger_od(jreast_jt_od,
                      jreast_jt,
                      departure_st_code,
                      arrive_st_code,
                      st_code,
                      volume,
                      .all = TRUE)
  expect_equal(
    nrow(res_all),
    199L)
})
