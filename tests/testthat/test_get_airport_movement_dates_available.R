context("get_airport_movement_dates_available")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# get_airport_movement_dates_available -----------------------

test_that("get_airport_movement_dates_available", {

  testthat::expect_true(class(get_airport_movement_dates_available()) == "numeric")
  testthat::expect_true(class(get_airport_movement_dates_available(date=2020)) == "numeric")
  testthat::expect_true(class(get_airport_movement_dates_available(date=202003)) == "numeric")
  testthat::expect_error( get_airport_movement_dates_available(date=2010))
  testthat::expect_error( get_airport_movement_dates_available(date=9))
})
