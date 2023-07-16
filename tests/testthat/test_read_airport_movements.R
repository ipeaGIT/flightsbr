context("read_airport_movements")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------
test_that("read_airport_movements", {

  # (default), one month, basica, progress
  test1 <- read_airport_movements(date=202201)
  testthat::expect_true(is(test1, "data.table"))
  testthat::expect_true(nrow(test1) >0 )

  # check conteudo
  testthat::expect_equal( as.character(min(test1$DT_PREVISTO)), as.character("2021-12-31") )

  # all months in a year
  test2 <- read_airport_movements(date=2022, showProgress = FALSE)
  testthat::expect_true(is(test2, "data.table"))


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
  try( test3 <- read_airport_movements(date=1990), silent = TRUE)
  if (exists('test3')) { testthat::expect_null(test3) }

  try( test4 <- read_airport_movements(date=9999), silent = TRUE)
  if (exists('test4')) { testthat::expect_null(test4) }

  # Wrong date 6 digits
  try( test5 <- read_airport_movements(date=999901), silent = TRUE)
  if (exists('test5')) { testthat::expect_null(test5) }

  # Wrong type and showProgress
  testthat::expect_error(read_airport_movements(showProgress='banana'))

})
