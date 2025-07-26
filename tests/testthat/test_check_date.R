context("check_date")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()



# check_date -----------------------

testthat::test_that("check_date", {

  testthat::expect_invisible( check_date(date = 2020, all_dates = 202001:202012) )
  testthat::expect_invisible( check_date(date = 202001, all_dates = 202001:202012) )
  testthat::expect_error( check_date(date = 2030, all_dates = 202001:202012) )
  testthat::expect_error( check_date(date = 203099, all_dates = 202001:202012) )

  })





