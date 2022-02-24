context("latest_flights_date")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# latest_flights_date -----------------------

test_that("latest_flights_date", {

  testthat::expect_true(class(latest_flights_date()) == "numeric")
  testthat::expect_error(latest_flights_date(999))
})

