context("read_airport_movements")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------
test_that("read_airport_movements", {

  # (default), one month, basica, progress
  test1 <- read_airport_movements(date=202001)
  testthat::expect_true(is(test1, "data.table"))

  # all months in a year
  test2 <- read_airport_movements(date=2020, showProgress = FALSE)
  testthat::expect_true(is(test2, "data.table"))
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
