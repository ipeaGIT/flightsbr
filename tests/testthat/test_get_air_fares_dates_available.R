context("get_air_fares_dates_available")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# get_air_fares_dates_available -----------------------

test_that("get_air_fares_dates_available", {

  testthat::expect_true(class(get_air_fares_dates_available()) == "numeric")
  testthat::expect_error(get_air_fares_dates_available(999))
})

