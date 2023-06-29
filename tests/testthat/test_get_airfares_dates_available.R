# context("")
#
# # skip tests because they take too much time
# skip_if(Sys.getenv("TEST_ONE") != "")
# testthat::skip_on_cran()
#
#
# # get_airfares_dates_available -----------------------
#
# test_that("get_airfares_dates_available", {
#
#   fares1 <- get_airfares_dates_available(dom = TRUE)
#   fares2 <- get_airfares_dates_available(dom = FALSE)
#
#   testthat::expect_true(class(fares1) == "numeric")
#   testthat::expect_true(class(fares2) == "numeric")
#
#   testthat::expect_true( length(fares1) >0 )
#   testthat::expect_true( length(fares2) >0 )
#
#
#   testthat::expect_error(fares1())
#   testthat::expect_error(fares2(dom = 999))
# })
#
