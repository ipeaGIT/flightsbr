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

  # test date all months in a year
  test2 <- read_aircrafts(date = 2020, showProgress = FALSE)
  testthat::expect_true(is(test2, "data.table"))

  # test vector of dates
  test3 <- read_aircrafts(date = c(202001, 202005), showProgress = FALSE)
  testthat::expect_true(is(test3, "data.table"))

})


# ERRORS and messages  -----------------------
test_that("read_aircrafts", {

  # Wrong date 4 digits
  testthat::expect_error(read_aircrafts(date=1990))
  testthat::expect_error(read_aircrafts(date=9999))

  # Wrong date 6 digits
  testthat::expect_error(read_aircrafts(date=199001))
  testthat::expect_error(read_aircrafts(date=999901))

  # mixed date format
  testthat::expect_error(read_aircrafts(date=c(2020, 202101)))

  testthat::expect_error(read_aircrafts(showProgress='banana'))
  testthat::expect_error(read_aircrafts(showProgress=NULL))
  testthat::expect_error(read_aircrafts(showProgress=3))
  testthat::expect_error(read_aircrafts(a=NULL))

  testthat::expect_error(read_aircrafts(cache='banana'))
  testthat::expect_error(read_aircrafts(cache=NULL))
  testthat::expect_error(read_aircrafts(cache=3))

})
