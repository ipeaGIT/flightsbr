context("read_aircraft")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_aircraft", {

  test1 <- read_aircraft(showProgress = FALSE)

  # (default), one month, basica, progress
  testthat::expect_true(is(test1, "data.table") | is.null(test1))
  testthat::expect_true(nrow(test1) > 0)

  testthat::expect_true(is(read_aircraft(showProgress = TRUE), "data.table"))

  # test columns are correct
  testthat::expect_equal(names(read_aircraft())[1], 'marca')

  # test date all months in a year
  test2 <- read_aircraft(date = 2020, showProgress = FALSE)
  testthat::expect_true(is(test2, "data.table"))

  # test vector of dates
  test3 <- read_aircraft(date = c(202001, 202005), showProgress = FALSE)
  testthat::expect_true(is(test3, "data.table"))

})


# ERRORS and messages  -----------------------
test_that("read_aircraft", {

  # Wrong date 4 digits
  testthat::expect_error(read_aircraft(date=1990))
  testthat::expect_error(read_aircraft(date=9999))

  # Wrong date 6 digits
  testthat::expect_error(read_aircraft(date=199001))
  testthat::expect_error(read_aircraft(date=999901))

  # mixed date format
  testthat::expect_error(read_aircraft(date=c(2020, 202101)))

  testthat::expect_error(read_aircraft(showProgress='banana'))
  testthat::expect_error(read_aircraft(showProgress=NULL))
  testthat::expect_error(read_aircraft(showProgress=3))
  testthat::expect_error(read_aircraft(a=NULL))

  testthat::expect_error(read_aircraft(cache='banana'))
  testthat::expect_error(read_aircraft(cache=NULL))
  testthat::expect_error(read_aircraft(cache=3))

})


# deprecated function  -----------------------

# test_that("add_two is deprecated", {
#
# testthat::expect_snapshot({
#
#  temp_deprecated <- read_aircrafts(showProgress = FALSE)
#  testthat::expect_equal(test1, temp_deprecated)
#  })
#
# })

# mock test
test_that("internet problem: throws informative message", {

  testthat::local_mocked_bindings(
    download_flightsbr_file = function(...) NULL
  )

  expect_message( read_aircraft() )
  expect_null( read_aircraft() )
})
