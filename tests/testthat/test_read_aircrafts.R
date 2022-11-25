context("read_aircrafts")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_aircrafts", {

  test1 <- read_aircrafts(showProgress = FALSE)

  # (default), one month, basica, progress
  testthat::expect_true(is(test1, "data.table"))
  testthat::expect_true(nrow(test1) > 0)

  testthat::expect_true(is(read_aircrafts(showProgress = TRUE), "data.table"))

  # test columns are correct
  testthat::expect_equal(names(read_aircrafts())[1], 'MARCA')
})


# ERRORS and messages  -----------------------
test_that("read_aircrafts", {

  testthat::expect_error(read_aircrafts(showProgress='banana'))
  testthat::expect_error(read_aircrafts(showProgress=NULL))
  testthat::expect_error(read_aircrafts(showProgress=3))
  testthat::expect_error(read_aircrafts(a=NULL))

})
