context("read_airfares")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_airfares", {

  # (default), one month, basica, progress
  test1 <- read_airfares()
  testthat::expect_true(is(test1, "data.table"))
  testthat::expect_true(nrow(test1) >0 )

  test2 <- read_airfares(domestic = FALSE)
  testthat::expect_true(is(test2, "data.table"))
  testthat::expect_true(nrow(test2) >0 )


  # one month, combinada, no progress bar
  test3 <- read_airfares(date=200401, showProgress = FALSE)
  testthat::expect_true(is(test3, "data.table"))
  testthat::expect_true(nrow(test3) >0 )

  test4 <- read_airfares(date=201202, showProgress = FALSE, domestic = FALSE)
  testthat::expect_true(is(test4, "data.table"))
  testthat::expect_true(nrow(test4) >0 )

  # check content
  testthat::expect_equal( as.character(min(test3$ANO)), as.character("2004") )
  testthat::expect_equal( as.character(min(test4$ANO)), as.character("2012") )

  # all months in a year
  test5 <- read_airfares(date=2022, select='Tarifa-N', showProgress = FALSE)
  testthat::expect_true(is(test5, "data.table"))

  test6 <- read_airfares(date=2022, domestic = FALSE, showProgress = FALSE, select='VALOR_TARIFA')
  testthat::expect_true(is(test6, "data.table"))

  # test vector of dates
  test7 <- read_airfares(date = c(202201, 202205), showProgress = FALSE)
  testthat::expect_true(is(test7, "data.table"))

  test8 <- read_airfares(date = c(2020, 2022), showProgress = FALSE)
  testthat::expect_true(is(test8, "data.table"))

})


# ERRORS and messages  -----------------------
test_that("read_airfares", {

  # Wrong date 4 digits
  testthat::expect_error(read_airfares(date=1990))
  testthat::expect_error(read_airfares(date=9999))
  testthat::expect_error(read_airfares(date=1990, domestic=FALSE))
  testthat::expect_error(read_airfares(date=9999, domestic=FALSE))

  # Wrong date 6 digits
  testthat::expect_error(read_airfares(date=199001))
  testthat::expect_error(read_airfares(date=999901))
  testthat::expect_error(read_airfares(date=199001, domestic=FALSE))
  testthat::expect_error(read_airfares(date=999901, domestic=FALSE))

  # mixed date format
  testthat::expect_error(read_airfares(date=c(2020, 202101)))

  # Wrong type and showProgress
  testthat::expect_error(read_airfares(showProgress='banana'))
  testthat::expect_warning(read_airfares(select='banana'))
  testthat::expect_error(read_airfares(cache='banana'))
})
