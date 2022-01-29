context("read_airports")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_airports", {

  # (default), one month, basica, progress

    testthat::expect_true(is(read_airports(type = 'all'), "data.table"))
    testthat::expect_true(is(read_airports(type = 'public'), "data.table"))
    testthat::expect_true(is(read_airports(type = 'private'), "data.table"))
    testthat::expect_true(is(read_airports(showProgress = FALSE), "data.table"))
})


# ERRORS and messages  -----------------------
test_that("read_airports", {

  testthat::expect_error(read_airports(type=NULL))
  testthat::expect_error(read_airports(type='banana'))
  testthat::expect_error(read_airports(showProgress='banana'))


})
