context("read_airport_movements")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------
testthat::test_that("read_airport_movements", {

  # (default), one month, basica, progress
  test1 <- read_airport_movements()
  testthat::expect_true(is(test1, "data.table"))
  testthat::expect_true(nrow(test1) >0 )

  # all months in a year
  test2 <- read_airport_movements(date=202401, showProgress = FALSE)
  testthat::expect_true(is(test2, "data.table"))

  # test vector of dates
  test3 <- read_airport_movements(date = c(202401, 202405), showProgress = FALSE)
  testthat::expect_true(is(test3, "data.table"))


  # check whether cache argument is working
  time_first <- system.time(
    f1 <- read_airport_movements(date = 202401))

  time_cache_true <- system.time(
    f2 <- read_airport_movements(date = 202401, cache = TRUE))

  time_cache_false <- system.time(
    f3 <- read_airport_movements(date = 202401, cache = FALSE))

  testthat::expect_true( time_cache_true[['elapsed']] < time_cache_false[['elapsed']] )
 })


# ERRORS and messages  -----------------------
testthat::test_that("read_airport_movements", {

  # Wrong date 4 digits
  testthat::expect_error(read_airport_movements(date=1990))
  testthat::expect_error(read_airport_movements(date=199012))
  testthat::expect_error(read_airport_movements(date=123456))

  # mixed date format
  testthat::expect_error(read_airport_movements(date=c(2020, 202101)))

  # Wrong type and showProgress and cache
  testthat::expect_error(read_airport_movements(showProgress='banana'))
  testthat::expect_error(read_airport_movements(cache='banana'))

})

# # mock test
# testthat::test_that("internet problem: throws informative message", {
#
#   testthat::local_mocked_bindings(
#     download_flightsbr_file = function(...) NULL
#   )
#
#   testthat::expect_message( read_airport_movements() )
#   testthat::expect_null( read_airport_movements() )
# })
