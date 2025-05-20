context("read_airport_movements")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------
test_that("read_airport_movements", {

  # (default), one month, basica, progress
  test1 <- read_airport_movements()
  testthat::expect_true(is(test1, "data.table"))
  testthat::expect_true(nrow(test1) >0 )

  # all months in a year
  test2 <- read_airport_movements(date=2022, showProgress = FALSE)
  testthat::expect_true(is(test2, "data.table"))

  # test vector of dates
  test3 <- read_airport_movements(date = c(202201, 202205), showProgress = FALSE)
  testthat::expect_true(is(test3, "data.table"))


  # check whether cache argument is working
  time_first <- system.time(
    f201506 <- read_airport_movements(date = 202210))

  time_cache_true <- system.time(
    f201506 <- read_airport_movements(date = 202210, cache = TRUE))

  time_cache_false <- system.time(
    f201506 <- read_airport_movements(date = 202210, cache = FALSE))

  testthat::expect_true( time_cache_true[['elapsed']] < time_cache_false[['elapsed']] )
 })


# ERRORS and messages  -----------------------
test_that("read_airport_movements", {

  # Wrong date 4 digits
  testthat::expect_error(read_airport_movements(date=1990))
  testthat::expect_error(read_airport_movements(date=199012))

  # mixed date format
  testthat::expect_error(read_airport_movements(date=c(2020, 202101)))

  # Wrong type and showProgress and cache
  testthat::expect_error(read_airport_movements(showProgress='banana'))
  testthat::expect_error(read_airport_movements(cache='banana'))

})
