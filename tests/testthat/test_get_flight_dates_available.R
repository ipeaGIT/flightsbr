context("get_flight_dates_available")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# get_flight_dates_available -----------------------

test_that("get_flight_dates_available", {

  dates1 <- get_flight_dates_available()

  testthat::expect_true(class(dates1) == "numeric")
  testthat::expect_true(length(dates1) > 0)
  testthat::expect_error(get_flight_dates_available(999))
})

