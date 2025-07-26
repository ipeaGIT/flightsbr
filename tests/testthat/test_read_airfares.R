context("read_airfares")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

testthat::test_that("read_airfares", {

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

  test4 <- read_airfares(date=202501, showProgress = FALSE, domestic = FALSE)
  testthat::expect_true(is(test4, "data.table"))
  testthat::expect_true(nrow(test4) >0 )

  # check content
  testthat::expect_equal( as.character(min(test3$ano)), as.character("2004") )
  testthat::expect_equal( as.character(min(test4$nr_ano_referencia)), as.character("2025") )

  # all months in a year
  test5 <- read_airfares(date=200401:200402, select='tarifa-n', showProgress = TRUE)
  testthat::expect_true(is(test5, "data.table") | is.null(test5))

  test6 <- read_airfares(date=201101:201102,
                         domestic = FALSE,
                         showProgress = FALSE,
                         select='valor_tarifa'
                         )
  testthat::expect_true(is(test6, "data.table"))

  # test vector of dates
  test7 <- read_airfares(date = c(200401, 200402), showProgress = FALSE)
  testthat::expect_true(is(test7, "data.table"))


})


# ERRORS and messages  -----------------------
testthat::test_that("read_airfares", {

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
  testthat::expect_error(read_airfares(date= 1))

  # Wrong type and showProgress
  testthat::expect_error(read_airfares(showProgress='banana'))
  testthat::expect_warning(read_airfares(select='banana'))
  testthat::expect_error(read_airfares(cache='banana'))
})

# # mock test
# testthat::test_that("internet problem: throws informative message", {
#
#   testthat::local_mocked_bindings(
#     download_flightsbr_file = function(...) NULL
#   )
#
#   testthat::expect_message( read_airfares() )
#   testthat::expect_null( read_airfares() )
# })
