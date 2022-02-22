context("read_airports")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_airports", {

    test1 <- read_airports()
  # (default), one month, basica, progress
    testthat::expect_true(is(test1, "data.table"))
    testthat::expect_true(is(read_airports(type = 'all'    , showProgress = FALSE), "data.table"))
    testthat::expect_true(is(read_airports(type = 'public' , showProgress = FALSE), "data.table"))
    testthat::expect_true(is(read_airports(type = 'private', showProgress = FALSE), "data.table"))

    # test columns are correct
    testthat::expect_equal(names(test1)[2], 'ciad')


})


# ERRORS and messages  -----------------------
test_that("read_airports", {

  testthat::expect_error(read_airports(type=NULL))
  testthat::expect_error(read_airports(type='banana'))
  testthat::expect_error(read_airports(showProgress='banana'))


})
