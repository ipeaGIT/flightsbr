context("read_airports")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------

test_that("read_airports", {

    test1 <- read_airports()
    test2 <- read_airports(type = 'all'    , showProgress = FALSE)
    test3 <- read_airports(type = 'public' , showProgress = FALSE)
    test4 <- read_airports(type = 'private', showProgress = FALSE)

  # (default), one month, basica, progress
    testthat::expect_true(is(test1, "data.table"))
    testthat::expect_true(is(test2, "data.table"))
    testthat::expect_true(is(test3, "data.table"))
    testthat::expect_true(is(test4, "data.table"))

    testthat::expect_true(nrow(test1) >0 )
    testthat::expect_true(nrow(test2) >0 )
    testthat::expect_true(nrow(test3) >0 )
    testthat::expect_true(nrow(test4) >0 )

    # test columns are correct
    testthat::expect_equal(names(test1)[2], 'ciad')


})


# ERRORS and messages  -----------------------
test_that("read_airports", {

  testthat::expect_error(read_airports(type=NULL))
  testthat::expect_error(read_airports(type='banana'))
  testthat::expect_error(read_airports(showProgress='banana'))
  testthat::expect_error(read_airports(cache='banana'))

})

# mock test
test_that("internet problem: throws informative message", {

  testthat::local_mocked_bindings(
    download_flightsbr_file = function(...) NULL
  )

  expect_message( read_airports() )
  expect_null( read_airports() )
})
