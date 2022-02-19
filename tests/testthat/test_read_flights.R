context("read_flights")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------
cols <- c('nr_ano_referencia' , 'nr_mes_referencia')

test_that("read_flights", {

  # (default), one month, basica, progress
  test1 <- read_flights()
  testthat::expect_true(is(test1, "data.table"))

  # one month, combinada, no progress bar
  test2 <- read_flights(date=200001, type='combinada', select=cols ,showProgress = FALSE)
  testthat::expect_true(is(read_flights(date=200001, type='combinada', select=cols), "data.table"))

  # all months in a year
  test3 <- read_flights(date=2000, select=cols, showProgress = FALSE)
  testthat::expect_true(is(test3, "data.table"))
 })


# ERRORS and messages  -----------------------
test_that("read_flights", {

  # Wrong date 4 digits
  testthat::expect_error(read_flights(date=1990))
  testthat::expect_error(read_flights(date=9999))

  # Wrong date 6 digits
  testthat::expect_error(read_flights(date=199001))
  testthat::expect_error(read_flights(date=999901))

  # Wrong type and showProgress
  testthat::expect_error(read_flights(type='banana'))
  testthat::expect_error(read_flights(showProgress='banana'))
  testthat::expect_warning(read_flights(select='banana'))
})
