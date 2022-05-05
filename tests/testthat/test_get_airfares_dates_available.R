context("")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# get_airfares_dates_available -----------------------

test_that("get_airfares_dates_available", {

  testthat::expect_true(class(get_airfares_dates_available(dom = TRUE)) == "numeric")
  testthat::expect_true(class(get_airfares_dates_available(dom = FALSE)) == "numeric")

  testthat::expect_error(get_airfares_dates_available())
  testthat::expect_error(get_airfares_dates_available(dom = 999))
})

