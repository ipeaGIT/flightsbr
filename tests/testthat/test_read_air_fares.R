context("read_air_fares")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------
cols <- c('Tarifa-N')

test_that("read_air_fares", {

  # (default), one month, basica, progress
  test1 <- read_air_fares()
  testthat::expect_true(is(test1, "data.table"))

  # one month, combinada, no progress bar
  test2 <- read_air_fares(date=200401, showProgress = FALSE)
  testthat::expect_true(is(test2, "data.table"))

  # check content
  testthat::expect_equal( as.character(min(test2$ANO)), as.character("2004") )

  # all months in a year
  test3 <- read_air_fares(date=2022, select=cols, showProgress = FALSE)
  testthat::expect_true(is(test3, "data.table"))
 })


# ERRORS and messages  -----------------------
test_that("read_air_fares", {

  # Wrong date 4 digits
  testthat::expect_error(read_air_fares(date=1990))
  testthat::expect_error(read_air_fares(date=9999))

  # Wrong date 6 digits
  testthat::expect_error(read_air_fares(date=199001))
  testthat::expect_error(read_air_fares(date=999901))

  # Wrong type and showProgress
  testthat::expect_error(read_air_fares(showProgress='banana'))
  testthat::expect_warning(read_air_fares(select='banana'))
})
