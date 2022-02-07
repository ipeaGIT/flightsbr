context("read_aircrafts")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_aircrafts", {

  # (default), one month, basica, progress
  testthat::expect_true(is(read_aircrafts(showProgress = FALSE), "data.table"))
  testthat::expect_true(is(read_aircrafts(), "data.table"))
})


# ERRORS and messages  -----------------------
test_that("read_aircrafts", {

  testthat::expect_error(read_aircrafts(showProgress='banana'))
  testthat::expect_error(read_aircrafts(showProgress=NULL))

})